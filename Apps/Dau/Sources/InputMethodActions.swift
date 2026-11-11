import AppKit
import SwiftUI

/// The Settings window's input method actions: "Bật lại" on the "Dấu chưa được bật"
/// banner (N4; there is no undo, Dấu cannot switch itself off) and "Gỡ cài đặt…" (D16):
/// confirmation, a sheet that waits for the user to remove Dấu from the input sources
/// in System Settings, then the removal. Views
/// get it from the environment; nil there (snapshots) leaves the old behavior: "Bật lại"
/// opens Keyboard settings and "Gỡ cài đặt…" is disabled.
@MainActor
@Observable
final class InputMethodActions {
    /// What the banner shows after "Bật lại" (mockup "SettingsBannerStates").
    enum BannerState: Equatable {
        case idle
        /// Waiting for the user's Allow ("Thử lại" cancels and asks again).
        case working
        /// Dấu was enabled from the banner: a confirmation with "Ẩn".
        case enabled
        /// The wait ended, Dấu still off: how to add it by hand.
        case notEnabled
        /// An error (copy, signature, registration): shown like `notEnabled`.
        case failed
    }

    private(set) var banner: BannerState = .idle
    private(set) var isUninstalling = false
    /// The uninstall sheet ("Bỏ Dấu khỏi nguồn đầu vào") is showing.
    private(set) var isShowingUninstallSheet = false
    /// Dấu is the selected input source (re-read by the sheet while it waits): the sheet
    /// then warns that "–" may be dimmed and asks to select another keyboard first.
    private(set) var dauIsSelected = false
    /// Captures fix `dauIsSelected`: the sheet does not read the real one then.
    @ObservationIgnored private var selectionPinned = false
    #if DEBUG
    /// Captures fix `installedTampered` (`forceTampered`): `checkInstalled` leaves it alone.
    @ObservationIgnored private var tamperedPinned = false
    #endif

    /// The installed input method is not the one this app installs (`installedIsGenuine`).
    private(set) var installedTampered = false
    enum ReinstallState: Equatable { case idle, working, failed }
    private(set) var reinstall: ReinstallState = .idle
    /// Counts the checks of the installed copy: `checkInstalled` (after the launch
    /// reconcile, whenever the app becomes active) and the end of "Cài lại". Views that show what is installed (the development
    /// build's "Bộ gõ đã cài" line, D25) read it again when it changes.
    private(set) var installedChecks = 0

    /// The input source shortcut and the English layout, read when Dấu got enabled from
    /// the banner (its confirmation names the real shortcut, N5).
    private(set) var shortcut: InputSourceShortcut.Reading = .unknown
    private(set) var englishLayout: String?

    @ObservationIgnored let installer: InputMethodInstaller
    @ObservationIgnored private let openKeyboardSettings: () -> Void
    @ObservationIgnored private let inputSourcesOpener: () -> Void
    @ObservationIgnored private let readShortcut: () -> InputSourceShortcut.Reading
    @ObservationIgnored private let readEnglishLayout: () -> String?
    @ObservationIgnored private var bannerTask: Task<EnableOutcome, Error>?
    @ObservationIgnored private var bannerAttempt = 0
    @ObservationIgnored private var launchReconcile: Task<Void, Never>?

    init(installer: InputMethodInstaller,
         openKeyboardSettings: @escaping () -> Void = SystemSettings.openKeyboard,
         openInputSources: @escaping () -> Void = SystemSettings.openInputSources,
         shortcut: @escaping () -> InputSourceShortcut.Reading = InputSourceShortcut.read,
         englishLayout: @escaping () -> String? = InputSourceStatus.englishLayoutName) {
        self.installer = installer
        self.openKeyboardSettings = openKeyboardSettings
        self.inputSourcesOpener = openInputSources
        self.readShortcut = shortcut
        self.readEnglishLayout = englishLayout
    }

