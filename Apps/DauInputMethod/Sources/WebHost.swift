import Foundation
import os

/// D43 (Ô bỏ qua vùng thay chữ): whether the client app may host web pages, read from its
/// bundle. DEL characters sent after the key (`InPlaceComposer.EraseMode.afterKey`) are
/// only for apps that are surely not: a web page can hold a terminal (xterm.js) and an
/// editor in one view, so one IMK client, and a click between them reaches no input
/// method (Chromium's `mouseEvent:`; `SharedViewTests`), so a DEL could reach the editor.
/// An xterm.js page whose `selectedRange` answers are all 0 is told apart like Ghostty
/// (`FakeXtermPage` with `markedLocation` NSNotFound). Anything not sure is `web`/
/// `unknown`, and both block: the worst case is a terminal replaced in place, as before D43.
///
/// Signals, from the bundles installed on a development machine (12/11/2026), by engine
/// (not by app, so an app that adds a web view later is still caught):
/// - Chromium (Chrome, Edge, Blisk, every Electron app, CEF): a `… Helper (Renderer).app`
///   under Contents/Frameworks (Electron: at its top; Chrome: in the framework's
///   Versions/<version>/Helpers), or an `Electron Framework.framework` or
///   `Chromium Embedded Framework.framework` there.
/// - Gecko (Firefox): Contents/MacOS/XUL (or libxul.dylib).
/// - WebKit (WKWebView apps, Tauri, Safari, Xcode): the main executable, or a framework or
///   dylib at the top of Contents/Frameworks or Contents/SharedFrameworks, loads
///   WebKit.framework or Safari.framework (Safari itself loads only the private
///   Safari.framework; Xcode: RenderedEditor.framework in SharedFrameworks).
///   Sparkle.framework is not counted: it loads WebKit for release notes shown in a
///   window of its own (another IMK client); Ghostty and TablePlus carry it.
/// Measured: Ghostty and Terminal load neither and carry none of the above.
///
/// Not covered (taken as native): WebKit or a web engine loaded with `dlopen`, or through
/// a system framework the app links (those show web content in views of their own), or
/// from an XPC service, plug-in or helper app of the bundle; a bundle framework nested
/// deeper than the top of Contents/Frameworks and Contents/SharedFrameworks (inside
/// another framework), or kept elsewhere in the bundle (Contents/Resources, Library);
/// a renderer helper outside the `Helpers` of a top-level framework.
///
/// Files are opened only if regular (`openRegularFile`), so a FIFO or device in a bundle
/// cannot block the read queue.
///
/// Reading another app's bundle from the input method's App Sandbox: the App Sandbox
/// profile (/System/Library/Sandbox/Profiles/application.sb, macOS 26) allows `file-read*`
/// on subpath "/Applications" and read-only access to "/System" (Terminal is in
/// /System/Applications). Apps elsewhere (~/Applications) are not readable: `unknown`.
enum WebHost {
    enum Verdict: Equatable, Sendable {
        /// None of the signals: DEL after the key allowed.
        case native
        /// A web engine (`engine`: chromium, gecko, webkit).
        case web(engine: String)
        /// The bundle could not be read or told apart (`why`, a fixed word for the log).
        case unknown(why: String)

        var allowsAfterKey: Bool { self == .native }

        /// The `blocked=` word of the D43 log, nil when not blocked.
        var blockedWord: String? {
            switch self {
            case .native: nil
            case .web: "web"
            case .unknown: "unknown"
            }
        }
    }

