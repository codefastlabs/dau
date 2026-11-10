import Foundation
import Testing
@testable import SnapshotSettings

// The owner copy of the installed input method (D37): which bundle it is, when the running
// copy is it, the code hash reader behind both, and `Dau --reconcile-input-method`. The
// folders are temp folders and the bundles are made here; no test reads /Applications,
// ~/Applications or ~/Library/Input Methods.

private let appID = "com.codefastlabs.dau"

/// A temp folder standing for /Applications and ~/Applications, with fake Dấu bundles whose
/// "code hashes" are a file inside them (`Contents/code`, one "<architecture>=<hash>" per line).
@MainActor
private struct Folders {
    let root: URL
    let applications: URL
    let userApplications: URL

    init() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("dau-owner-\(UUID().uuidString)")
        applications = root.appendingPathComponent("Applications")
        userApplications = root.appendingPathComponent("Users/u/Applications")
        try FileManager.default.createDirectory(at: applications, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userApplications, withIntermediateDirectories: true)
    }

    func remove() { try? FileManager.default.removeItem(at: root) }

    static let release: CodeHashes = ["arm64": Data([1, 1]), "x86_64": Data([2, 2])]

    @discardableResult
    func makeApp(_ name: String = "Dấu.app", in folder: URL, bundleID: String = appID,
                 code: CodeHashes? = Folders.release) throws -> URL {
        let url = folder.appendingPathComponent(name)
        let contents = url.appendingPathComponent("Contents")
        try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        try PropertyListSerialization.data(fromPropertyList: ["CFBundleIdentifier": bundleID], format: .xml, options: 0)
            .write(to: contents.appendingPathComponent("Info.plist"))
        if let code {
            let lines = code.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value.map { String($0) }.joined(separator: ","))" }
            try Data(lines.joined(separator: "\n").utf8).write(to: contents.appendingPathComponent("code"))
        }
        return url
    }

    /// Reads the fake hashes back; nil when the bundle has none (unsigned).
    static func hashes(_ url: URL) -> CodeHashes? {
        guard let text = try? String(contentsOf: url.appendingPathComponent("Contents/code"), encoding: .utf8) else { return nil }
        var result: CodeHashes = [:]
        for line in text.split(separator: "\n") {
            let parts = line.split(separator: "=")
            guard parts.count == 2 else { return nil }
            result[String(parts[0])] = Data(parts[1].split(separator: ",").compactMap { UInt8($0) })
        }
        return result
    }

    /// The check for a running copy with `running` as its hashes. The running copy has no
    /// path here at all: where it runs from is never part of the answer.
    func owner(running: CodeHashes? = Folders.release) -> ApplicationsOwnerCopy {
        ApplicationsOwnerCopy(bundleID: appID, directories: [applications, userApplications],
                              runningHashes: { running }, hashes: Folders.hashes)
    }
}

@MainActor
@Suite("Owner copy (D37)")
struct OwnerCopyTests {
    /// File paths to compare (a listed folder's URLs carry a trailing slash).
    func paths(_ urls: [URL]) -> [String] { urls.map { $0.resolvingSymlinksInPath().path } }

    @Test("the copy in /Applications is the owner; the running copy is it when the hashes match")
    func inApplications() throws {
        let folders = try Folders()
        defer { folders.remove() }
        let app = try folders.makeApp(in: folders.applications)
        #expect(paths(folders.owner().candidates()) == paths([app]))
        #expect(folders.owner().runningCopyIsOwner)
        // Another build of Dấu running (a disk image, Downloads, a build folder).
        #expect(!folders.owner(running: ["arm64": Data([9]), "x86_64": Data([9])]).runningCopyIsOwner)
    }

    @Test("only in ~/Applications: that copy is the owner")
    func inUserApplications() throws {
        let folders = try Folders()
        defer { folders.remove() }
        let app = try folders.makeApp(in: folders.userApplications)
        #expect(paths(folders.owner().candidates()) == paths([app]))
        #expect(folders.owner().runningCopyIsOwner)
    }

    @Test("in both: /Applications decides, the copy in ~/Applications is not looked at")
    func inBoth() throws {
        let folders = try Folders()
        defer { folders.remove() }
        let other: CodeHashes = ["arm64": Data([7]), "x86_64": Data([8])]
        let system = try folders.makeApp(in: folders.applications, code: other)
        try folders.makeApp(in: folders.userApplications)
        #expect(paths(folders.owner().candidates()) == paths([system]))
        // The running copy equals the one in ~/Applications only: not the owner.
        #expect(!folders.owner().runningCopyIsOwner)
        #expect(folders.owner(running: other).runningCopyIsOwner)
    }