    /// "Bật lại" and "Thử lại". Returns true when the onboarding window should take over:
    /// the input method is not installed, or macOS does not list it yet. A run still
    /// waiting for the user's Allow is cancelled first. An installed copy with a wrong
    /// signature is not enabled (D37): the "Cài lại" banner shows instead.
    func enableFromBanner() async -> Bool {
        bannerTask?.cancel()
        bannerAttempt += 1
        let mine = bannerAttempt
        banner = .working
        switch installer.status() {
        case .notInstalled:
            banner = .idle
            return true
        case .unknown:
            // No input method inside the app: nothing to enable here (N4: guide only).
            banner = .idle
            openKeyboardSettings()
            return false
        case .enabled, .selected:
            banner = .idle
            return false
        case .installed:
            break
        }
        let installer = self.installer
        let task = Task { @MainActor in try await installer.enable() }
        bannerTask = task
        let result = await task.result
        guard mine == bannerAttempt else { return false }   // replaced by a newer run
        bannerTask = nil
        switch result {
        case .success(.enabled):
            shortcut = readShortcut()
            englishLayout = readEnglishLayout()
            banner = .enabled
        case .success(.notEnabled):
            banner = .notEnabled
        case .success(.notListed):
            banner = .idle
            return true
        case .success(.needsReinstall):
            // D37: nothing was enabled. The tampered banner, with "Cài lại", shows above
            // this one, which goes back to "Bật lại" for after the reinstall.
            installedTampered = true
            banner = .idle
        case .failure:
            banner = .failed
        }
        return false
    }

    /// "Ẩn" on the confirmation: hides it for this session.
    func dismissBanner() {
        guard banner == .enabled else { return }
        banner = .idle
    }

    /// D37, at launch: the owner copy replaces an installed input method that differs
    /// from the one inside it (`reconcile`), then the signature is checked. A copy with
    /// a wrong signature is not replaced, so the check shows "Cài lại" for it.
    func startLaunchReconcile() {
        guard launchReconcile == nil else { return }
        let installer = self.installer
        launchReconcile = Task { @MainActor [weak self] in
            do {
                let outcome = try await installer.reconcile()
                installLogger.notice("event=launch-reconcile outcome=\(String(describing: outcome), privacy: .public)")
            } catch {
                installLogger.error("event=launch-reconcile-failed error=\(String(describing: error), privacy: .public)")
            }
            self?.checkInstalled()
        }
    }

    /// The launch reconcile, when one was started (tests wait for it).
    func launchReconcileFinished() async {
        await launchReconcile?.value
    }

    /// Checks the installed input method's signature (at launch and whenever the app
    /// becomes active). A copy that is not the owner copy checks nothing and shows no
    /// banner (D37).
    func checkInstalled() {
        installedChecks += 1
        #if DEBUG
        // `--tampered`: the banner stays for the capture, whatever is installed.
        if tamperedPinned { return }
        #endif
        guard reinstall != .working else { return }
        guard installer.isOwnerCopy else {
            installedTampered = false
            reinstall = .idle
            return
        }
        installedTampered = !installer.installedIsGenuine()
        if !installedTampered { reinstall = .idle }
    }

    /// "Cài lại" on the tampered banner: installs the app's own copy (signature checked
    /// before it is swapped in); the replaced one quits, its bundle on disk having changed.
    /// Only the owner copy (D37): the banner does not show otherwise.
    func reinstallInputMethod() async {
        guard reinstall != .working, installer.isOwnerCopy else { return }
        #if DEBUG
        // Captures (`--tampered`): the banner is pinned; "Cài lại" never touches the real copy.
        if tamperedPinned { return }
        #endif
        reinstall = .working
        do {
            try await installer.install()
            reinstall = .idle
        } catch {
            reinstall = .failed
        }
        installedTampered = !installer.installedIsGenuine()
        if installedTampered { reinstall = .failed }
        installedChecks += 1
    }

    #if DEBUG
    /// Captures (`--tampered`): show the banner without touching the installed copy, and
    /// keep it: no later check (the launch reconcile's, an activation's) reads the real one.
    func forceTampered() {
        tamperedPinned = true
        installedTampered = true
    }
    /// Captures (`--capture-uninstall`): show or hide the uninstall sheet, running nothing.
    func showUninstallSheetForCapture(_ shown: Bool, dauIsSelected: Bool = false) {
        selectionPinned = shown
        isShowingUninstallSheet = shown
        self.dauIsSelected = dauIsSelected
    }
    #endif

