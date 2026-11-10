// Screenshots the canvas artboards for scripts/design/render-canvas.sh, which builds this
// file once with scripts/lib/swift-tool.sh.
//
//   canvas-render CHROME PROFILE PROJECT OUT PIDFILE < boards.tsv
//
//   CHROME    the Google Chrome executable
//   PROFILE   an empty folder for --user-data-dir (never the user's Chrome profile)
//   PROJECT   the folder with <name>.dc.html and support.js
//   OUT       where <name>.png goes
//   PIDFILE   gets the pid of the Chrome this tool started, for the caller's cleanup
//   stdin     name<TAB>width<TAB>height, one board a line (canvas-index boards)
//
// stdout, one line per event, for the caller to print:
//   ok<TAB>name<TAB>width<TAB>height     the board was written
//   warn<TAB>name<TAB>text               a resource of the board did not load
//   fail<TAB>name<TAB>text               the board was not written
// Exit status 0 when every board was written, 1 otherwise (also when Chrome did not start).
//
// One headless Chrome serves the whole run. It is driven over the DevTools protocol on
// --remote-debugging-pipe: Chrome reads commands on fd 3 and answers on fd 4, each message
// a JSON text followed by a NUL byte. No port is opened, and Chrome quits by itself when
// the pipe closes, so it cannot outlive this tool. A board is rendered like
// `chrome --screenshot --virtual-time-budget=8000` renders it: the page gets 8 seconds of
// virtual time (timers and animations run without waiting, pending fetches hold the clock),
// then the viewport is captured at scale 1. One step is added: a web font that is still
// loading when the time is up is waited for, so that the picture does not depend on how
// fast the font came (see `render`).
import Foundation

let usage = "Cách dùng: canvas-render CHROME PROFILE PROJECT OUT PIDFILE < boards.tsv"
let virtualTimeBudget = 8000.0  // milliseconds, the budget render-canvas.sh has always used
let fontRounds = 20  // extra rounds of virtual time while a font is still loading
let fontRoundBudget = 250.0  // milliseconds of virtual time a round
let startTimeout = 30.0  // seconds for Chrome to answer the first command
let commandTimeout = 30.0  // seconds for one protocol command
let renderTimeout = 60.0  // real seconds for a board to use up its virtual time

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

/// Set once before the signal handlers are installed, then only read.
nonisolated(unsafe) var chromePID: pid_t = 0

struct ProtocolError: Error, CustomStringConvertible {
    let description: String
}

/// The DevTools connection to one Chrome process over a pair of pipes.
final class Chrome {
    private let toChrome: Int32
    private let fromChrome: Int32
    private var buffer = Data()
    private var nextID = 0
    /// Events that arrived while waiting for a command's answer, oldest first.
    private var events: [[String: Any]] = []

    init(executable: String, arguments: [String]) {
        var commands: [Int32] = [0, 0], answers: [Int32] = [0, 0]
        guard pipe(&commands) == 0, pipe(&answers) == 0 else { fail("Không tạo được pipe") }
        // Move all four ends above the descriptors the child gets, so that dup2 onto 3 and 4
        // in the child cannot overwrite an end that is still needed.
        let ends = (commands + answers).map { fd -> Int32 in
            let high = fcntl(fd, F_DUPFD_CLOEXEC, 10)
            close(fd)
            return high
        }
        guard ends.allSatisfy({ $0 >= 10 }) else { fail("Không tạo được pipe") }

        var actions: posix_spawn_file_actions_t?
        posix_spawn_file_actions_init(&actions)
        // Chrome's own log lines are not this tool's output.
        posix_spawn_file_actions_addopen(&actions, 0, "/dev/null", O_RDONLY, 0)
        posix_spawn_file_actions_addopen(&actions, 1, "/dev/null", O_WRONLY, 0)
        posix_spawn_file_actions_addopen(&actions, 2, "/dev/null", O_WRONLY, 0)
        posix_spawn_file_actions_adddup2(&actions, ends[0], 3)
        posix_spawn_file_actions_adddup2(&actions, ends[3], 4)
        var attributes: posix_spawnattr_t?
        posix_spawnattr_init(&attributes)
        // Only the descriptors named above reach Chrome.
        posix_spawnattr_setflags(&attributes, Int16(POSIX_SPAWN_CLOEXEC_DEFAULT))

        var argv: [UnsafeMutablePointer<CChar>?] = ([executable] + arguments).map { strdup($0) }
        argv.append(nil)
        var pid: pid_t = 0
        let status = posix_spawn(&pid, executable, &actions, &attributes, argv, environ)
        argv.forEach { free($0) }
        posix_spawn_file_actions_destroy(&actions)
        posix_spawnattr_destroy(&attributes)
        guard status == 0 else { fail("Không chạy được \(executable): \(String(cString: strerror(status)))") }
        chromePID = pid
        close(ends[0])
        close(ends[3])
        toChrome = ends[1]
        fromChrome = ends[2]
    }

