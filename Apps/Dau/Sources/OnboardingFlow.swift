import Foundation
import Observation

/// The onboarding window's state (D14, docs/UI.md "Onboarding"): which step shows, what
/// was detected, Dấu's status and the result of the last action. Views only read it and
/// call its actions; services come in through protocols (`OldInputMethodDetector`,
/// `InputMethodInstaller`) so tests drive it with fakes.
///
/// Before the steps, "Chuyển Dấu vào Applications" (artboard OnboardingMoveToApplications):
/// while this copy of Dấu is not the owner copy and no input method is installed (D37).
/// It only guides: open the Applications folder, quit Dấu. No step has started then.
///
/// Steps:
/// 1. "Tắt bộ gõ cũ trước đã": only while another Vietnamese input method is running.
///    Rechecked when the window becomes active; it moves on by itself once none runs,
///    and skipping is allowed.
/// 2. "Bật Dấu": install if needed (the owner copy only, D37), then enable: macOS asks the user to allow it, so the
///    step waits ("Đang chờ"), then shows the result read back from Text Input Sources
///    (N4, N5): enabled → "Đã bật"; still off or not listed → "Chưa bật được" with the
///    ways around it (retry, add it by hand, one logout, D37). No undo: Dấu cannot
///    switch itself off, only the user can. While the owner copy finds the installed
///    input method's signature wrong, the step shows the install error, whose "Cài lại"
///    reinstalls (artboard OnboardingEnableError; D37): reinstall first, then enable.
/// 3. "Chọn kiểu gõ và gõ thử".
///
/// No step has a "Quay lại" button: each one moves forward only.
@MainActor
@Observable
final class OnboardingFlow {
    enum Step: Int, CaseIterable, Sendable {
        case oldInputMethods = 1, enable, typing
    }

    enum StepState: Equatable, Sendable {
        case done, current, pending
    }

    private(set) var step: Step = .enable
    /// Other input methods running now (installed but not running ones do not clash).
    private(set) var conflicts: [DetectedInputMethod] = []
    private(set) var status: InputMethodStatus = .unknown
    /// This copy of Dấu is not the owner copy and no input method is installed (D37):
    /// the window shows "Chuyển Dấu vào Applications" instead of the steps. Read again
    /// with everything else, so it follows the system (the user moved Dấu, or another
    /// copy installed the input method).
    private(set) var needsMoveToApplications = false
    private(set) var shortcut: InputSourceShortcut.Reading = .unknown
    /// Name of the keyboard layout used for English, e.g. "U.S."; nil if unknown.
    private(set) var englishLayout: String?
    /// Other Vietnamese input sources enabled in the system (soft note, step 2).
    private(set) var otherSources: [String] = []
    /// `enable()` is running: installing, or waiting for the user to click Allow.
    private(set) var isWorking = false
    /// This copy is the owner copy and the installed input method's signature is invalid
    /// or by another team (D37): step 2 shows the install error, whose "Cài lại"
    /// reinstalls before Dấu can be turned on.
    /// Read again with everything else; a copy that is not the owner copy never checks.
    private(set) var installedTampered = false
    /// "Cài lại" is running.
    private(set) var isReinstalling = false
    /// What went wrong with the last action, shown on step 2.
    private(set) var problem: Problem?

    enum Problem: Equatable, Sendable {
        /// An error: the copy, the signature, the registration…
        case failed
        /// Nothing stored as enabled after the wait (the dialog did not show, or the user
        /// declined it).
        case notEnabled
        /// Text Input Sources does not list Dấu (D37).
        case notListed
    }

    /// What step 2 shows.
    enum EnableScreen: Equatable, Sendable {
        /// Before "Bật Dấu".
        case ready
        /// "Bật Dấu" is waiting for the user to click Allow.
        case waiting
        /// Dấu is among the enabled input sources.
        case done
        /// `notEnabled` or `notListed`: retry, add by hand, log out.
        case notEnabled
        /// "Chưa cài được Dấu" (artboard OnboardingEnableError): an install error (copy,
        /// signature, registration), or the installed input method's signature is wrong
        /// (D37). Its "Cài lại" is `enable()`, which reinstalls in the second case.
        case error
    }

    var enableScreen: EnableScreen {
        if status.isEnabled { return .done }
        if isReinstalling || installedTampered { return .error }
        if isWorking { return .waiting }
        switch problem {
        case .notEnabled?, .notListed?: return .notEnabled
        case .failed?: return .error
        case nil: return .ready
        }
    }