    /// The input sources changed: once Dấu is on (e.g. the user added it in Keyboard
    /// settings) the "not enabled" guidance is no longer true.
    func inputSourcesChanged(isEnabled: Bool?) {
        if isEnabled == true, banner == .notEnabled || banner == .failed { banner = .idle }
    }

    // MARK: Uninstall (D16)

    enum UninstallOutcome: Equatable {
        case done(UninstallReport)
        case failed
        /// "Huỷ gỡ cài đặt": nothing was removed.
        case cancelled
    }

    @ObservationIgnored private var uninstallTask: Task<UninstallOutcome, Never>?
    /// How often the sheet re-reads the selected input source while it waits. The change
    /// notification can arrive before this process's Text Input Sources state has caught
    /// up (measured: the hint lagged one change behind), so the poll is what keeps the hint
    /// right; the notification only makes it quicker.
    var selectionPollInterval: Duration = .milliseconds(500)

    /// "Gỡ cài đặt…": confirmation alert ("Tiếp tục gỡ"), then the sheet and the removal.
    func confirmUninstall(in window: NSWindow?) {
        guard !isUninstalling else { return }
        let (alert, deleteData) = UninstallAlert.confirmation()
        UninstallAlert.present(alert, in: window) { [weak self] response in
            guard response == .alertFirstButtonReturn, let self else { return }
            let delete = deleteData.state == .on
            Task { await self.uninstall(deleteSettings: delete, window: window) }
        }
    }

    /// The whole removal with its alerts: prepare, wait for the user, finish.
    func uninstall(deleteSettings: Bool, window: NSWindow?) async {
        switch await performUninstall(deleteSettings: deleteSettings) {
        case .cancelled:
            break
        case .done(let report):
            UninstallAlert.present(UninstallAlert.done(report), in: window) { _ in
                // The input method is gone; this app would only offer to install it
                // again. It quits; the user removes Dấu.app from Applications.
                NSApp.terminate(nil)
            }
        case .failed:
            UninstallAlert.present(UninstallAlert.failed(), in: window) { _ in }
        }
    }

    /// Without the alerts (tests): `prepareUninstall` (another keyboard, Keyboard
    /// settings), the sheet while it waits until Dấu is gone from the stored input
    /// sources, then `finishUninstall` (stop, Trash, data). `cancelUninstall()` ends the
    /// wait and removes nothing.
    func performUninstall(deleteSettings: Bool) async -> UninstallOutcome {
        guard !isUninstalling else { return .cancelled }
        isUninstalling = true
        let installer = self.installer
        let task = Task { @MainActor [weak self] () -> UninstallOutcome in
            do {
                // D16: Dấu installed but not among the input sources (never enabled, or the
                // user removed it already): nothing to wait for, so no System Settings and
                // no sheet; straight to the removal.
                guard installer.isListedInInputSources() else {
                    return .done(try await installer.finishUninstall(deleteSettings: deleteSettings))
                }
                try await installer.prepareUninstall()
                self?.isShowingUninstallSheet = true
                self?.refreshDauIsSelected()
                let poll = self?.selectionPollInterval ?? .milliseconds(500)
                let poller = Task { @MainActor [weak self] in
                    while !Task.isCancelled {
                        try? await Task.sleep(for: poll)
                        // Not after the sheet closed: a read in flight must not set the hint again.
                        if self?.isShowingUninstallSheet == true { self?.refreshDauIsSelected() }
                    }
                }
                defer { poller.cancel() }
                try await installer.waitUntilRemovedFromInputSources()
                return .done(try await installer.finishUninstall(deleteSettings: deleteSettings))
            } catch is CancellationError {
                // "Huỷ gỡ cài đặt": nothing was switched or removed.
                return .cancelled
            } catch {
                installLogger.error("event=uninstall-failed error=\(String(describing: error), privacy: .public)")
                return .failed
            }
        }
        uninstallTask = task
        let outcome = await task.value
        isShowingUninstallSheet = false
        dauIsSelected = false
        uninstallTask = nil
        isUninstalling = false
        return outcome
    }

