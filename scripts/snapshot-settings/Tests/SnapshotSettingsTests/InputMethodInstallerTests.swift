import Foundation
import Testing
@testable import SnapshotSettings

// The installer's state machine (D14, D16, D37; docs/research/M5-INSTALL.md sections
// 2–4) on fake Text Input Sources, a fake process list and fake bundle files: the order
// of the system calls, read-backs, and failure paths. No test touches the real input
// sources or ~/Library/Input Methods; the file tests run in a temp folder.

private let imID = "com.codefastlabs.dau.inputmethod.Dau"
private let modeID = imID + ".vi"

/// One log shared by the fakes, to check the order of calls across them.
@MainActor final class Order { var log: [String] = [] }

/// Text Input Sources in memory. `log` records every call that changes something.
@MainActor
final class FakeTextInputSources: TextInputSources {
    struct Source { var entry: InputSourceEntry; var enabled: Bool }
    var all: [Source] = []
    var currentID: String?
    var log: [String] = []
    var order: Order?
    /// `enable` returns this status and changes nothing when false (the macOS 27.0
    /// report: noErr, mode still off).
    var enableTakesEffect = true
    /// Enabling the parent also stores the mode (macOS does; 8.1b).
    var enableCascadesToMode = true
    var enableStatus: OSStatus = noErr
    /// What `register` makes appear (nothing: the source is not listed until logout).
    var registerAdds: [Source] = []
    /// Stored-list reads, after `enable` is called, before macOS stores Dấu as enabled by itself (the user
    /// clicked Allow a bit later). nil: never.
    var storedAfterReads: Int?
    private var storedReads = 0
    private var enableCalled = false
    /// What macOS has stored as enabled (`com.apple.inputsources`). nil: follows the
    /// enabled flags. Set to model the T4 bug: TIS says off, the stored entries stay.
    var stored: Set<String>?
    /// The user clicks "–" in System Settings: Dấu's entries go, stored and listed.
    func userRemovesDau() {
        stored = []
        for i in all.indices where all[i].entry.bundleID == imID { all[i].enabled = false }
        if let currentID, all.first(where: { $0.entry.id == currentID })?.entry.bundleID == imID { self.currentID = nil }
    }

    func storedEnabledIDs(bundleID: String) -> Set<String> {
        if let storedAfterReads {
            guard enableCalled else { return [] }
            storedReads += 1
            return storedReads > storedAfterReads ? [imID, modeID] : []
        }
        guard let stored else {
            return Set(all.filter { $0.entry.bundleID == bundleID && $0.enabled }.map(\.entry.id))
        }
        return stored
    }

    static func dau(enabled: Bool = false) -> [Source] {
        [Source(entry: InputSourceEntry(id: imID, bundleID: imID, isMode: false, name: "Dấu"), enabled: enabled),
         Source(entry: InputSourceEntry(id: modeID, bundleID: imID, isMode: true, name: "Dấu – Tiếng Việt"), enabled: enabled)]
    }
    static let abc = Source(entry: InputSourceEntry(id: "com.apple.keylayout.ABC", bundleID: "com.apple.keylayout",
                                                    isMode: false, name: "ABC"), enabled: true)

    func register(_ url: URL) -> OSStatus {
        log.append("register"); order?.log.append("register")
        for s in registerAdds where !all.contains(where: { $0.entry.id == s.entry.id }) { all.append(s) }
        return noErr
    }

    func sources(bundleID: String, includeDisabled: Bool) -> [InputSourceEntry] {
        return all.filter { $0.entry.bundleID == bundleID && (includeDisabled || $0.enabled) }.map(\.entry)
    }

    func enable(_ id: String) -> OSStatus {
        enableCalled = true
        log.append("enable \(id)"); order?.log.append("enable \(id)")
        if enableTakesEffect, let i = all.firstIndex(where: { $0.entry.id == id }) { all[i].enabled = true }
        if enableTakesEffect, enableCascadesToMode, id == imID, let i = all.firstIndex(where: { $0.entry.id == modeID }) {
            all[i].enabled = true
        }
        return enableStatus
    }

