import Foundation
import DauEngine
import Testing

/// D43: `WebHost` on fake bundles in a temporary directory (layouts read from the apps on
/// a development machine, 12/11/2026), and the composer with its verdict.
@Suite("D43: web hosts read from the app bundle (WebHost)")
struct WebHostTests {
    // MARK: Fake bundles

    /// A thin 64-bit Mach-O header with one LC_LOAD_DYLIB per library.
    static func machO(_ libraries: [String]) -> Data {
        var commands = Data()
        for name in libraries {
            var bytes = Array(name.utf8) + [0]
            while (24 + bytes.count) % 8 != 0 { bytes.append(0) }
            let size = UInt32(24 + bytes.count)
            commands += le(0xC) + le(size) + le(24) + le(0) + le(0) + le(0) + Data(bytes)
        }
        let header = le(0xFEED_FACF) + le(0x0100_000C) + le(0) + le(2) + le(UInt32(libraries.count))
            + le(UInt32(commands.count)) + le(0) + le(0)
        return header + commands
    }

    /// A universal file of `slices` (fat_arch, big-endian), each at a 4 KB boundary.
    static func fat(_ slices: [Data]) -> Data {
        var data = be(0xCAFE_BABE) + be(UInt32(slices.count))
        var offset = 4096
        var bodies = Data()
        for slice in slices {
            data += be(0x0100_000C) + be(0) + be(UInt32(offset)) + be(UInt32(slice.count)) + be(12)
            bodies += slice + Data(count: 4096 - slice.count % 4096)
            offset += slice.count + (4096 - slice.count % 4096)
        }
        return data + Data(count: 4096 - data.count) + bodies
    }

    static func le(_ v: UInt32) -> Data { withUnsafeBytes(of: v.littleEndian) { Data($0) } }
    static func be(_ v: UInt32) -> Data { withUnsafeBytes(of: v.bigEndian) { Data($0) } }

    static let system = ["/usr/lib/libSystem.B.dylib",
                         "/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit"]
    static let webKit = "/System/Library/Frameworks/WebKit.framework/Versions/A/WebKit"