    /// "Huỷ gỡ cài đặt" on the sheet (or Esc).
    func cancelUninstall() {
        uninstallTask?.cancel()
    }

    /// Reads again whether Dấu is the selected input source (the sheet's hint follows it).
    func refreshDauIsSelected() {
        guard !selectionPinned else { return }
        dauIsSelected = installer.status() == .selected
    }

    /// "Mở System Settings" on the sheet: the Input Sources list (N4: only opens it).
    func showInputSources() { inputSourcesOpener() }
}

extension EnvironmentValues {
    @Entry var inputMethodActions: InputMethodActions?
}

/// The uninstall alerts (mockup "ConfirmDialogs", "Gỡ Dấu khỏi máy?"): a system alert
/// with the app icon, a checkbox and stacked buttons, the destructive one first. The
/// buttons' look is the system's (D9): macOS 27 draws a destructive button as red text
/// on a red tint, the mockup as white on red.
@MainActor
enum UninstallAlert {
    /// The confirmation, and its "Xoá cả cài đặt và quy tắc ứng dụng" checkbox (off).
    static func confirmation() -> (NSAlert, NSButton) {
        let alert = NSAlert()
        alert.messageText = String(localized: "Uninstall Dấu?")
        // macOS lets only the user remove an input source, so the alert says what happens
        // in order (docs/research/InputMethodInstall.md section 5.1).
        let ui = SystemUINames.system()   // macOS's own names (D38)
        alert.informativeText = String(localized: "You’ll remove Dấu from \(ui.inputSources) in \(ui.systemSettings). Then the input method is moved to \(ui.trash).")
        let remove = alert.addButton(withTitle: String(localized: "Uninstall"))
        remove.hasDestructiveAction = true
        // Return must not remove Dấu: no default button; Esc cancels.
        remove.keyEquivalent = ""
        let cancel = alert.addButton(withTitle: String(localized: "Cancel"))
        cancel.keyEquivalent = "\u{1b}"
        alert.showsSuppressionButton = true
        let checkbox = alert.suppressionButton!
        checkbox.title = String(localized: "Also delete settings and app rules")
        checkbox.state = .off
        return (alert, checkbox)
    }

    static func done(_ report: UninstallReport) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = String(localized: "Dấu’s input method was removed")
        let ui = SystemUINames.system()   // macOS's own names (D38)
        var lines: [String] = []
        if report.movedToTrash {
            lines.append(String(localized: "The input method was moved to \(ui.trash)."))
        }
        if report.stillEnabled {
            lines.append(String(localized: "macOS still lists Dấu among the input sources; you can remove it in \(ui.inputSourcesPath)."))
        }
        if report.dataDeleted {
            lines.append(String(localized: "Settings and app rules were deleted."))
        }
        lines.append(String(localized: "To remove the app too, drag Dấu from the \(ui.applications) folder to \(ui.trash)."))
        alert.informativeText = lines.joined(separator: " ")
        alert.addButton(withTitle: String(localized: "Quit Dấu"))
        return alert
    }

    static func failed() -> NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = String(localized: "Couldn’t Remove Dấu")
        let ui = SystemUINames.system()
        alert.informativeText = String(localized: "You can remove “\(ui.dauInputSource)” in \(ui.inputSourcesPath), then try again.")
        alert.addButton(withTitle: String(localized: "OK"))
        return alert
    }

    /// App-modal, centered: the mockup's alert (app icon, centered text, stacked
    /// buttons) is how macOS 26+ draws an app-modal alert; as a sheet it is
    /// left-aligned with side-by-side buttons. `window` is brought forward first.
    static func present(_ alert: NSAlert, in window: NSWindow?, then handler: @escaping @MainActor (NSApplication.ModalResponse) -> Void) {
        window?.makeKeyAndOrderFront(nil)
        // After the button's action returns, so SwiftUI is not inside a modal loop.
        DispatchQueue.main.async {
            MainActor.assumeIsolated { handler(alert.runModal()) }
        }
    }
}