    func select(_ id: String) -> OSStatus {
        log.append("select \(id)")
        currentID = id
        return noErr
    }

    func current() -> InputSourceEntry? {
        all.first { $0.entry.id == currentID }?.entry
    }

    func asciiKeyboard(excludingBundleID: String) -> InputSourceEntry? {
        all.first { $0.enabled && $0.entry.bundleID != excludingBundleID && $0.entry.id.contains("keylayout") }?.entry
    }
}

@MainActor
final class FakeProcesses: InputMethodProcesses {
    var running = false
    /// The process exits when asked (an input method that listens for the request).
    var honoursQuit = true
    var log: [String] = []

    func isRunning(bundleID: String) -> Bool { running }
    func requestQuit(bundleID: String) {
        log.append("requestQuit")
        if honoursQuit { running = false }
    }
    func forceQuit(bundleID: String) {
        log.append("forceQuit")
        running = false
    }
}

@MainActor
final class FakeSettings: SystemSettingsControl {
    var running = false
    /// Quits when asked (false: stays, as with an unsaved-changes sheet).
    var honoursTerminate = true
    var removedFiles = 2
    var log: [String] = []
    /// Shared with the fake sources to record the order of every call.
    var order: Order?

    var isRunning: Bool { running }
    func terminate() {
        log.append("terminate"); order?.log.append("terminate")
        if honoursTerminate { running = false }
    }
    func clearKeyboardCache() -> (removed: Int, failed: Int) {
        log.append("clearCache"); order?.log.append("clearCache")
        return (removedFiles, 0)
    }
}

@MainActor
final class FakeFiles: InputMethodFiles {
    var embedded: InputMethodBundleInfo? = InputMethodBundleInfo(bundleID: imID, version: "2", shortVersion: "0.2.0", modeIDs: [modeID])
    var installed: InputMethodBundleInfo?
    var installedURL = URL(fileURLWithPath: "/tmp/does-not-matter/DauInputMethod.app")
    var isInstalled: Bool { installed != nil }
    var genuine = true
    var installedIsGenuine: Bool { !isInstalled || genuine }
    var installError: InputMethodInstallerError?
    var trashError: InputMethodInstallerError?
    var log: [String] = []

    func installEmbedded() throws {
        log.append("copy")
        if let installError { throw installError }
        installed = embedded
        genuine = true
    }

    func moveInstalledToTrash() throws {
        log.append("trash")
        if let trashError { throw trashError }
        installed = nil
    }
}

@MainActor
struct Rig {
    let files = FakeFiles()
    let tis = FakeTextInputSources()
    let processes = FakeProcesses()
    let settings = FakeSettings()
    let installer: SystemInputMethodInstaller

    init(installed: InputMethodBundleInfo? = nil, sources: [FakeTextInputSources.Source] = [],
         removedByUserAfterPauses: Int? = nil) {
        files.installed = installed
        tis.all = sources + [FakeTextInputSources.abc]
        let counter = Counter(), keyboardOpened = Counter(), pauses = Counter()
        self.counter = counter
        self.keyboardOpened = keyboardOpened
        self.pauses = pauses
        let tis = self.tis
        installer = SystemInputMethodInstaller(files: files, sources: tis, processes: processes,
                                               settings: settings,
                                               deleteSharedData: { counter.value += 1; return true },
                                               openKeyboardSettings: { keyboardOpened.value += 1 },
                                               // Yields, so a loop that waits can be cancelled.
                                               pause: { _ in
                                                   pauses.value += 1
                                                   if pauses.value == removedByUserAfterPauses { tis.userRemovesDau() }
                                                   await Task.yield()
                                               })
    }

    let counter: Counter
    /// How many times Keyboard settings were opened.
    let keyboardOpened: Counter
    /// How many times the installer paused (polled).
    let pauses: Counter
    @MainActor final class Counter { var value = 0 }
}