    /// Reads `bundle` (an .app). Never throws; at most a few directory listings and the
    /// load commands of the main executable and of the top-level bundled frameworks
    /// (Contents/Frameworks, Contents/SharedFrameworks).
    static func classify(bundle: URL) -> Verdict {
        let fm = FileManager.default
        let contents = bundle.appendingPathComponent("Contents")
        guard let plist = readRegularFile(contents.appendingPathComponent("Info.plist"), limit: infoPlistLimit),
              let info = try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: Any],
              let executable = info["CFBundleExecutable"] as? String, !executable.isEmpty,
              !executable.contains("/") else {
            return .unknown(why: "info")
        }
        let macOS = contents.appendingPathComponent("MacOS")
        // Gecko.
        for name in ["XUL", "libxul.dylib"] where fm.fileExists(atPath: macOS.appendingPathComponent(name).path) {
            return .web(engine: "gecko")
        }
        let folders = frameworkFolders.map { contents.appendingPathComponent($0) }
        let listings = folders.map { (try? fm.contentsOfDirectory(atPath: $0.path)) ?? [] }
        // Chromium, by name at the top.
        for names in listings {
            for name in names where chromiumFrameworks.contains(name) || isRenderer(name) {
                return .web(engine: "chromium")
            }
        }
        // WebKit: the main executable.
        guard let main = loadedLibraries(machO: macOS.appendingPathComponent(executable)) else {
            return .unknown(why: "executable")
        }
        if main.contains(where: loadsWebKit) { return .web(engine: "webkit") }
        // WebKit: top-level bundled frameworks and dylibs.
        for (folder, names) in zip(folders, listings) {
            if let verdict = webKitFramework(in: folder, names: names) { return verdict }
        }
        // Chromium: a renderer helper deeper down (Chrome: framework/Versions/<v>/Helpers).
        for (folder, names) in zip(folders, listings) where hasRendererHelper(under: folder, frameworks: names) {
            return .web(engine: "chromium")
        }
        return .native
    }

    /// Bundle folders whose top-level frameworks and dylibs are read: Xcode keeps most of
    /// its own in SharedFrameworks (RenderedEditor.framework, DNTTransformer.framework load
    /// WebKit).
    static let frameworkFolders = ["Frameworks", "SharedFrameworks"]

    /// `.web(webkit)` if a top-level framework or dylib of `folder` (except Sparkle) loads
    /// WebKit, `.unknown` if one cannot be read, nil otherwise.
    private static func webKitFramework(in folder: URL, names: [String]) -> Verdict? {
        let fm = FileManager.default
        for name in names.sorted() where name != "Sparkle.framework" {
            let item = folder.appendingPathComponent(name)
            let binary: URL
            if name.hasSuffix(".framework") {
                let base = String(name.dropLast(".framework".count))
                let candidates = [item.appendingPathComponent(base),
                                  item.appendingPathComponent("Versions/Current/\(base)"),
                                  item.appendingPathComponent("Versions/A/\(base)")]
                guard let found = candidates.first(where: { fm.fileExists(atPath: $0.path) }) else { continue }
                binary = found
            } else if name.hasSuffix(".dylib") {
                binary = item
            } else {
                continue
            }
            guard let libraries = loadedLibraries(machO: binary) else { return .unknown(why: "framework") }
            if libraries.contains(where: loadsWebKit) { return .web(engine: "webkit") }
        }
        return nil
    }

    static let chromiumFrameworks: Set<String> = ["Electron Framework.framework",
                                                  "Chromium Embedded Framework.framework"]

    static func isRenderer(_ name: String) -> Bool {
        name.hasSuffix(" (Renderer).app")
    }

    static func loadsWebKit(_ path: String) -> Bool {
        path.contains("/WebKit.framework/") || path.contains("/Safari.framework/")
    }

    /// A renderer helper in the `Helpers` folder of a top-level framework, in any of its
    /// versions (Chrome, Edge, Blisk: `<name> Framework.framework/Versions/<version>/
    /// Helpers/<name> Helper (Renderer).app`). Listings only, no walk of the whole folder
    /// (Xcode's Frameworks holds a few hundred frameworks).
    private static func hasRendererHelper(under url: URL, frameworks: [String]) -> Bool {
        let fm = FileManager.default
        for name in frameworks where name.hasSuffix(".framework") {
            let framework = url.appendingPathComponent(name)
            let versions = framework.appendingPathComponent("Versions")
            var folders = [framework.appendingPathComponent("Helpers")]
            for version in (try? fm.contentsOfDirectory(atPath: versions.path)) ?? [] {
                folders.append(versions.appendingPathComponent(version).appendingPathComponent("Helpers"))
            }
            for folder in folders {
                if ((try? fm.contentsOfDirectory(atPath: folder.path)) ?? []).contains(where: isRenderer) { return true }
            }
        }
        return false
    }

    // MARK: Regular files only

    /// Info.plist files larger than this are not read (the largest seen is a few tens of KB).
    static let infoPlistLimit = 4 << 20

    /// Opens `url` for reading only if it is (or links to) a regular file: opened with
    /// O_NONBLOCK, then checked with `fstat` on the open descriptor, so a FIFO or a device
    /// planted in a bundle (D18) neither blocks the read queue nor is read.
    static func openRegularFile(_ url: URL) -> FileHandle? {
        let fd = open(url.path, O_RDONLY | O_NONBLOCK | O_CLOEXEC)
        guard fd >= 0 else { return nil }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFREG else {
            close(fd)
            return nil
        }
        return FileHandle(fileDescriptor: fd, closeOnDealloc: true)
    }

    /// The whole file, if regular and at most `limit` bytes.
    static func readRegularFile(_ url: URL, limit: Int) -> Data? {
        guard let file = openRegularFile(url) else { return nil }
        defer { try? file.close() }
        guard let data = try? file.read(upToCount: limit + 1), data.count <= limit else { return nil }
        return data
    }

    // MARK: Mach-O

    /// The install names a Mach-O file loads (LC_LOAD_DYLIB and its weak, re-export, lazy
    /// and upward forms), over every slice of a universal file; nil if the file cannot be
    /// read or is not Mach-O (<mach-o/loader.h>, <mach-o/fat.h>). Each slice's load
    /// commands (at most 8 MB) are read and dropped in turn; only the names are kept.
    static func loadedLibraries(machO url: URL) -> [String]? {
        guard let file = openRegularFile(url) else { return nil }
        defer { try? file.close() }
        guard let head = read(file, at: 0, count: 8), head.count == 8 else { return nil }
        let magicBE = head.uint32BE(0)
        if magicBE == 0xCAFE_BABE || magicBE == 0xCAFE_BABF {
            let wide = magicBE == 0xCAFE_BABF
            let count = Int(head.uint32BE(4))
            guard count > 0, count <= 16 else { return nil }  // also not a Java class file
            let entry = wide ? 32 : 20
            guard let table = read(file, at: 8, count: count * entry), table.count == count * entry else { return nil }
            var names: [String] = []
            for i in 0..<count {
                let base = i * entry
                let offset = wide ? table.uint64BE(base + 8) : UInt64(table.uint32BE(base + 8))
                guard let slice = thinLibraries(file, at: offset) else { return nil }
                names += slice
            }
            return names
        }
        return thinLibraries(file, at: 0)
    }

    private static func thinLibraries(_ file: FileHandle, at offset: UInt64) -> [String]? {
        // D18: a slice offset from the file is untrusted; `seek` converts to off_t (traps
        // above Int64.max) and `offset + headerSize` must not overflow.
        guard offset <= 1 << 40 else { return nil }
        guard let header = read(file, at: offset, count: 32), header.count == 32 else { return nil }
        let magic = header.uint32LE(0)
        let headerSize: UInt64
        switch magic {
        case 0xFEED_FACF: headerSize = 32
        case 0xFEED_FACE: headerSize = 28
        default: return nil
        }
        let ncmds = Int(header.uint32LE(16)), sizeofcmds = Int(header.uint32LE(20))
        guard sizeofcmds > 0, sizeofcmds <= 8 << 20, ncmds <= 10_000,
              let commands = read(file, at: offset + headerSize, count: sizeofcmds),
              commands.count == sizeofcmds else { return nil }
        let dylibCommands: Set<UInt32> = [0xC, 0x8000_0018, 0x8000_001F, 0x20, 0x8000_0023]
        var names: [String] = []
        var at = 0
        for _ in 0..<ncmds {
            guard at + 8 <= commands.count else { return nil }
            let cmd = commands.uint32LE(at), size = Int(commands.uint32LE(at + 4))
            guard size >= 8, at + size <= commands.count else { return nil }
            if dylibCommands.contains(cmd), size >= 12 {
                let nameOffset = Int(commands.uint32LE(at + 8))
                if nameOffset < size {
                    let bytes = commands[(commands.startIndex + at + nameOffset)..<(commands.startIndex + at + size)]
                    names.append(String(decoding: bytes.prefix { $0 != 0 }, as: UTF8.self))
                }
            }
            at += size
        }
        return names
    }

    private static func read(_ file: FileHandle, at offset: UInt64, count: Int) -> Data? {
        do {
            try file.seek(toOffset: offset)
            return try file.read(upToCount: count)
        } catch {
            return nil
        }
    }

    // MARK: Off the key path

    /// Reads bundles off the main thread: a first read takes up to ~30 ms (Xcode), and a
    /// client change can come with a key (`DauInputController.noteClient`).
    private static let queue = DispatchQueue(label: "WebHost", qos: .utility)

    /// `verdict(bundle:)` on `queue`, then `done` on the main queue with the verdict and
    /// the time the read took (ns). `bundle` nil (the app not found): `unknown` at once.
    static func read(bundle: URL?, done: @escaping @Sendable (Verdict, UInt64) -> Void) {
        queue.async {
            let start = DispatchTime.now().uptimeNanoseconds
            let verdict = bundle.map(Self.verdict(bundle:)) ?? .unknown(why: "not-running")
            let ns = DispatchTime.now().uptimeNanoseconds - start
            DispatchQueue.main.async { done(verdict, ns) }
        }
    }

    // MARK: Per process

    /// Verdicts already read in this process, by bundle path and the modification dates
    /// of its Info.plist and Contents/MacOS (an update changes them): one read per app
    /// version, at activation, never per key.
    private static let cache = OSAllocatedUnfairLock<[String: Verdict]>(initialState: [:])

    static func verdict(bundle: URL) -> Verdict {
        let key = cacheKey(bundle)
        if let key, let known = cache.withLock({ $0[key] }) { return known }
        let verdict = classify(bundle: bundle)
        if let key { cache.withLock { $0[key] = verdict } }
        return verdict
    }

    private static func cacheKey(_ bundle: URL) -> String? {
        let fm = FileManager.default
        let contents = bundle.appendingPathComponent("Contents")
        guard let plist = try? fm.attributesOfItem(atPath: contents.appendingPathComponent("Info.plist").path),
              let exec = try? fm.attributesOfItem(atPath: contents.appendingPathComponent("MacOS").path),
              let a = plist[.modificationDate] as? Date, let b = exec[.modificationDate] as? Date else { return nil }
        return "\(bundle.standardizedFileURL.path)|\(a.timeIntervalSince1970)|\(b.timeIntervalSince1970)"
    }
}