    @Test("in neither, or the folders do not exist: no owner copy")
    func nowhere() throws {
        let folders = try Folders()
        defer { folders.remove() }
        #expect(folders.owner().candidates().isEmpty)
        #expect(!folders.owner().runningCopyIsOwner)
        folders.remove()
        #expect(!folders.owner().runningCopyIsOwner)
    }

    @Test("every architecture must match: one that differs, one missing, one more → not the owner")
    func everyArchitecture() throws {
        let folders = try Folders()
        defer { folders.remove() }
        try folders.makeApp(in: folders.applications)
        #expect(!folders.owner(running: ["arm64": Data([1, 1]), "x86_64": Data([2, 3])]).runningCopyIsOwner)
        #expect(!folders.owner(running: ["arm64": Data([1, 1])]).runningCopyIsOwner)
        #expect(!folders.owner(running: ["arm64": Data([1, 1]), "x86_64": Data([2, 2]), "arm64e": Data([4])]).runningCopyIsOwner)
        #expect(CodeSignature.sameCode(Folders.release, Folders.release))
        // Nothing to compare proves nothing.
        #expect(!CodeSignature.sameCode([:], [:]))
    }

    @Test("found by bundle ID, not by file name; only directly inside the folder; a link is not the bundle")
    func byBundleID() throws {
        let folders = try Folders()
        defer { folders.remove() }
        // Another app that happens to be named like Dấu, a copy of Dấu one level down, and
        // a link to a copy elsewhere: none is the owner copy.
        try folders.makeApp("Dấu.app", in: folders.applications, bundleID: "com.example.other")
        try folders.makeApp(in: folders.applications.appendingPathComponent("Utilities"))
        let elsewhere = try folders.makeApp(in: folders.root.appendingPathComponent("Downloads"))
        try FileManager.default.createSymbolicLink(at: folders.applications.appendingPathComponent("Link.app"),
                                                   withDestinationURL: elsewhere)
        #expect(folders.owner().candidates().isEmpty)
        #expect(!folders.owner().runningCopyIsOwner)
        // Renamed by the user: still found, in ~/Applications since /Applications has none.
        let renamed = try folders.makeApp("Bộ gõ của tôi.app", in: folders.userApplications)
        #expect(paths(folders.owner().candidates()) == paths([renamed]))
        #expect(folders.owner().runningCopyIsOwner)
    }

    @Test("hashes that cannot be read (not signed) prove nothing: not the owner")
    func unreadable() throws {
        let folders = try Folders()
        defer { folders.remove() }
        try folders.makeApp(in: folders.applications)
        #expect(!folders.owner(running: nil).runningCopyIsOwner)
        let unsigned = try Folders()
        defer { unsigned.remove() }
        try unsigned.makeApp(in: unsigned.applications, code: nil)
        #expect(!unsigned.owner().runningCopyIsOwner)
        // No bundle ID to look for (the running copy has none): no owner copy.
        let noID = ApplicationsOwnerCopy(bundleID: "", directories: [folders.applications],
                                         runningHashes: { Folders.release }, hashes: Folders.hashes)
        #expect(!noID.runningCopyIsOwner)
    }

    @Test("the standard folders are /Applications, then Applications in the home folder")
    func standardFolders() {
        let paths = ApplicationsOwnerCopy.standardDirectories.map(\.path)
        #expect(paths == ["/Applications", FileManager.default.homeDirectoryForCurrentUser.path + "/Applications"])
    }
}