@MainActor
@Suite("Input method installer (M5)")
struct InputMethodInstallerTests {
    let old = InputMethodBundleInfo(bundleID: imID, version: "1", shortVersion: "0.1.0", modeIDs: [modeID])

    // MARK: Status

    @Test("status: unknown without the bundle in the app, then installed, enabled, selected")
    func status() {
        let rig = Rig()
        rig.files.embedded = nil
        #expect(rig.installer.status() == .unknown)
        rig.files.embedded = old
        #expect(rig.installer.status() == .notInstalled)
        rig.files.installed = old
        rig.tis.all = FakeTextInputSources.dau()
        #expect(rig.installer.status() == .installed(version: "0.1.0"))
        // Only the parent on: the mode is what the user types with.
        rig.tis.all[0].enabled = true
        #expect(rig.installer.status() == .installed(version: "0.1.0"))
        rig.tis.all[1].enabled = true
        #expect(rig.installer.status() == .enabled)
        rig.tis.currentID = modeID
        #expect(rig.installer.status() == .selected)
    }

    // MARK: Install

    @Test("install: copy, stop the old process, register")
    func install() async throws {
        let rig = Rig()
        rig.processes.running = true
        try await rig.installer.install()
        #expect(rig.files.log == ["copy"])
        #expect(rig.processes.log == ["requestQuit"])
        #expect(rig.tis.log == ["register"])
        #expect(rig.files.isInstalled)
        // Installing never enables or selects anything (N4).
        #expect(!rig.tis.log.contains { $0.hasPrefix("enable") || $0.hasPrefix("select") })
    }

    @Test("install: a failed copy or a bad signature stops before registering")
    func installFails() async {
        for error in [InputMethodInstallerError.invalidSignature, .failed("disk full")] {
            let rig = Rig()
            rig.files.installError = error
            await #expect(throws: error) { try await rig.installer.install() }
            #expect(rig.tis.log.isEmpty)
        }
        let rig = Rig()
        rig.files.embedded = nil
        await #expect(throws: InputMethodInstallerError.unavailable) { try await rig.installer.install() }
        #expect(rig.files.log.isEmpty)
    }

    // MARK: Enable