    /// The next message from Chrome, or nil when `deadline` passes or Chrome is gone.
    private func readMessage(until deadline: Date) -> [String: Any]? {
        while true {
            if let end = buffer.firstIndex(of: 0) {
                let message = buffer[buffer.startIndex..<end]
                buffer = Data(buffer[buffer.index(after: end)...])
                if let object = (try? JSONSerialization.jsonObject(with: message)) as? [String: Any] {
                    return object
                }
                continue
            }
            let left = deadline.timeIntervalSinceNow
            guard left > 0 else { return nil }
            var descriptor = pollfd(fd: fromChrome, events: Int16(POLLIN), revents: 0)
            let ready = poll(&descriptor, 1, Int32(min(left * 1000, 1000).rounded(.up)))
            if ready < 0 && errno != EINTR { return nil }
            guard ready > 0 else { continue }
            var chunk = [UInt8](repeating: 0, count: 1 << 16)
            let count = read(fromChrome, &chunk, chunk.count)
            if count == 0 { return nil }  // Chrome closed the pipe
            if count < 0 {
                if errno == EINTR || errno == EAGAIN { continue }
                return nil
            }
            buffer.append(contentsOf: chunk[0..<count])
        }
    }

    /// Sends one command and returns its result; events that arrive first are kept.
    @discardableResult
    func send(_ method: String, _ params: [String: Any] = [:], session: String? = nil,
              timeout: Double = commandTimeout) throws -> [String: Any] {
        nextID += 1
        let id = nextID
        var message: [String: Any] = ["id": id, "method": method, "params": params]
        if let session { message["sessionId"] = session }
        var data = (try? JSONSerialization.data(withJSONObject: message)) ?? Data()
        data.append(0)
        var sent = 0
        while sent < data.count {
            let count = data.withUnsafeBytes { write(toChrome, $0.baseAddress! + sent, data.count - sent) }
            if count < 0 {
                if errno == EINTR { continue }
                throw ProtocolError(description: "Chrome đã thoát (\(method))")
            }
            sent += count
        }
        let deadline = Date(timeIntervalSinceNow: timeout)
        while let answer = readMessage(until: deadline) {
            guard answer["id"] as? Int == id else {
                if answer["method"] != nil { events.append(answer) }
                continue
            }
            if let error = answer["error"] as? [String: Any] {
                throw ProtocolError(description: "\(method): \(error["message"] as? String ?? "lỗi")")
            }
            return answer["result"] as? [String: Any] ?? [:]
        }
        throw ProtocolError(description: "\(method): Chrome không trả lời sau \(Int(timeout)) giây")
    }

    /// Hands every event received so far, and then each new one, to `handle` until it
    /// returns true. False when `timeout` passes first or Chrome is gone.
    func waitForEvent(timeout: Double, _ handle: ([String: Any]) -> Bool) -> Bool {
        let deadline = Date(timeIntervalSinceNow: timeout)
        while true {
            while !events.isEmpty {
                if handle(events.removeFirst()) { return true }
            }
            guard let message = readMessage(until: deadline) else { return false }
            if message["method"] != nil { events.append(message) }
        }
    }

    func dropEvents() { events.removeAll() }

