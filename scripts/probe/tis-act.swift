// Acting half of the "new input source without logging out" experiments (docs/research/M5-INSTALL.md 8.2).
// Side effects: installs input method, changes input source
//
//   tis-act register <path.app>                 TISRegisterInputSource
//   tis-act enable <id>                         TISEnableInputSource (the source must be listed)
//   tis-act select <id>                         TISSelectInputSource (the source must be listed)
//   tis-act wait-listed <id> [--timeout 20] [--interval 0.5]
//                                               polls TISCreateInputSourceList in THIS process
//   tis-act p1 <path.app>                       one process: register, wait-listed parent, enable parent,
//                                               wait-listed mode (<parent>.vi), enable mode
//
// Every command prints one line per call with the OSStatus (0 = noErr). On macOS 27.2 a third-party
// Enable returns 0 without effect (System Settings must confirm), so status 0 proves nothing:
// read the result with scripts/probe/tis-probe in a fresh process. Run through scripts/probe/step.sh
// only: it changes the user's input sources. Packed as build/probe.noindex/TisAct.app (CFBundleName
// "Dấu thử") by scripts/probe/build-tools.sh so System Settings has an app name for the "Allow … to
// enable …?" dialog.
import Carbon
import Foundation

setvbuf(stdout, nil, _IOLBF, 0)
let started = Date()

func stamp() -> String {
    let f = DateFormatter()
    f.dateFormat = "HH:mm:ss.SSS"
    return f.string(from: Date())
}

func log(_ message: String) { print("\(stamp()) \(message)") }

func fail(_ message: String, code: Int32 = 1) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(code)
}

func findSource(_ id: String) -> TISInputSource? {
    let filter = [kTISPropertyInputSourceID as String: id] as CFDictionary
    guard let list = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource] else { return nil }
    return list.first
}

func register(_ path: String) -> OSStatus {
    let status = TISRegisterInputSource(URL(fileURLWithPath: path) as CFURL)
    log("register path=\(path) status=\(status)")
    return status
}

func enable(_ id: String) -> OSStatus? {
    guard let source = findSource(id) else { log("enable id=\(id) not-listed"); return nil }
    let status = TISEnableInputSource(source)
    log("enable id=\(id) status=\(status)")
    return status
}

func select(_ id: String) -> OSStatus? {
    guard let source = findSource(id) else { log("select id=\(id) not-listed"); return nil }
    let status = TISSelectInputSource(source)
    log("select id=\(id) status=\(status)")
    return status
}

func waitListed(_ id: String, timeout: Double, interval: Double) -> Bool {
    let begin = Date()
    var attempts = 0
    while true {
        attempts += 1
        if findSource(id) != nil {
            log(String(format: "wait-listed id=%@ listed=true attempts=%d elapsed=%.3fs", id, attempts, Date().timeIntervalSince(begin)))
            return true
        }
        if Date().timeIntervalSince(begin) + interval > timeout { break }
        usleep(UInt32(interval * 1_000_000))
    }
    log(String(format: "wait-listed id=%@ listed=false attempts=%d elapsed=%.3fs", id, attempts, Date().timeIntervalSince(begin)))
    return false
}

func bundleID(ofApp path: String) -> String {
    guard let bundle = Bundle(path: path), let id = bundle.bundleIdentifier else { fail("không đọc được CFBundleIdentifier của \(path)", code: 2) }
    return id
}

func option(_ name: String, in args: [String], default value: Double) -> Double {
    guard let i = args.firstIndex(of: name), i + 1 < args.count, let v = Double(args[i + 1]) else { return value }
    return v
}

let args = Array(CommandLine.arguments.dropFirst())
switch args.first {
case "register":
    guard args.count == 2 else { fail("usage: tis-act register <path.app>", code: 2) }
    exit(register(args[1]) == noErr ? 0 : 1)

case "enable":
    guard args.count == 2 else { fail("usage: tis-act enable <id>", code: 2) }
    exit(enable(args[1]) == noErr ? 0 : 1)

case "select":
    guard args.count == 2 else { fail("usage: tis-act select <id>", code: 2) }
    exit(select(args[1]) == noErr ? 0 : 1)

case "wait-listed":
    guard args.count >= 2 else { fail("usage: tis-act wait-listed <id> [--timeout 20] [--interval 0.5]", code: 2) }
    let found = waitListed(args[1], timeout: option("--timeout", in: args, default: 20), interval: option("--interval", in: args, default: 0.5))
    exit(found ? 0 : 3)

case "p1":
    guard args.count == 2 else { fail("usage: tis-act p1 <path.app>", code: 2) }
    let parent = bundleID(ofApp: args[1])
    let mode = parent + ".vi"
    _ = register(args[1])
    if waitListed(parent, timeout: 20, interval: 0.5) { _ = enable(parent) }
    if waitListed(mode, timeout: 20, interval: 0.5) { _ = enable(mode) }
    log(String(format: "p1 done elapsed=%.3fs", Date().timeIntervalSince(started)))

default:
    fail("usage: tis-act register <path.app> | enable <id> | select <id> | wait-listed <id> [--timeout S] [--interval S] | p1 <path.app>", code: 2)
}