    var failed: Bool { problem != nil }
    /// "Chi tiết" on the error screen (no placeholder, N5): the last error's own
    /// description, else the signature check's while the installed copy is not Dấu's own.
    var errorDetail: String? {
        failureDetail ?? (installedTampered ? InputMethodInstallerError.invalidSignature.detail : nil)
    }
    /// The last error's description. Set with `problem == .failed`.
    private var failureDetail: String?
    /// Text of the try-it field (step 3).
    var tryText = ""
    /// Step to open at instead of the usual first step, once (debug flag `--onboarding`).
    @ObservationIgnored var forcedStartStep: Step?

    @ObservationIgnored private let detector: OldInputMethodDetector
    @ObservationIgnored private let installer: InputMethodInstaller
    @ObservationIgnored private let readShortcut: () -> InputSourceShortcut.Reading
    @ObservationIgnored private let readEnglishLayout: () -> String?
    @ObservationIgnored private let openKeyboardSettings: () -> Void
    @ObservationIgnored private let applicationsFolderOpener: @MainActor () -> Void
    @ObservationIgnored private let quitter: @MainActor () -> Void
    /// The running `enable()` and which call it belongs to: "Thử lại" cancels it, and a
    /// call that was replaced leaves the state alone.
    @ObservationIgnored private var enableTask: Task<EnableOutcome, Error>?
    @ObservationIgnored private var attempt = 0

    init(detector: OldInputMethodDetector, installer: InputMethodInstaller,
         shortcut: @escaping () -> InputSourceShortcut.Reading = InputSourceShortcut.read,
         englishLayout: @escaping () -> String? = InputSourceStatus.englishLayoutName,
         openKeyboardSettings: @escaping () -> Void = SystemSettings.openKeyboard,
         openApplicationsFolder: @escaping @MainActor () -> Void = OwnerCopyGuide.openApplicationsFolder,
         quit: @escaping @MainActor () -> Void = OwnerCopyGuide.quit) {
        self.detector = detector
        self.installer = installer
        self.readShortcut = shortcut
        self.readEnglishLayout = englishLayout
        self.openKeyboardSettings = openKeyboardSettings
        self.applicationsFolderOpener = openApplicationsFolder
        self.quitter = quit
    }

    /// Starts over: step 1 if another input method is running, else step 2.
    func start() {
        cancelEnable()
        problem = nil
        failureDetail = nil
        readSystem()
        step = conflicts.isEmpty ? .enable : .oldInputMethods
        if let forced = forcedStartStep {
            step = forced
            forcedStartStep = nil
        }
    }

    /// Reads everything again (window became active, input sources changed). On step
    /// 1, moves on by itself once nothing clashes any more.
    func refresh() {
        readSystem()
        if step == .oldInputMethods && conflicts.isEmpty { step = .enable }
        // macOS turned Dấu on (the user allowed it, or added it by hand): the failure no
        // longer holds.
        if status.isEnabled { problem = nil }
    }

    /// Step 1, "Kiểm tra lại".
    func recheck() { refresh() }

    /// Step 1, "Bỏ qua": go on with the other input method still running.
    func skip() {
        guard step == .oldInputMethods, !needsMoveToApplications else { return }
        step = .enable
    }

    /// "Tiếp tục": step 2 → 3 once Dấu is enabled.
    func next() {
        guard !needsMoveToApplications, step == .enable, status.isEnabled else { return }
        problem = nil
        step = .typing
    }

    /// Step 2, "Bật Dấu", "Thử lại" and the install error's "Cài lại": installs first
    /// when needed, then waits for macOS to store Dấu as enabled. A run still waiting is
    /// cancelled first (the new one makes macOS ask again). A copy that is not the owner
    /// copy never installs (D37): with nothing installed it shows "Chuyển Dấu vào
    /// Applications" and this does nothing; with the input method installed it only
    /// enables. While the installed input method's signature is wrong nothing is enabled
    /// (D37): this reinstalls instead, and an `enable()` that finds it only now shows the
    /// install error.
    func enable() async {
        guard step == .enable, !status.isEnabled, !needsMoveToApplications, !isReinstalling else { return }
        if installedTampered {
            await reinstall()
            return
        }
        enableTask?.cancel()
        attempt += 1
        let mine = attempt
        isWorking = true
        problem = nil
        failureDetail = nil
        let installer = self.installer
        let install = status == .notInstalled && installer.isOwnerCopy
        let task = Task { @MainActor () throws -> EnableOutcome in
            if install { try await installer.install() }
            return try await installer.enable()
        }
        enableTask = task
        let result = await task.result
        // Replaced by a newer run, or cancelled: not this call's state.
        guard mine == attempt else { return }
        enableTask = nil
        isWorking = false
        switch result {
        case .success(.enabled): break
        case .success(.notEnabled): problem = .notEnabled
        case .success(.notListed): problem = .notListed
        case .success(.needsReinstall): installedTampered = true
        case .failure(let error):
            problem = .failed
            failureDetail = Self.describe(error)
            installLogger.error("event=enable-failed error=\(String(describing: error), privacy: .public)")
        }
        status = installer.status()
        if status.isEnabled { problem = nil }
    }