    @Test("enable: register, clear the cache, quit System Settings, then enable the parent, read back from the stored entries")
    func enable() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau())
        rig.settings.running = true
        rig.tis.storedAfterReads = 3
        #expect(try await rig.installer.enable() == .enabled)
        #expect(rig.tis.log == ["register", "enable \(imID)"])
        #expect(rig.settings.log == ["clearCache", "terminate"])
        #expect(rig.tis.currentID == nil)   // never selected (N4)
    }

    @Test("enable: the order is register, clear cache, quit System Settings, enable the parent")
    func enableOrder() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau())
        rig.settings.running = true
        let order = Order()
        rig.settings.order = order
        rig.tis.order = order
        rig.tis.storedAfterReads = 1
        #expect(try await rig.installer.enable() == .enabled)
        #expect(order.log == ["register", "clearCache", "terminate", "enable \(imID)"])
        #expect(!rig.settings.running)
    }

    @Test("enable: TIS says enabled but nothing is stored → not enabled, status not enabled")
    func tisFlagIsNotEnough() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.tis.stored = []
        rig.installer.enableTimeout = .seconds(1)
        #expect(rig.installer.status() == .installed(version: "0.1.0"))
        rig.tis.enableTakesEffect = false
        #expect(try await rig.installer.enable() == .notEnabled)
        #expect(rig.installer.status() == .installed(version: "0.1.0"))
        // A stored mode is what makes it enabled, whatever TIS lists.
        rig.tis.all[1].enabled = false
        rig.tis.stored = [imID, modeID]
        #expect(rig.installer.status() == .enabled)
    }

    @Test("enable: noErr but nothing stored before the deadline is not enabled, never success")
    func enableReturnsOkButStillOff() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau())
        rig.tis.enableTakesEffect = false
        rig.tis.enableStatus = noErr
        rig.installer.enableTimeout = .seconds(2)
        #expect(try await rig.installer.enable() == .notEnabled)
        #expect(rig.installer.status() == .installed(version: "0.1.0"))
        // Undo still knows what was asked for, if macOS stores it later.
    }

    @Test("enable: stored during the wait (the user clicked Allow) counts")
    func enableLate() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau())
        rig.tis.enableTakesEffect = false
        rig.tis.storedAfterReads = 40
        #expect(try await rig.installer.enable() == .enabled)
    }

    @Test("enable: System Settings not running → nothing to quit; one that will not quit does not stop it")
    func enableSettings() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau())
        rig.tis.storedAfterReads = 1
        _ = try await rig.installer.enable()
        #expect(rig.settings.log == ["clearCache"])

        let stuck = Rig(installed: old, sources: FakeTextInputSources.dau())
        stuck.settings.running = true
        stuck.settings.honoursTerminate = false
        stuck.tis.storedAfterReads = 1
        #expect(try await stuck.installer.enable() == .enabled)
        #expect(stuck.settings.log == ["clearCache", "terminate"])
        #expect(stuck.tis.log.last == "enable \(imID)")
    }

    @Test("enable: not listed in TIS after registering → report a logout (D37), nothing else touched")
    func enableNotListed() async throws {
        let rig = Rig(installed: old)
        #expect(try await rig.installer.enable() == .notListed)
        #expect(rig.tis.log == ["register"])
        #expect(rig.settings.log.isEmpty)
        // Registering makes it appear (same session, same ID): enabled normally.
        let again = Rig(installed: old)
        again.tis.registerAdds = FakeTextInputSources.dau()
        again.tis.storedAfterReads = 1
        #expect(try await again.installer.enable() == .enabled)
        #expect(again.tis.log == ["register", "enable \(imID)"])
    }

    @Test("enable: already stored as enabled → no cache, no System Settings, no enable call")
    func enableAlreadyOn() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.settings.running = true
        #expect(try await rig.installer.enable() == .enabled)
        #expect(rig.tis.log == ["register"])
        #expect(rig.settings.log.isEmpty)
    }

    @Test("enable: not installed throws; nothing touched")
    func enableNotInstalled() async {
        let rig = Rig()
        await #expect(throws: InputMethodInstallerError.failed("not installed")) { try await rig.installer.enable() }
        #expect(rig.tis.log.isEmpty)
    }

    @Test("enable: cancelling during the wait throws CancellationError and reports nothing (Thử lại)")
    func enableCancelled() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau())
        rig.tis.enableTakesEffect = false
        let task = Task { try await rig.installer.enable() }
        await Task.yield()
        task.cancel()
        await #expect(throws: CancellationError.self) { try await task.value }
        // The user's pending Allow is not touched; a new run asks again.
        let again = Rig(installed: old, sources: FakeTextInputSources.dau())
        #expect(try await again.installer.enable() == .enabled)
    }

    // MARK: Upgrade

    @Test("upgrade: newer build → copy, stop the old process, register; IDs and enabled state kept")
    func upgrade() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.processes.running = true
        #expect(try await rig.installer.upgradeIfNeeded() == .upgraded(from: "1", to: "2"))
        #expect(rig.files.log == ["copy"])
        #expect(rig.processes.log == ["requestQuit"])
        #expect(rig.tis.log == ["register"])
        #expect(rig.installer.status() == .enabled)
    }

    @Test("upgrade: an input method that ignores the request is ended after the timeout")
    func upgradeForceQuit() async throws {
        let rig = Rig(installed: old)
        rig.processes.running = true
        rig.processes.honoursQuit = false
        _ = try await rig.installer.upgradeIfNeeded()
        #expect(rig.processes.log == ["requestQuit", "forceQuit"])
        #expect(!rig.processes.running)
    }

    @Test("upgrade: same or older version, nothing installed, another bundle ID → untouched")
    func noUpgrade() async throws {
        let same = Rig(installed: InputMethodBundleInfo(bundleID: imID, version: "2", shortVersion: nil, modeIDs: [modeID]))
        #expect(try await same.installer.upgradeIfNeeded() == .upToDate)
        let newer = Rig(installed: InputMethodBundleInfo(bundleID: imID, version: "10", shortVersion: nil, modeIDs: [modeID]))
        #expect(try await newer.installer.upgradeIfNeeded() == .upToDate)
        let none = Rig()
        #expect(try await none.installer.upgradeIfNeeded() == .notInstalled)
        let other = Rig(installed: InputMethodBundleInfo(bundleID: "com.example.other", version: "1", shortVersion: nil, modeIDs: []))
        #expect(try await other.installer.upgradeIfNeeded() == .skipped("bundle ID com.example.other"))
        for rig in [same, newer, none, other] {
            #expect(rig.files.log.isEmpty && rig.tis.log.isEmpty && rig.processes.log.isEmpty)
        }
    }

    @Test("version order is numeric")
    func versions() {
        #expect(SystemInputMethodInstaller.isNewer("10", than: "9"))
        #expect(SystemInputMethodInstaller.isNewer("1.10", than: "1.9"))
        #expect(!SystemInputMethodInstaller.isNewer("1", than: "1"))
        #expect(SystemInputMethodInstaller.isNewer("1", than: nil))
    }

    // MARK: Uninstall (D16): prepare, wait for the user, finish

    @Test("prepare: Dấu is selected → another keyboard is selected and Keyboard settings open; nothing removed, nothing disabled")
    func prepareSelected() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.tis.currentID = modeID
        let preparation = try await rig.installer.prepareUninstall()
        #expect(preparation == UninstallPreparation(switchedTo: "ABC", needsOtherKeyboard: false))
        #expect(rig.tis.log == ["select com.apple.keylayout.ABC"])
        #expect(rig.keyboardOpened.value == 1)
        #expect(rig.files.log.isEmpty)
        #expect(rig.processes.log.isEmpty)
        #expect(rig.counter.value == 0)
    }

    @Test("prepare: Dấu not selected → no keyboard switch, Keyboard settings still open")
    func prepareNotSelected() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.tis.currentID = "com.apple.keylayout.ABC"
        let preparation = try await rig.installer.prepareUninstall()
        #expect(preparation == UninstallPreparation(switchedTo: nil, needsOtherKeyboard: false))
        #expect(rig.tis.log.isEmpty)
        #expect(rig.keyboardOpened.value == 1)
    }

    @Test("prepare: Dấu is selected and there is no keyboard to switch to → the user must choose one (N5: no name claimed)")
    func prepareNoKeyboard() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.tis.all.removeAll { $0.entry.id.contains("keylayout") }
        rig.tis.currentID = modeID
        let preparation = try await rig.installer.prepareUninstall()
        #expect(preparation == UninstallPreparation(switchedTo: nil, needsOtherKeyboard: true))
        #expect(rig.keyboardOpened.value == 1)
    }

    @Test("wait: returns once the user removed Dấu from the input sources; it never disables anything itself")
    func waitUntilRemoved() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true), removedByUserAfterPauses: 3)
        try await rig.installer.waitUntilRemovedFromInputSources()
        #expect(rig.pauses.value == 3)
        #expect(rig.tis.log.isEmpty)
        #expect(rig.files.log.isEmpty)
        // Already gone: no wait.
        try await rig.installer.waitUntilRemovedFromInputSources()
        #expect(rig.pauses.value == 3)
    }

    @Test("wait: cancelling ends the wait and removes nothing (Huỷ gỡ cài đặt)")
    func waitCancelled() async {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        let task = Task { try await rig.installer.waitUntilRemovedFromInputSources() }
        await Task.yield()
        task.cancel()
        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(rig.files.log.isEmpty)
        #expect(rig.counter.value == 0)
        #expect(rig.installer.status() == .enabled)
    }

    @Test("finish: refuses while Dấu is still in the stored input sources; nothing stopped, trashed or deleted")
    func finishWhileStored() async {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.processes.running = true
        await #expect(throws: InputMethodInstallerError.stillListed) {
            _ = try await rig.installer.finishUninstall(deleteSettings: true)
        }
        #expect(rig.files.log.isEmpty)
        #expect(rig.processes.log.isEmpty)
        #expect(rig.counter.value == 0)
        // Only the mode left over counts too.
        rig.tis.stored = [modeID]
        await #expect(throws: InputMethodInstallerError.stillListed) {
            _ = try await rig.installer.finishUninstall(deleteSettings: false)
        }
        #expect(rig.files.log.isEmpty)
    }

    @Test("finish: once removed → stop the input method, Trash, data kept")
    func finish() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.processes.running = true
        rig.tis.userRemovesDau()
        let report = try await rig.installer.finishUninstall(deleteSettings: false)
        #expect(rig.processes.log == ["requestQuit"])
        #expect(rig.files.log == ["trash"])
        #expect(report == UninstallReport(switchedTo: nil, movedToTrash: true, stillEnabled: false, dataDeleted: false))
        #expect(rig.counter.value == 0)
        #expect(rig.installer.status() == .notInstalled)
        // TIS is not asked to disable anything.
        #expect(!rig.tis.log.contains { $0.hasPrefix("disable") })
    }

    @Test("finish: the box deletes the data")
    func finishWithData() async throws {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.tis.userRemovesDau()
        let report = try await rig.installer.finishUninstall(deleteSettings: true)
        #expect(report.dataDeleted)
        #expect(rig.counter.value == 1)
    }

    @Test("finish: a failed trash throws and deletes no data")
    func finishTrashFails() async {
        let rig = Rig(installed: old, sources: FakeTextInputSources.dau(enabled: true))
        rig.tis.userRemovesDau()
        rig.files.trashError = .failed("trash")
        await #expect(throws: InputMethodInstallerError.failed("trash")) {
            _ = try await rig.installer.finishUninstall(deleteSettings: true)
        }
        #expect(rig.counter.value == 0)
    }

    @Test("finish: not installed (only listed before) still reports")
    func finishNotInstalled() async throws {
        let rig = Rig(sources: FakeTextInputSources.dau(enabled: true))
        rig.tis.userRemovesDau()
        let report = try await rig.installer.finishUninstall(deleteSettings: false)
        #expect(rig.files.log.isEmpty)
        #expect(!report.movedToTrash)
        #expect(!report.stillEnabled)
    }

    // MARK: Files (temp folder)

    @Test("files: staged copy swapped in, quarantine cleared, old bundle gone, no staging left")
    func files() throws {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent("dau-installer-\(UUID().uuidString)")
        defer { try? fm.removeItem(at: root) }
        func makeBundle(_ url: URL, version: String, marker: String) throws {
            let contents = url.appendingPathComponent("Contents")
            try fm.createDirectory(at: contents.appendingPathComponent("MacOS"), withIntermediateDirectories: true)
            let info: [String: Any] = [
                "CFBundleIdentifier": imID, "CFBundleVersion": version, "CFBundleShortVersionString": "0.\(version).0",
                "ComponentInputModeDict": ["tsInputModeListKey": [modeID: [:]]],
            ]
            try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
                .write(to: contents.appendingPathComponent("Info.plist"))
            try Data(marker.utf8).write(to: contents.appendingPathComponent("MacOS/DauInputMethod"))
        }
        let embedded = root.appendingPathComponent("App/DauInputMethod.app")
        try makeBundle(embedded, version: "2", marker: "new")
        let quarantine = "0081;00000000;Safari;"
        #expect(setxattr(embedded.appendingPathComponent("Contents/MacOS/DauInputMethod").path, Quarantine.attribute,
                         quarantine, quarantine.utf8.count, 0, 0) == 0)
        let dir = root.appendingPathComponent("Input Methods")
        var verified: [URL] = []
        var trashed: [URL] = []
        var files = InputMethodBundleFiles(embeddedURL: embedded, directory: dir)
        files.verify = { verified.append($0); return true }
        files.trash = { trashed.append($0); try fm.removeItem(at: $0) }

        #expect(!files.isInstalled)
        #expect(files.embedded?.vietnameseModeID == modeID)
        try files.installEmbedded()   // first install: creates the folder
        #expect(files.installed?.version == "2")

        try makeBundle(files.installedURL, version: "1", marker: "old")   // an older one is there
        #expect(files.installed?.version == "1")
        try files.installEmbedded()
        #expect(files.installed?.version == "2")   // read fresh, not from a Bundle cache
        let binary = files.installedURL.appendingPathComponent("Contents/MacOS/DauInputMethod")
        #expect(String(decoding: try Data(contentsOf: binary), as: UTF8.self) == "new")
        #expect(!Quarantine.isSet(binary))
        #expect(Quarantine.isSet(embedded.appendingPathComponent("Contents/MacOS/DauInputMethod")))   // the app's copy untouched
        #expect(try fm.contentsOfDirectory(atPath: dir.path) == ["DauInputMethod.app"])
        // The staged copy was checked, not the app's.
        #expect(verified.count == 2 && verified.allSatisfy { $0.lastPathComponent.hasPrefix(".DauInputMethod-staging-") })

        // A bad signature leaves the installed bundle as it was.
        files.verify = { _ in false }
        #expect(throws: InputMethodInstallerError.invalidSignature) { try files.installEmbedded() }
        #expect(files.installed?.version == "2")
        #expect(try fm.contentsOfDirectory(atPath: dir.path) == ["DauInputMethod.app"])

        try files.moveInstalledToTrash()
        #expect(trashed.map(\.path) == [files.installedURL.path])
        #expect(!files.isInstalled)

        // No bundle inside the app.
        let missing = InputMethodBundleFiles(embeddedURL: root.appendingPathComponent("nope.app"), directory: dir)
        #expect(missing.embedded == nil)
        #expect(throws: InputMethodInstallerError.unavailable) { try missing.installEmbedded() }
    }
}