@Suite("Code hashes of every architecture (D37)")
struct CodeHashTests {
    @Test("Mach-O headers: a universal file lists every slice, a thin file is one; anything else is unreadable")
    func slices() {
        func bigEndian(_ words: [UInt32]) -> Data {
            Data(words.flatMap { [UInt8($0 >> 24), UInt8($0 >> 16 & 0xFF), UInt8($0 >> 8 & 0xFF), UInt8($0 & 0xFF)] })
        }
        let arm64: UInt32 = 0x0100_000C, x86_64: UInt32 = 0x0100_0007
        // fat_header + two fat_arch (cputype, cpusubtype, offset, size, align).
        let fat = bigEndian([0xCAFE_BABE, 2, x86_64, 3, 0x4000, 0x100, 14, arm64, 0, 0x8000, 0x100, 14])
        #expect(MachOSlices.parse(fat) == [.init(cpuType: 0x0100_0007, cpuSubtype: 3), .init(cpuType: 0x0100_000C, cpuSubtype: 0)])
        // fat_arch_64 entries are longer (64-bit offset and size, align, reserved).
        let fat64 = bigEndian([0xCAFE_BABF, 2, x86_64, 3, 0, 0x4000, 0, 0x100, 14, 0, arm64, 2, 0, 0x8000, 0, 0x100, 14, 0])
        #expect(MachOSlices.parse(fat64) == [.init(cpuType: 0x0100_0007, cpuSubtype: 3), .init(cpuType: 0x0100_000C, cpuSubtype: 2)])
        // mach_header_64, little-endian: magic, cputype, cpusubtype.
        let thin = Data([0xCF, 0xFA, 0xED, 0xFE, 0x0C, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00])
        #expect(MachOSlices.parse(thin) == [.init(cpuType: 0x0100_000C, cpuSubtype: 0)])
        #expect(MachOSlices.parse(Data("#!/bin/sh\n".utf8)) == nil)
        #expect(MachOSlices.parse(Data()) == nil)
        // A header cut short, or a slice count that cannot be true.
        #expect(MachOSlices.parse(fat.prefix(30)) == nil)
        #expect(MachOSlices.parse(bigEndian([0xCAFE_BABE, 0])) == nil)
        #expect(MachOSlices.parse(bigEndian([0xCAFE_BABE, 5000])) == nil)
    }

    /// Runs `codesign` on a bundle made here (ad-hoc: no identity, no keychain).
    func sign(_ bundle: URL, identifier: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        process.arguments = ["--force", "--sign", "-", "--identifier", identifier, bundle.path]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()
        try #require(process.terminationStatus == 0)
    }

    @Test("real signatures: one hash per slice of a universal bundle; the copy the installer makes equals the embedded bundle; another signature differs and is replaced")
    @MainActor
    func installedCopyEqualsEmbedded() throws {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent("dau-hashes-\(UUID().uuidString)")
        defer { try? fm.removeItem(at: root) }
        // A stand-in for the input method: a bundle around a universal system binary,
        // signed ad hoc.
        let embedded = root.appendingPathComponent("App/DauInputMethod.app")
        let macOS = embedded.appendingPathComponent("Contents/MacOS")
        try fm.createDirectory(at: macOS, withIntermediateDirectories: true)
        try fm.copyItem(at: URL(fileURLWithPath: "/usr/bin/true"), to: macOS.appendingPathComponent("DauInputMethod"))
        let info: [String: Any] = ["CFBundleIdentifier": "com.example.dau-test.inputmethod", "CFBundleExecutable": "DauInputMethod",
                                   "CFBundleVersion": "1", "CFBundlePackageType": "APPL"]
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
            .write(to: embedded.appendingPathComponent("Contents/Info.plist"))
        try sign(embedded, identifier: "com.example.dau-test.inputmethod")

        let slices = try #require(MachOSlices.read(bundle: embedded))
        try #require(slices.count >= 2, "/usr/bin/true is universal")
        let hashes = try #require(CodeSignature.codeHashes(of: embedded))
        #expect(hashes.count == slices.count)
        #expect(Set(hashes.values).count == slices.count)   // each slice has its own hash
        #expect(hashes.values.allSatisfy { $0.count == 20 })

        // Not a bundle, and a bundle that is not signed: unreadable.
        #expect(CodeSignature.codeHashes(of: root.appendingPathComponent("missing.app")) == nil)

        var files = InputMethodBundleFiles(embeddedURL: embedded, directory: root.appendingPathComponent("Input Methods"))
        files.verify = { _ in true }   // ad-hoc signed: the team check is not what this test is about
        #expect(!files.installedMatchesEmbedded)   // nothing installed
        try files.installEmbedded()
        #expect(files.installedMatchesEmbedded)
        #expect(CodeSignature.codeHashes(of: files.installedURL) == hashes)

        // The installed copy gets another signature (same build number): it differs at
        // every architecture, and installing again makes it equal.
        try sign(files.installedURL, identifier: "com.example.dau-test.other")
        let other = try #require(CodeSignature.codeHashes(of: files.installedURL))
        #expect(Set(other.keys) == Set(hashes.keys))
        #expect(Set(other.values).isDisjoint(with: Set(hashes.values)))
        #expect(!files.installedMatchesEmbedded)
        #expect(files.installed?.version == files.embedded?.version)
        try files.installEmbedded()
        #expect(files.installedMatchesEmbedded)
    }
}