private extension Data {
    func uint32BE(_ at: Int) -> UInt32 {
        self[(startIndex + at)..<(startIndex + at + 4)].reduce(0) { $0 << 8 | UInt32($1) }
    }
    func uint32LE(_ at: Int) -> UInt32 {
        self[(startIndex + at)..<(startIndex + at + 4)].reversed().reduce(0) { $0 << 8 | UInt32($1) }
    }
    func uint64BE(_ at: Int) -> UInt64 {
        self[(startIndex + at)..<(startIndex + at + 8)].reduce(0) { $0 << 8 | UInt64($1) }
    }
}

/// D43: the verdict that applies to the current client, with reads that come back late.
/// Each request (activation, client change) starts a new generation and blocks DEL after
/// the key until the verdict of that generation is delivered; a verdict for an earlier
/// generation (a client since replaced) is dropped.
struct WebHostGate: Equatable {
    private(set) var generation = 0
    private(set) var verdict = WebHost.Verdict.unknown(why: "pending")

    var allowsAfterKey: Bool { verdict.allowsAfterKey }

    /// A new client to read: returns the generation its verdict must carry.
    mutating func request() -> Int {
        generation &+= 1
        verdict = .unknown(why: "pending")
        return generation
    }

    /// Returns whether `verdict` was taken (it is for the latest request).
    mutating func deliver(_ verdict: WebHost.Verdict, for generation: Int) -> Bool {
        guard generation == self.generation else { return false }
        self.verdict = verdict
        return true
    }
}