@MainActor
@Suite("Tampered input method (D37, security review 02/11/2026)")
struct TamperedInputMethodTests {
    @Test("a copy without this app's signature shows the banner; Cài lại installs ours")
    func reinstall() async {
        let installer = FakeInputMethodInstaller(.enabled)
        installer.genuine = false
        let actions = InputMethodActions(installer: installer, openKeyboardSettings: {})
        actions.checkInstalled()
        #expect(actions.installedTampered)
        await actions.reinstallInputMethod()
        #expect(installer.calls == ["install"])
        #expect(!actions.installedTampered)
        #expect(actions.reinstall == .idle)
    }

    @Test("a failed reinstall keeps the banner with the failure hint")
    func reinstallFails() async {
        let installer = FakeInputMethodInstaller(.enabled, failure: .invalidSignature)
        installer.genuine = false
        let actions = InputMethodActions(installer: installer, openKeyboardSettings: {})
        actions.checkInstalled()
        await actions.reinstallInputMethod()
        #expect(actions.installedTampered)
        #expect(actions.reinstall == .failed)
    }

    @Test("the real files check: nothing installed counts as genuine")
    func notInstalled() {
        let files = FakeFiles()
        #expect(files.installedIsGenuine)
        files.installed = files.embedded
        files.genuine = false
        #expect(!files.installedIsGenuine)
    }
}