    /// Step 2, "Cài lại" while the installed input method's signature is wrong (artboard
    /// OnboardingEnableError; D37): installs the owner copy's own input method over it,
    /// and enables nothing. Once the installed copy is genuine the step shows "Bật Dấu" as
    /// usual; otherwise the install error stays, with the new detail.
    func reinstall() async {
        guard step == .enable, installedTampered, !isReinstalling, !status.isEnabled else { return }
        cancelEnable()
        isReinstalling = true
        problem = nil
        failureDetail = nil
        do {
            try await installer.install()
        } catch {
            problem = .failed
            failureDetail = Self.describe(error)
            installLogger.error("event=onboarding-reinstall-failed error=\(String(describing: error), privacy: .public)")
        }
        isReinstalling = false
        status = installer.status()
        installedTampered = readInstalledTampered()
        if installedTampered, problem == nil {
            // Installed without an error, and still not Dấu's own: say so, never "Bật Dấu".
            problem = .failed
            failureDetail = InputMethodInstallerError.invalidSignature.detail
        }
        if status.isEnabled { problem = nil }
    }

    /// What the error screen shows under "Chi tiết": the error's description.
    nonisolated static func describe(_ error: Error) -> String {
        if let error = error as? InputMethodInstallerError { return error.detail }
        // Any other error (a file operation): its text is in the system's language, not
        // Dấu's, so the screen says only where it happened; the log has the error.
        return String(localized: "Something went wrong while copying or registering the input method.")
    }

    /// "Mở System Settings" on the "Chưa bật được" screen (N4: only opens the pane).
    func openSystemSettings() { openKeyboardSettings() }

    /// "Mở thư mục Applications" on "Chuyển Dấu vào Applications": shows the folder in
    /// Finder. Dấu never moves itself.
    func openApplicationsFolder() { applicationsFolderOpener() }

    /// "Thoát Dấu" on "Chuyển Dấu vào Applications": a normal quit.
    func quit() { quitter() }

    private func cancelEnable() {
        enableTask?.cancel()
        enableTask = nil
        attempt += 1
        isWorking = false
    }

    func state(of step: Step) -> StepState {
        // "Chuyển Dấu vào Applications" comes before step 1: no step has started.
        if needsMoveToApplications { return .pending }
        if step == self.step { return .current }
        switch step {
        case .oldInputMethods:
            // Skipped with an input method still running: not done.
            return conflicts.isEmpty ? .done : .pending
        case .enable:
            return status.isEnabled ? .done : .pending
        case .typing:
            return .pending
        }
    }

    /// Debug captures: show a step as is.
    func show(_ step: Step) {
        self.step = step
    }

    /// D37: only the owner copy checks, only an installed input method that is not on
    /// yet (once it is on, the Settings window's banner asks). `status` is read first.
    private func readInstalledTampered() -> Bool {
        guard case .installed = status, installer.isOwnerCopy else { return false }
        return !installer.installedIsGenuine()
    }

    private func readSystem() {
        conflicts = detector.detect().filter(\.isRunning)
        otherSources = detector.otherVietnameseSources()
        status = installer.status()
        let needsMove = status == .notInstalled && !installer.isOwnerCopy
        if needsMove && !needsMoveToApplications { cancelEnable() }
        needsMoveToApplications = needsMove
        if !isReinstalling {
            let tampered = readInstalledTampered()
            // No wait for Allow outlives the screen: nothing is enabled while it shows.
            if tampered && !installedTampered { cancelEnable() }
            installedTampered = tampered
        }
        shortcut = readShortcut()
        englishLayout = readEnglishLayout()
    }
}

/// Which window opens at launch (docs/UI.md): onboarding while Dấu is not installed or
/// not enabled, Settings otherwise. Unknown status opens Settings (nothing is claimed).
enum LaunchRouter {
    static func opensOnboarding(_ status: InputMethodStatus) -> Bool {
        switch status {
        case .notInstalled, .installed: true
        case .unknown, .enabled, .selected: false
        }
    }
}