    /// Asks Chrome to quit and waits for it; kills it when it does not.
    func quit() {
        _ = try? send("Browser.close", timeout: 5)
        close(toChrome)
        close(fromChrome)
        let deadline = Date(timeIntervalSinceNow: 10)
        var status: Int32 = 0
        while waitpid(chromePID, &status, WNOHANG) == 0 {
            if Date() > deadline {
                kill(chromePID, SIGKILL)
                waitpid(chromePID, &status, 0)
                break
            }
            usleep(50_000)
        }
    }
}

/// Renders one board to `png`. Returns the URLs the page asked for and did not get.
func render(_ chrome: Chrome, url: String, width: Int, height: Int, png: String) throws -> [String] {
    // Chrome takes a size only for a new window; in headless mode that window is never shown.
    let target = try chrome.send("Target.createTarget",
                                 ["url": "about:blank", "width": width, "height": height, "newWindow": true])
    guard let targetID = target["targetId"] as? String else { throw ProtocolError(description: "Không mở được trang") }
    defer {
        _ = try? chrome.send("Target.closeTarget", ["targetId": targetID])
        chrome.dropEvents()
    }
    let attached = try chrome.send("Target.attachToTarget", ["targetId": targetID, "flatten": true])
    guard let session = attached["sessionId"] as? String else { throw ProtocolError(description: "Không nối được với trang") }

    try chrome.send("Page.enable", session: session)
    try chrome.send("Network.enable", session: session)
    try chrome.send("Emulation.setDeviceMetricsOverride",
                    ["width": width, "height": height, "deviceScaleFactor": 1, "mobile": false], session: session)
    // Hold the clock until the page is on its way, then let it run for the budget.
    try chrome.send("Emulation.setVirtualTimePolicy", ["policy": "pause"], session: session)
    let navigation = try chrome.send("Page.navigate", ["url": url], session: session)
    if let error = navigation["errorText"] as? String, !error.isEmpty {
        throw ProtocolError(description: "Không mở được trang: \(error)")
    }
    var requested: [String: String] = [:]  // request id -> URL
    var missing: [String] = []
    /// Lets the page's clock run for `budget` milliseconds; notes resources that did not load.
    func runClock(_ budget: Double) throws {
        try chrome.send("Emulation.setVirtualTimePolicy",
                        ["policy": "pauseIfNetworkFetchesPending", "budget": budget], session: session)
        let expired = chrome.waitForEvent(timeout: renderTimeout) { event in
            guard event["sessionId"] as? String == session, let method = event["method"] as? String else { return false }
            let params = event["params"] as? [String: Any] ?? [:]
            switch method {
            case "Network.requestWillBeSent":
                if let id = params["requestId"] as? String, let request = params["request"] as? [String: Any],
                   let url = request["url"] as? String { requested[id] = url }
            case "Network.loadingFailed":
                if params["canceled"] as? Bool != true, let id = params["requestId"] as? String {
                    missing.append("\(requested[id] ?? "?") (\(params["errorText"] as? String ?? "lỗi"))")
                }
            case "Network.responseReceived":
                if let response = params["response"] as? [String: Any], let status = response["status"] as? Int,
                   status >= 400, let url = response["url"] as? String { missing.append("\(url) (HTTP \(status))") }
            case "Emulation.virtualTimeBudgetExpired":
                return true
            default:
                break
            }
            return false
        }
        guard expired else { throw ProtocolError(description: "Trang chưa dựng xong sau \(Int(renderTimeout)) giây") }
    }
    /// Lays the page out and says whether a web font is still loading.
    func fontLoading() throws -> Bool {
        let state = try chrome.send("Runtime.evaluate",
                                    ["expression": "document.body && document.body.offsetHeight, document.fonts.status",
                                     "returnByValue": true], session: session)
        return (state["result"] as? [String: Any])?["value"] as? String == "loading"
    }

    try runClock(virtualTimeBudget)
    // Chrome asks for a web font when it lays out text that uses it, and text added during
    // the budget may get its first layout only at the capture: the picture would show the
    // fallback font, or not, by a race. Lay out now; while a font is on its way, give the
    // page more virtual time (font loading does not move while the clock is stopped).
    var lateFont = false
    for _ in 0..<fontRounds {
        guard try fontLoading() else { break }
        lateFont = true
        try runClock(fontRoundBudget)
    }
    if lateFont {
        // Chrome may already have painted with the fallback font. Painting again over that
        // leaves edge pixels that differ from a single paint, and whether it happened is a
        // race too. A throwaway capture at scale 2 drops what was painted at scale 1, so
        // the capture below paints everything once.
        try chrome.send("Emulation.setDeviceMetricsOverride",
                        ["width": width, "height": height, "deviceScaleFactor": 2, "mobile": false], session: session)
        try chrome.send("Page.captureScreenshot", ["format": "png"], session: session, timeout: 60)
        try chrome.send("Emulation.setDeviceMetricsOverride",
                        ["width": width, "height": height, "deviceScaleFactor": 1, "mobile": false], session: session)
    }

    let shot = try chrome.send("Page.captureScreenshot", ["format": "png"], session: session, timeout: 60)
    guard let encoded = shot["data"] as? String, let image = Data(base64Encoded: encoded) else {
        throw ProtocolError(description: "Chrome không trả ảnh")
    }
    guard FileManager.default.createFile(atPath: png, contents: image) else {
        throw ProtocolError(description: "Không ghi được \(png)")
    }
    return missing
}