@MainActor
@Suite("Uninstall flow (D16)")
struct UninstallFlowTests {
    func settle(_ condition: () -> Bool) async {
        for _ in 0..<400 where !condition() { try? await Task.sleep(for: .milliseconds(5)) }
    }

    @Test("prepare, the sheet while the user removes Dấu, then finish: nothing removed before the entry is gone")
    func waitsThenFinishes() async {
        let installer = FakeInputMethodInstaller(.selected)
        installer.preparation = UninstallPreparation(switchedTo: "ABC", needsOtherKeyboard: false)
        installer.stillListed = true
        installer.uninstallReport = UninstallReport(switchedTo: nil, movedToTrash: true, stillEnabled: false, dataDeleted: true)
        let actions = InputMethodActions(installer: installer, openKeyboardSettings: {})
        let run = Task { await actions.performUninstall(deleteSettings: true) }
        await settle { actions.uninstallSheet != nil }
        #expect(actions.uninstallSheet == UninstallPreparation(switchedTo: "ABC", needsOtherKeyboard: false))
        #expect(actions.isUninstalling)
        #expect(installer.calls == ["prepareUninstall", "wait"])
        #expect(installer.status() == .selected)

        installer.stillListed = false   // the user clicked "–"
        let outcome = await run.value
        #expect(outcome == .done(UninstallReport(switchedTo: "ABC", movedToTrash: true, stillEnabled: false, dataDeleted: true)))
        #expect(installer.calls == ["prepareUninstall", "wait", "finish+data"])
        #expect(actions.uninstallSheet == nil)
        #expect(!actions.isUninstalling)
    }

