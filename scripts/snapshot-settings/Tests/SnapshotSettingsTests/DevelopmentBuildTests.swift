import Foundation
import Testing
@testable import SnapshotSettings

// D25: a development build's Updates & Support card names its configuration and the
// installed input method's build (commit · Debug/Release). Debug is read from the
// get-task-allow entitlement, as scripts/dev/dau-version.sh does; without a readable
// signature nothing is claimed (N5). The bundles are minimal .app folders around a copy of
// /usr/bin/true, signed ad hoc here (or not signed).

private enum Signing { case none, release, debug }

/// A temp Fake.app: Info.plist, Contents/MacOS/Fake (a copy of /usr/bin/true),
/// Contents/Resources/BuildCommit.txt holding `commit` when given, signed as `signing` says.
private func fakeBundle(_ signing: Signing, commit: String?, version: String? = nil) throws -> URL {
    let folder = FileManager.default.temporaryDirectory.appendingPathComponent("dau-build-\(UUID().uuidString)")
    let app = folder.appendingPathComponent("Fake.app")
    let contents = app.appendingPathComponent("Contents")
    try FileManager.default.createDirectory(at: contents.appendingPathComponent("MacOS"), withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: contents.appendingPathComponent("Resources"), withIntermediateDirectories: true)
    var plist: [String: Any] = ["CFBundleIdentifier": "test.fake", "CFBundleExecutable": "Fake", "CFBundlePackageType": "APPL"]
    if let version { plist["CFBundleShortVersionString"] = version }
    try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        .write(to: contents.appendingPathComponent("Info.plist"))
    try FileManager.default.copyItem(at: URL(fileURLWithPath: "/usr/bin/true"),
                                     to: contents.appendingPathComponent("MacOS/Fake"))
    if let commit {
        try commit.write(to: contents.appendingPathComponent("Resources/BuildCommit.txt"), atomically: true, encoding: .utf8)
    }
    // /usr/bin/true carries Apple's signature: strip it, so `.none` is really unsigned.
    try run("/usr/bin/codesign", ["--remove-signature", contents.appendingPathComponent("MacOS/Fake").path])
    guard signing != .none else { return app }
    var arguments = ["--force", "--sign", "-"]
    if signing == .debug {
        let ent = folder.appendingPathComponent("ent.plist")
        try PropertyListSerialization.data(fromPropertyList: ["com.apple.security.get-task-allow": true], format: .xml, options: 0)
            .write(to: ent)
        arguments += ["--entitlements", ent.path]
    }
    try run("/usr/bin/codesign", arguments + [app.path])
    return app
}

private func run(_ tool: String, _ arguments: [String]) throws {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: tool)
    p.arguments = arguments
    p.standardError = FileHandle.nullDevice
    try p.run()
    p.waitUntilExit()
    #expect(p.terminationStatus == 0, "\(tool) \(arguments)")
}

private func remove(_ apps: URL...) {
    for app in apps { try? FileManager.default.removeItem(at: app.deletingLastPathComponent()) }
}

@Suite("Development build label (D25)")
struct DevelopmentBuildTests {
    @Test("get-task-allow in the signature means Debug, its absence Release, no signature unknown")
    func getTaskAllow() throws {
        let debug = try fakeBundle(.debug, commit: nil)
        let release = try fakeBundle(.release, commit: nil)
        let unsigned = try fakeBundle(.none, commit: nil)
        defer { remove(debug, release, unsigned) }
        #expect(CodeSignature.hasGetTaskAllow(debug) == true)
        #expect(CodeSignature.hasGetTaskAllow(release) == false)
        #expect(CodeSignature.hasGetTaskAllow(unsigned) == nil)
        #expect(CodeSignature.hasGetTaskAllow(release.appendingPathComponent("missing")) == nil)
    }

    @Test("the installed input method line names only what it could read")
    func installedLine() throws {
        let debug = try fakeBundle(.debug, commit: "a1b2c3d")
        let release = try fakeBundle(.release, commit: nil)
        let unsigned = try fakeBundle(.none, commit: "a1b2c3d")
        let bare = try fakeBundle(.none, commit: nil, version: "1.0.0")
        let empty = try fakeBundle(.none, commit: nil)
        defer { remove(debug, release, unsigned, bare, empty) }
        // Neither commit nor signature: the bundle's version, else a dash, never a guess.
        #expect(AppVersion.installedInputMethodBuild(at: bare) == "1.0.0")
        #expect(AppVersion.installedInputMethodBuild(at: empty) == "–")
        #expect(AppVersion.stampedCommit(at: debug) == "a1b2c3d")
        #expect(AppVersion.stampedCommit(at: release) == nil)
        #expect(AppVersion.installedInputMethodBuild(at: debug) == "a1b2c3d · Debug")
        #expect(AppVersion.installedInputMethodBuild(at: release) == "Release")
        // No signature: the commit alone, never "Release" (N5).
        #expect(AppVersion.installedInputMethodBuild(at: unsigned) == "a1b2c3d")
        #expect(AppVersion.installedInputMethodBuild(at: debug.appendingPathComponent("missing")) == nil)
    }

    @Test("a development build's sidebar line ends with its configuration")
    func sidebarLine() {
        // swift test builds without DAU_OFFICIAL, in whichever configuration it was asked for.
        #if DEBUG
        let expected = "Debug"
        #else
        let expected = "Release"
        #endif
        #expect(AppVersion.developmentConfiguration == expected)
        #expect(AppVersion.sidebarLine == AppVersion.nameAndVersion + " · " + expected)
    }
}
