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
    /// The uninstall sheet ("Bỏ Dấu khỏi Nguồn nhập liệu") is showing; what it says about
    /// the keyboard Dấu switched away from.
    private(set) var uninstallSheet: UninstallPreparation?

    /// The installed input method is not the one this app installs (`installedIsGenuine`).
    private(set) var installedTampered = false
    enum ReinstallState: Equatable { case idle, working, failed }
    private(set) var reinstall: ReinstallState = .idle

    /// The input source shortcut and the English layout, read when Dấu got enabled from
    /// the banner (its confirmation names the real shortcut, N5).
    private(set) var shortcut: InputSourceShortcut.Reading = .unknown
    private(set) var englishLayout: String?

    @ObservationIgnored let installer: InputMethodInstaller
    @ObservationIgnored private let openKeyboardSettings: () -> Void
    @ObservationIgnored private let readShortcut: () -> InputSourceShortcut.Reading
    @ObservationIgnored private let readEnglishLayout: () -> String?
    @ObservationIgnored private var bannerTask: Task<EnableOutcome, Error>?
    @ObservationIgnored private var bannerAttempt = 0

    init(installer: InputMethodInstaller,
         openKeyboardSettings: @escaping () -> Void = SystemSettings.openKeyboard,
         shortcut: @escaping () -> InputSourceShortcut.Reading = InputSourceShortcut.read,
         englishLayout: @escaping () -> String? = InputSourceStatus.englishLayoutName) {
        self.installer = installer
        self.openKeyboardSettings = openKeyboardSettings
        self.readShortcut = shortcut
        self.readEnglishLayout = englishLayout
    }

    /// "Bật lại" and "Thử lại". Returns true when the onboarding window should take over:
    /// the input method is not installed, or macOS does not list it yet. A run still
    /// waiting for the user's Allow is cancelled first.
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

    /// Checks the installed input method's signature (at launch and whenever the app
    /// becomes active).
    func checkInstalled() {
        guard reinstall != .working else { return }
        installedTampered = !installer.installedIsGenuine()
        if !installedTampered { reinstall = .idle }
    }

    /// "Cài lại" on the tampered banner: installs the app's own copy (signature checked
    /// before it is swapped in); the replaced one quits, its bundle on disk having changed.
    func reinstallInputMethod() async {
        guard reinstall != .working else { return }
        reinstall = .working
        do {
            try await installer.install()
            reinstall = .idle
        } catch {
            reinstall = .failed
        }
        installedTampered = !installer.installedIsGenuine()
        if installedTampered { reinstall = .failed }
    }

    #if DEBUG
    /// Captures (`--tampered`): show the banner without touching the installed copy.
    func forceTampered() { installedTampered = true }
    /// Captures (`--capture-uninstall`): show or hide the uninstall sheet, running nothing.
    func showUninstallSheetForCapture(_ preparation: UninstallPreparation?) { uninstallSheet = preparation }
    /// Captures (`--capture-banner`): show a banner state, running nothing.
    func showBannerForCapture(_ state: BannerState, shortcut: InputSourceShortcut.Reading = .unknown, englishLayout: String? = nil) {
        banner = state
        self.shortcut = shortcut
        self.englishLayout = englishLayout
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
                let preparation = try await installer.prepareUninstall()
                self?.uninstallSheet = preparation
                try await installer.waitUntilRemovedFromInputSources()
                var report = try await installer.finishUninstall(deleteSettings: deleteSettings)
                report.switchedTo = preparation.switchedTo
                return .done(report)
            } catch is CancellationError {
                return .cancelled
            } catch {
                installLogger.error("event=uninstall-failed error=\(String(describing: error), privacy: .public)")
                return .failed
            }
        }
        uninstallTask = task
        let outcome = await task.value
        uninstallSheet = nil
        uninstallTask = nil
        isUninstalling = false
        return outcome
    }

    /// "Huỷ gỡ cài đặt" on the sheet (or Esc).
    func cancelUninstall() {
        uninstallTask?.cancel()
    }

    /// "Mở System Settings" on the sheet: the Keyboard pane (N4: only opens it).
    func openKeyboard() { openKeyboardSettings() }
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
        alert.messageText = String(localized: "Gỡ Dấu khỏi máy?")
        // macOS lets only the user remove an input source, so the alert says what happens
        // in order (docs/research/M5-INSTALL.md section 4).
        alert.informativeText = String(localized: "Dấu chuyển bạn sang bàn phím khác, rồi bạn bỏ Dấu khỏi Nguồn nhập liệu trong System Settings. Xong bước đó, Dấu được chuyển vào Thùng rác.")
        let remove = alert.addButton(withTitle: String(localized: "Tiếp tục gỡ"))
        remove.hasDestructiveAction = true
        // Return must not remove Dấu: no default button; Esc cancels.
        remove.keyEquivalent = ""
        let cancel = alert.addButton(withTitle: String(localized: "Huỷ"))
        cancel.keyEquivalent = "\u{1b}"
        alert.showsSuppressionButton = true
        let checkbox = alert.suppressionButton!
        checkbox.title = String(localized: "Xoá cả cài đặt và quy tắc ứng dụng")
        checkbox.state = .off
        return (alert, checkbox)
    }

    static func done(_ report: UninstallReport) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = String(localized: "Đã gỡ bộ gõ Dấu")
        var lines: [String] = []
        if report.movedToTrash {
            lines.append(String(localized: "Bộ gõ đã được chuyển vào Thùng rác."))
        }
        if let keyboard = report.switchedTo {
            lines.append(String(localized: "Nguồn nhập liệu hiện tại: “\(keyboard)”."))
        }
        if report.stillEnabled {
            lines.append(String(localized: "macOS vẫn báo Dấu trong Nguồn nhập liệu; bạn có thể bỏ nó trong System Settings › Keyboard › Input Sources."))
        }
        if report.dataDeleted {
            lines.append(String(localized: "Đã xoá cài đặt và quy tắc ứng dụng."))
        }
        lines.append(String(localized: "Muốn xoá cả ứng dụng, kéo Dấu trong thư mục Ứng dụng vào Thùng rác."))
        alert.informativeText = lines.joined(separator: " ")
        alert.addButton(withTitle: String(localized: "Thoát Dấu"))
        return alert
    }

    static func failed() -> NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = String(localized: "Chưa gỡ được Dấu")
        alert.informativeText = String(localized: "Bạn có thể bỏ “Dấu – Tiếng Việt” trong System Settings › Keyboard › Input Sources, rồi thử lại.")
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