    @Test("Huỷ gỡ cài đặt: the sheet closes and nothing is removed")
    func cancel() async {
        let installer = FakeInputMethodInstaller(.enabled)
        installer.stillListed = true
        let actions = InputMethodActions(installer: installer, openKeyboardSettings: {})
        let run = Task { await actions.performUninstall(deleteSettings: true) }
        await settle { actions.uninstallSheet != nil }
        actions.cancelUninstall()
        #expect(await run.value == .cancelled)
        #expect(installer.calls == ["prepareUninstall", "wait"])
        #expect(installer.status() == .enabled)
        #expect(actions.uninstallSheet == nil)
        #expect(!actions.isUninstalling)
        // A later uninstall starts again.
        installer.stillListed = false
        #expect(await actions.performUninstall(deleteSettings: false) == .done(UninstallReport()))
    }

    @Test("a failed preparation or finish ends in the failure alert, no sheet left")
    func failure() async {
        let installer = FakeInputMethodInstaller(.enabled, failure: .unavailable)
        let actions = InputMethodActions(installer: installer, openKeyboardSettings: {})
        #expect(await actions.performUninstall(deleteSettings: false) == .failed)
        #expect(actions.uninstallSheet == nil)
        #expect(!actions.isUninstalling)
    }

    @Test("\"Mở System Settings\" on the sheet opens the Keyboard pane")
    func openKeyboard() {
        final class Opened { var count = 0 }
        let opened = Opened()
        let actions = InputMethodActions(installer: FakeInputMethodInstaller(.enabled), openKeyboardSettings: { opened.count += 1 })
        actions.openKeyboard()
        #expect(opened.count == 1)
    }
}

@MainActor
@Suite("Banner enable (N4)")
struct BannerEnableTests {
    @Test("Bật lại enables and reads back; the banner has no undo")
    func enable() async {
        let installer = FakeInputMethodInstaller(.installed(version: nil))
        let actions = InputMethodActions(installer: installer, openKeyboardSettings: {})
        #expect(await actions.enableFromBanner() == false)
        #expect(actions.banner == .enabled)
        #expect(installer.calls == ["enable"])
    }

    @Test("macOS keeps Dấu off → Keyboard settings open")
    func stillOff() async {
        final class Opened { var count = 0 }
        let opened = Opened()
        let installer = FakeInputMethodInstaller(.installed(version: nil))
        installer.enableOutcome = .notEnabled
        let actions = InputMethodActions(installer: installer, openKeyboardSettings: { opened.count += 1 })
        _ = await actions.enableFromBanner()
        #expect(actions.banner == .notEnabled)
        #expect(opened.count == 1)
    }
}