@MainActor
@Suite("Dau --reconcile-input-method")
struct ReconcileCommandTests {
    @Test("the flag is read from the arguments, not from the program's own path")
    func arguments() {
        #expect(ReconcileCommand.isRequested(["/Applications/Dau.app/Contents/MacOS/Dau", "--reconcile-input-method"]))
        #expect(ReconcileCommand.isRequested(["Dau", "-AppleLanguages", "(en)", "--reconcile-input-method"]))
        #expect(!ReconcileCommand.isRequested(["Dau"]))
        #expect(!ReconcileCommand.isRequested(["--reconcile-input-method"]))
        #expect(!ReconcileCommand.isRequested(["Dau", "--reconcile"]))
        #expect(!ReconcileCommand.isRequested([]))
    }

    @Test("every outcome has its own exit status and one line that starts with its word")
    func reports() {
        struct Disk: Error {}
        let cases: [(Result<ReconcileOutcome, Error>, ReconcileCommand.Status, Int32)] = [
            (.success(.alreadyCurrent), .alreadyCurrent, 0),
            (.failure(InputMethodInstallerError.invalidSignature), .failed, 1),
            (.failure(Disk()), .failed, 1),
            (.success(.replaced), .replaced, 3),
            (.success(.notInstalled), .notInstalled, 4),
            (.success(.notOwnerCopy), .notOwnerCopy, 5),
            (.success(.badSignature), .badSignature, 6),
            (.success(.skipped("bundle ID com.example.other\nsecond line")), .skipped, 7),
        ]
        for (result, status, code) in cases {
            let report = ReconcileCommand.report(result)
            #expect(report.status == status)
            #expect(report.status.rawValue == code)
            #expect(report.line.hasPrefix("reconcile-input-method: \(status.word): "))
            #expect(!report.line.contains("\n"))
        }
        let statuses = ReconcileCommand.Status.allCases
        #expect(Set(statuses.map(\.rawValue)).count == statuses.count)
        #expect(Set(statuses.map(\.word)).count == statuses.count)
        // 2 stays free for a command line that cannot be read.
        #expect(!statuses.map(\.rawValue).contains(2))
    }

    @Test("the command runs the installer's reconcile, once, and reports what it did")
    func run() async {
        let notOwner = FakeInputMethodInstaller(.enabled)
        notOwner.ownerCopy = false
        #expect(await ReconcileCommand.run(notOwner).status == .notOwnerCopy)
        #expect(notOwner.calls == ["reconcile"])

        let replaced = FakeInputMethodInstaller(.enabled)
        replaced.reconcileOutcome = .replaced
        #expect(await ReconcileCommand.run(replaced).status == .replaced)
        #expect(await ReconcileCommand.run(FakeInputMethodInstaller(.selected)).status == .alreadyCurrent)
        #expect(await ReconcileCommand.run(FakeInputMethodInstaller(.notInstalled)).status == .notInstalled)
        let bad = FakeInputMethodInstaller(.enabled)
        bad.genuine = false
        #expect(await ReconcileCommand.run(bad).status == .badSignature)
        #expect(await ReconcileCommand.run(FakeInputMethodInstaller(.enabled, failure: .unavailable)).status == .failed)
    }

    @Test("on the real installer's rule: the same outcomes through SystemInputMethodInstaller")
    func runOnRig() async {
        let rig = Rig(installed: InputMethodBundleInfo(bundleID: "com.codefastlabs.dau.inputmethod.Dau", version: "1",
                                                       shortVersion: nil, modeIDs: []))
        #expect(await ReconcileCommand.run(rig.installer).status == .replaced)
        #expect(await ReconcileCommand.run(rig.installer).status == .alreadyCurrent)
        rig.files.genuine = false
        #expect(await ReconcileCommand.run(rig.installer).status == .badSignature)
        rig.owner.runningCopyIsOwner = false
        #expect(await ReconcileCommand.run(rig.installer).status == .notOwnerCopy)
        #expect(rig.files.log == ["copy"])
    }
}