let arguments = Array(CommandLine.arguments.dropFirst())
guard arguments.count == 5 else { fail(usage) }
let (executable, profile, project, out, pidFile) = (arguments[0], arguments[1], arguments[2], arguments[3], arguments[4])

struct Board {
    let name: String, width: String, height: String
}
var boards: [Board] = []
while let line = readLine() {
    let fields = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
    guard fields.count == 3, Double(fields[1]) != nil, Double(fields[2]) != nil else { fail("Dòng không hợp lệ: \(line)") }
    boards.append(Board(name: fields[0], width: fields[1], height: fields[2]))
}

setvbuf(stdout, nil, _IOLBF, 0)  // the caller prints each line as it comes
signal(SIGPIPE, SIG_IGN)  // a write to a Chrome that died is an error to report, not a signal
let chrome = Chrome(executable: executable, arguments: [
    "--headless=new", "--remote-debugging-pipe", "--user-data-dir=\(profile)",
    "--no-first-run", "--no-default-browser-check", "--disable-gpu", "--hide-scrollbars",
    // The canvas runtime fetches the page itself and sibling boards; Chrome blocks that on file://.
    "--allow-file-access-from-files",
    "about:blank",
])
guard (try? Data("\(chromePID)\n".utf8).write(to: URL(fileURLWithPath: pidFile))) != nil else {
    kill(chromePID, SIGTERM)
    fail("Không ghi được \(pidFile)")
}
// Stopped from outside: take Chrome along instead of leaving it to notice the closed pipe.
for number in [SIGINT, SIGTERM, SIGHUP] {
    signal(number) { number in
        kill(chromePID, SIGTERM)
        _exit(128 + number)
    }
}
do {
    try chrome.send("Browser.getVersion", timeout: startTimeout)
} catch {
    kill(chromePID, SIGTERM)
    fail("Chrome không khởi động được ở chế độ chạy ẩn: \(error)")
}

var failed = false
for board in boards {
    let stem = board.name.hasSuffix(".dc.html") ? String(board.name.dropLast(".dc.html".count)) : board.name
    let page = URL(fileURLWithPath: project).appendingPathComponent(board.name)
    // A viewport is a whole number of pixels; a fractional board size is rounded up so that
    // nothing is cut off.
    let width = Int(Double(board.width)!.rounded(.up)), height = Int(Double(board.height)!.rounded(.up))
    do {
        let missing = try render(chrome, url: page.absoluteString, width: width, height: height, png: "\(out)/\(stem).png")
        for url in missing { print("warn\t\(board.name)\tkhông tải được \(url)") }
        print("ok\t\(board.name)\t\(board.width)\t\(board.height)")
    } catch {
        failed = true
        print("fail\t\(board.name)\t\(error)")
    }
}
chrome.quit()
exit(failed ? 1 : 0)