    /// Builds an .app in a new temporary directory: `files` maps paths under Contents to
    /// their data (nil: a directory). The main executable is Contents/MacOS/App.
    static func bundle(executable: Data? = machO(system), info: Bool = true,
                       _ files: [String: Data?] = [:]) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("WebHostTests-\(UUID().uuidString)/App.app")
        let contents = root.appendingPathComponent("Contents")
        try FileManager.default.createDirectory(at: contents.appendingPathComponent("MacOS"),
                                                withIntermediateDirectories: true)
        if info {
            let plist = try PropertyListSerialization.data(fromPropertyList: ["CFBundleExecutable": "App"],
                                                           format: .xml, options: 0)
            try plist.write(to: contents.appendingPathComponent("Info.plist"))
        }
        if let executable { try executable.write(to: contents.appendingPathComponent("MacOS/App")) }
        for (path, data) in files {
            let url = contents.appendingPathComponent(path)
            if let data {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true)
                try data.write(to: url)
            } else {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            }
        }
        return root
    }

    static func remove(_ bundle: URL) {
        try? FileManager.default.removeItem(at: bundle.deletingLastPathComponent())
    }

    // MARK: Verdicts

    @Test("the Mach-O reader gives the libraries of a thin and of a universal file")
    func reader() throws {
        let url = try Self.bundle(executable: Self.fat([Self.machO(Self.system), Self.machO([Self.webKit])]))
        defer { Self.remove(url) }
        let libraries = WebHost.loadedLibraries(machO: url.appendingPathComponent("Contents/MacOS/App"))
        #expect(libraries == Self.system + [Self.webKit])
    }

    @Test("web engines are told apart by the bundle's structure",
          arguments: [
            // Electron (VS Code, Cursor, Claude, Discord…).
            ("electron", ["Frameworks/Electron Framework.framework/Electron Framework": machO(system),
                          "Frameworks/App Helper (Renderer).app": nil], "chromium"),
            // Chrome, Edge, Blisk: the helper in the framework's versioned Helpers.
            ("chrome", ["Frameworks/App Framework.framework/Versions/1.2.3/Helpers/App Helper (Renderer).app": nil,
                        "Frameworks/App Framework.framework/Versions/1.2.3/App Framework": machO(system)], "chromium"),
            ("cef", ["Frameworks/Chromium Embedded Framework.framework": nil], "chromium"),
            ("gecko", ["MacOS/XUL": machO(system)], "gecko"),
            // A WKWebView or Tauri app, through a framework of its own.
            ("webkit framework", ["Frameworks/UI.framework/UI": machO(system + [webKit])], "webkit"),
          ] as [(String, [String: Data?], String)])
    func web(name: String, files: [String: Data?], engine: String) throws {
        let url = try Self.bundle(files)
        defer { Self.remove(url) }
        #expect(WebHost.classify(bundle: url) == .web(engine: engine), "\(name)")
    }

    @Test("the main executable loading WebKit or Safari.framework is a web host",
          arguments: [webKit, "/System/Library/PrivateFrameworks/Safari.framework/Versions/A/Safari"])
    func webKitExecutable(library: String) throws {
        let url = try Self.bundle(executable: Self.machO(Self.system + [library]))
        defer { Self.remove(url) }
        #expect(WebHost.classify(bundle: url) == .web(engine: "webkit"))
    }

    @Test("a Ghostty-like app (AppKit, Sparkle loading WebKit for its own window) is native")
    func ghosttyLike() throws {
        let url = try Self.bundle(executable: Self.machO(Self.system + ["@rpath/Sparkle.framework/Versions/B/Sparkle"]),
                                  ["Frameworks/Sparkle.framework/Sparkle": Self.machO(Self.system + [Self.webKit])])
        defer { Self.remove(url) }
        #expect(WebHost.classify(bundle: url) == .native)
        #expect(WebHost.classify(bundle: url).allowsAfterKey)
        // Terminal: no Frameworks at all.
        let bare = try Self.bundle()
        defer { Self.remove(bare) }
        #expect(WebHost.classify(bundle: bare) == .native)
    }

    @Test("a bundle that cannot be read is not native",
          arguments: ["no Info.plist", "no executable", "not Mach-O", "bad framework", "no bundle"])
    func unreadable(why: String) throws {
        let url: URL
        switch why {
        case "no Info.plist": url = try Self.bundle(info: false)
        case "no executable": url = try Self.bundle(executable: nil)
        case "not Mach-O": url = try Self.bundle(executable: Data("#!/bin/sh\n".utf8))
        case "bad framework": url = try Self.bundle(["Frameworks/X.framework/X": Data(count: 64)])
        default: url = FileManager.default.temporaryDirectory.appendingPathComponent("WebHostTests-none/App.app")
        }
        defer { Self.remove(url) }
        let verdict = WebHost.classify(bundle: url)
        #expect(!verdict.allowsAfterKey)
        #expect(verdict.blockedWord == "unknown")
    }

    @Test("the verdict is kept per bundle version")
    func cached() throws {
        let url = try Self.bundle()
        defer { Self.remove(url) }
        #expect(WebHost.verdict(bundle: url) == .native)
        // The same version read again: the cache answers, even if a file appeared since
        // (an update changes the modification dates of Info.plist or Contents/MacOS).
        try FileManager.default.createDirectory(at: url.appendingPathComponent("Contents/Frameworks/Electron Framework.framework"),
                                                withIntermediateDirectories: true)
        #expect(WebHost.verdict(bundle: url) == .native)
        #expect(WebHost.classify(bundle: url) == .web(engine: "chromium"))
    }

    // MARK: The composer

    @Test("Ghostty-like answers in an app not read as native: in place, no DEL, as before D43")
    func blockedAfterKey() {
        var engine = VietEngine()
        var composer = InPlaceComposer()  // afterKeyAllowed false
        let terminal = FakeGhostty()
        var now: TimeInterval = 0
        var sent: [String] = []
        for scalar in RangeIgnoreTests.t4Line.unicodeScalars {
            now += 0.15
            let route: KeyRoute = scalar == "⌫" ? .backspace : .character(scalar)
            let before = terminal.inserts
            terminal.inKey = true
            let outcome = composer.handle(route, time: now, engine: &engine, client: terminal)
            terminal.inKey = false
            #expect(terminal.inserts - before <= 1)
            if !outcome.consumed { terminal.defaultAction(route) }
            if let deferred = outcome.deferredText { sent.append(deferred) }
        }
        #expect(composer.detector.send == .afterKey)
        #expect(composer.eraseMode == .off)
        #expect(sent.isEmpty)
        #expect(String(terminal.line).hasPrefix("toôis vieetj ddi"))
    }

    /// Keys typed in a Ghostty-like terminal (`FakeGhostty`), 150 ms apart; the deferred
    /// text (after the key) goes in as Ghostty takes it.
    static func ghostty(_ keys: String, composer: inout InPlaceComposer, engine: inout VietEngine,
                        terminal: FakeGhostty, now: inout TimeInterval) {
        for scalar in keys.unicodeScalars {
            now += 0.15
            let route: KeyRoute = scalar == "⌫" ? .backspace : .character(scalar)
            terminal.inKey = true
            let outcome = composer.handle(route, time: now, engine: &engine, client: terminal)
            terminal.inKey = false
            if !outcome.consumed { terminal.defaultAction(route) }
            if let deferred = outcome.deferredText { terminal.send(deferred) }
        }
    }

    @Test("a native verdict that comes after the field was told apart: DEL after the key from the next word")
    func lateNativeVerdict() {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        let terminal = FakeGhostty()
        var now: TimeInterval = 0
        // Told apart at the second e of "vieetj" while the verdict is still being read.
        Self.ghostty("toois vieetj ddi hoc", composer: &composer, engine: &engine, terminal: terminal, now: &now)
        #expect(composer.detector.send == .afterKey)
        #expect(composer.eraseMode == .off)
        composer.afterKeyAllowed = true  // the verdict is back, in the middle of "hoc"
        Self.ghostty("j", composer: &composer, engine: &engine, terminal: terminal, now: &now)
        #expect(composer.eraseMode == .off)  // never inside a word
        Self.ghostty(" nhaf dd ", composer: &composer, engine: &engine, terminal: terminal, now: &now)
        #expect(composer.eraseMode == .afterKey)
        #expect(String(terminal.line).hasSuffix(" nhà đ "))
    }

    @Test("a web verdict never turns DEL after the key on")
    func webVerdictNever() {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        let terminal = FakeGhostty()
        var now: TimeInterval = 0
        Self.ghostty("toois vieetj ddi hoc", composer: &composer, engine: &engine, terminal: terminal, now: &now)
        composer.afterKeyAllowed = false  // the verdict: web (or unknown)
        Self.ghostty("j nhaf dd ", composer: &composer, engine: &engine, terminal: terminal, now: &now)
        #expect(composer.detector.send == .afterKey)
        #expect(composer.eraseMode == .off)
        #expect(!composer.afterKeyPending)
        // A native verdict for a client since replaced (activation) has nothing to start.
        composer.activate()
        composer.afterKeyAllowed = true
        #expect(!composer.afterKeyPending)
    }

    @Test("Xcode-like: WebKit loaded from a framework in Contents/SharedFrameworks")
    func sharedFrameworks() throws {
        let url = try Self.bundle(["SharedFrameworks/Editor.framework/Versions/A/Editor": Self.machO(Self.system + [Self.webKit]),
                                   "SharedFrameworks/Tools.framework/Versions/A/Tools": Self.machO(Self.system)])
        defer { Self.remove(url) }
        #expect(WebHost.classify(bundle: url) == .web(engine: "webkit"))
        let renderer = try Self.bundle(["SharedFrameworks/App Helper (Renderer).app": nil])
        defer { Self.remove(renderer) }
        #expect(WebHost.classify(bundle: renderer) == .web(engine: "chromium"))
        let plain = try Self.bundle(["SharedFrameworks/Tools.framework/Tools": Self.machO(Self.system)])
        defer { Self.remove(plain) }
        #expect(WebHost.classify(bundle: plain) == .native)
    }

    @Test("only regular files are read: a FIFO in the bundle does not block, a symlink to a file is read",
          arguments: ["Info.plist", "MacOS/App", "Frameworks/X.framework/X"])
    func fifo(path: String) throws {
        let url = try Self.bundle(path == "Frameworks/X.framework/X" ? ["Frameworks/X.framework/Versions/A/X": Self.machO(Self.system)] : [:])
        defer { Self.remove(url) }
        let target = url.appendingPathComponent("Contents/\(path)")
        try? FileManager.default.removeItem(at: target)
        try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
        #expect(mkfifo(target.path, 0o644) == 0)
        let verdict = WebHost.classify(bundle: url)  // returns: a blocking open would hang here
        #expect(verdict.blockedWord == "unknown")
        #expect(WebHost.openRegularFile(target) == nil)
        // The usual framework layout: X.framework/X a symlink to Versions/A/X.
        let linked = try Self.bundle(["Frameworks/X.framework/Versions/A/X": Self.machO(Self.system + [Self.webKit])])
        defer { Self.remove(linked) }
        try FileManager.default.createSymbolicLink(atPath: linked.appendingPathComponent("Contents/Frameworks/X.framework/X").path,
                                                   withDestinationPath: "Versions/A/X")
        #expect(WebHost.classify(bundle: linked) == .web(engine: "webkit"))
    }

    @Test("a fix queued for a client session is dropped once the session changed (ClientEpoch)")
    func clientEpoch() {
        var epoch = ClientEpoch()
        let atKey = epoch.value
        #expect(epoch.isCurrent(atKey))
        epoch.advance()  // client change, deactivation, close or a new activation
        #expect(!epoch.isCurrent(atKey))
        #expect(epoch.isCurrent(epoch.value))
    }

    // MARK: Read off the main thread (WebHostGate)

    @Test("until the verdict for the current client is back, DEL after the key stays blocked")
    func pending() {
        var gate = WebHostGate()
        #expect(!gate.allowsAfterKey)
        _ = gate.request()
        #expect(!gate.allowsAfterKey)
    }

    @Test("a verdict that comes back late for an earlier client does not apply to the new one")
    func lateVerdict() {
        var gate = WebHostGate()
        let ghostty = gate.request()           // activation in Ghostty
        let code = gate.request()              // client change to VS Code before the read is back
        let lateGhostty = gate.deliver(.native, for: ghostty)
        #expect(!lateGhostty)
        #expect(!gate.allowsAfterKey)
        let current = gate.deliver(.web(engine: "chromium"), for: code)
        #expect(current)
        #expect(!gate.allowsAfterKey)
        // And the other way: the late web verdict does not undo the current native one.
        let first = gate.request(), second = gate.request()
        let native = gate.deliver(.native, for: second)
        #expect(native)
        let lateWeb = gate.deliver(.web(engine: "chromium"), for: first)
        #expect(!lateWeb)
        #expect(gate.allowsAfterKey)
        // A new request blocks again until its verdict.
        _ = gate.request()
        #expect(!gate.allowsAfterKey)
    }

    @Test("WebHost.read answers on the main queue, off it for the reading")
    func readsInBackground() async throws {
        let url = try Self.bundle()
        defer { Self.remove(url) }
        let (verdict, mainThread) = await withCheckedContinuation { (done: CheckedContinuation<(WebHost.Verdict, Bool), Never>) in
            WebHost.read(bundle: url) { verdict, _ in done.resume(returning: (verdict, Thread.isMainThread)) }
        }
        #expect(verdict == .native)
        #expect(mainThread)
        let none = await withCheckedContinuation { (done: CheckedContinuation<WebHost.Verdict, Never>) in
            WebHost.read(bundle: nil) { verdict, _ in done.resume(returning: verdict) }
        }
        #expect(!none.allowsAfterKey)
    }

    // MARK: Fuzz (D18)

    /// The Mach-O reader on hostile files: random bytes, and valid thin and universal files
    /// cut short, with bytes changed, and with counts, sizes and offsets far out of range.
    /// Never traps or hangs; the answer is nil or a list of names (fixed seed).
    @Test("fuzz: loadedLibraries never traps on broken Mach-O files")
    func fuzz() throws {
        var random = SplitMix(0xD43_F022)
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("WebHostFuzz-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("bin")
        var runs = 0, answered = 0

        func check(_ data: Data) throws {
            try data.write(to: file)
            runs += 1
            if let names = WebHost.loadedLibraries(machO: file) {
                answered += 1
                #expect(names.count <= 16 * 10_000)
                #expect(!names.contains { $0.utf8.contains(0) })
            }
        }
        func put(_ value: UInt32, at offset: Int, in data: inout Data, bigEndian: Bool = false) {
            guard offset + 4 <= data.count else { return }
            let bytes = bigEndian ? Self.be(value) : Self.le(value)
            data.replaceSubrange(offset..<(offset + 4), with: bytes)
        }
        let thin = Self.machO(Self.system + [Self.webKit, "@rpath/X.framework/X"])
        let universal = Self.fat([Self.machO(Self.system), thin])
        let extremes: [UInt32] = [0, 1, 7, 8, 11, 12, 0x7FFF_FFFF, 0x8000_0000, 0xFFFF_FFF0, 0xFFFF_FFFF]

        // Random bytes, with and without a Mach-O or universal magic in front.
        let magics: [Data] = [Data(), Self.le(0xFEED_FACF), Self.le(0xFEED_FACE),
                              Self.be(0xCAFE_BABE), Self.be(0xCAFE_BABF)]
        for _ in 0..<1500 {
            let count = Int(random.next() % 300)
            let bytes = (0..<count).map { _ in UInt8(truncatingIfNeeded: random.next()) }
            try check(magics[Int(random.next() % UInt64(magics.count))] + Data(bytes))
        }
        // Valid files cut at every length.
        for source in [thin, universal.prefix(4096 + thin.count + 64)] {
            for length in 0..<min(source.count, 400) { try check(source.prefix(length)) }
        }
        // Valid files with random bytes changed.
        for _ in 0..<1000 {
            var data = random.next() % 2 == 0 ? thin : universal
            for _ in 0..<(1 + random.next() % 4) {
                let at = Int(random.next() % UInt64(min(data.count, 4096 + 200)))
                data[at] = UInt8(truncatingIfNeeded: random.next())
            }
            try check(data)
        }
        // Thin: ncmds, sizeofcmds, cmdsize, name offset far out of range.
        for value in extremes {
            for offset in [16, 20, 32 + 4, 32 + 8] {
                var data = thin
                put(value, at: offset, in: &data)
                try check(data)
            }
        }
        // Universal: slice count, slice offset (32- and 64-bit tables) far out of range.
        for value in extremes {
            for offset in [4, 8 + 8] {
                var data = universal
                put(value, at: offset, in: &data, bigEndian: true)
                try check(data)
            }
            var wide = Self.be(0xCAFE_BABF) + Self.be(1) + Self.be(0x0100_000C) + Self.be(0)
            wide += Self.be(value) + Self.be(value) + Self.be(0) + Self.be(64) + Self.be(12) + Self.be(0)
            try check(wide + thin)
        }
        #expect(runs > 3000)
        // The untouched files still read.
        try check(thin)
        #expect(WebHost.loadedLibraries(machO: file) == Self.system + [Self.webKit, "@rpath/X.framework/X"])
        print("fuzz: \(runs) files, \(answered) answered with a list")
    }
}
