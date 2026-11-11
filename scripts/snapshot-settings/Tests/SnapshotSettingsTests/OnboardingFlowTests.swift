import Foundation
import Testing
import DauShared
@testable import SnapshotSettings

/// The onboarding window's state machine (D14, docs/UI.md "Onboarding") on fake
/// services: which step shows, what the sidebar marks done, enabling (waiting for the
/// user's Allow, retry, failure; no undo) and which window opens at launch.
@MainActor
@Suite("Onboarding flow")
struct OnboardingFlowTests {
    let openKey = FakeInputMethodDetector.running("OpenKey", bundleID: "com.tuyenmai.openkey")

    final class Opened { var count = 0 }
    let opened = Opened()

    func flow(_ found: [DetectedInputMethod] = [], status: InputMethodStatus = .notInstalled,
              failure: InputMethodInstallerError? = nil,
              shortcut: InputSourceShortcut.Reading = .unknown)
        -> (OnboardingFlow, FakeInputMethodDetector, FakeInputMethodInstaller) {
        let detector = FakeInputMethodDetector(found)
        let installer = FakeInputMethodInstaller(status, failure: failure)
        let opened = self.opened
        let flow = OnboardingFlow(detector: detector, installer: installer,
                                  shortcut: { shortcut }, englishLayout: { "U.S." },
                                  openKeyboardSettings: { opened.count += 1 })
        return (flow, detector, installer)
    }

    @Test("step 1 shows only while another input method runs")
    func conflictStepOnlyWhenRunning() {
        let (withConflict, _, _) = flow([openKey])
        withConflict.start()
        #expect(withConflict.step == .oldInputMethods)
        #expect(withConflict.conflicts.map(\.name) == ["OpenKey"])

        let installedOnly = DetectedInputMethod(name: "EVKey", bundleID: "x", isRunning: false, quitSteps: [])
        let (clear, _, _) = flow([installedOnly])
        clear.start()
        #expect(clear.step == .enable)
        #expect(clear.conflicts.isEmpty)
        #expect(clear.state(of: .oldInputMethods) == .done)
        #expect(!clear.canGoBack)
    }

    @Test("rechecking moves on once the other input method has quit")
    func recheck() {
        let (flow, detector, _) = flow([openKey])
        flow.start()
        flow.recheck()
        #expect(flow.step == .oldInputMethods)
        detector.found = []
        flow.refresh()   // the window became active again
        #expect(flow.step == .enable)
        #expect(flow.state(of: .oldInputMethods) == .done)
    }

    @Test("skipping keeps step 1 not done and allows going back")
    func skip() {
        let (flow, _, _) = flow([openKey])
        flow.start()
        flow.skip()
        #expect(flow.step == .enable)
        #expect(flow.state(of: .oldInputMethods) == .pending)
        #expect(flow.state(of: .enable) == .current)
        #expect(flow.canGoBack)
        flow.back()
        #expect(flow.step == .oldInputMethods)
    }

    /// Lets the main actor run until `condition` holds (the fake installer waits on a timer).
    func settle(_ condition: () -> Bool) async {
        for _ in 0..<400 where !condition() { try? await Task.sleep(for: .milliseconds(5)) }
    }

    @Test("enable installs first when needed, then step 2 is done and goes on")
    func enableThenNext() async {
        let (flow, _, installer) = flow(status: .notInstalled)
        flow.start()
        flow.next()   // not enabled yet: stays
        #expect(flow.step == .enable)
        #expect(flow.enableScreen == .ready)

        await flow.enable()
        #expect(installer.calls == ["install", "enable"])
        #expect(flow.status == .enabled)
        #expect(flow.enableScreen == .done)
        #expect(!flow.failed)
        #expect(!flow.isWorking)

        flow.next()
        #expect(flow.step == .typing)
        #expect(flow.state(of: .enable) == .done)
        #expect(flow.state(of: .typing) == .current)
        flow.back()
        #expect(flow.step == .enable)
    }

    @Test("clicking waits for the user's Allow: waiting, then done")
    func waitsForAllow() async {
        let (flow, _, installer) = flow(status: .installed(version: nil))
        installer.enableWaits = true
        flow.start()
        let run = Task { await flow.enable() }
        await settle { installer.enableWaiting }
        #expect(flow.isWorking)
        #expect(flow.enableScreen == .waiting)
        flow.next()   // not enabled yet
        #expect(flow.step == .enable)

        installer.release = .enabled
        await run.value
        #expect(!flow.isWorking)
        #expect(flow.enableScreen == .done)
        #expect(flow.problem == nil)
    }

    @Test("the wait ends with Dấu still off: failed screen, nothing opened by itself; macOS turning it on later is noticed")
    func waitExpires() async {
        let (flow, _, installer) = flow(status: .installed(version: nil))
        installer.enableOutcome = .notEnabled
        flow.start()
        await flow.enable()
        #expect(flow.problem == .notEnabled)
        #expect(flow.enableScreen == .notEnabled)
        #expect(opened.count == 0)
        flow.next()
        #expect(flow.step == .enable)
        // "Mở System Settings" opens the Keyboard pane (N4: only opens it).
        flow.openSystemSettings()
        #expect(opened.count == 1)
        // The user added Dấu by hand: the window notices and shows step 2 done.
        installer.current = .enabled
        flow.refresh()
        #expect(flow.problem == nil)
        #expect(flow.enableScreen == .done)
        flow.next()
        #expect(flow.step == .typing)
    }

    @Test("not listed by macOS: the same failed screen, nothing opened")
    func notListed() async {
        let (flow, _, installer) = flow(status: .notInstalled)
        installer.enableOutcome = .notListed
        flow.start()
        await flow.enable()
        #expect(installer.calls == ["install", "enable"])
        #expect(flow.problem == .notListed)
        #expect(flow.enableScreen == .notEnabled)
        #expect(opened.count == 0)
    }

    @Test("Thử lại cancels the wait that is running and asks again")
    func retryCancelsTheOldWait() async {
        let (flow, _, installer) = flow(status: .installed(version: nil))
        installer.enableWaits = true
        flow.start()
        let first = Task { await flow.enable() }
        await settle { installer.enableWaiting }
        let second = Task { await flow.enable() }
        // The first run was cancelled and left no state behind; the second is waiting.
        await first.value
        #expect(flow.isWorking)
        #expect(flow.problem == nil)
        #expect(flow.enableScreen == .waiting)
        await settle { installer.enableWaiting }
        #expect(installer.calls == ["enable", "enable"])

        installer.release = .enabled
        await second.value
        #expect(flow.enableScreen == .done)
        #expect(!flow.isWorking)
    }

    @Test("Quay lại while waiting cancels the wait")
    func backCancels() async {
        let (flow, _, installer) = flow([openKey], status: .installed(version: nil))
        installer.enableWaits = true
        flow.start()
        flow.skip()
        let run = Task { await flow.enable() }
        await settle { installer.enableWaiting }
        #expect(flow.enableScreen == .waiting)
        #expect(flow.canGoBack)
        flow.back()
        await run.value
        #expect(flow.step == .oldInputMethods)
        #expect(!flow.isWorking)
        #expect(flow.problem == nil)
        await settle { !installer.enableWaiting }
        #expect(!installer.enableWaiting)
        // The cancelled run left no state behind: back on step 2, the screen is "ready".
        flow.skip()
        #expect(flow.enableScreen == .ready)
        #expect(installer.calls == ["enable"])
    }

    /// Where step 2 is when "Quay lại" is looked at.
    enum BackState: Sendable { case ready, waiting, notEnabled, error, done, typing }
    struct BackCase: Sendable, CustomTestStringConvertible {
        var cameThroughStepOne: Bool
        var state: BackState
        var visible: Bool
        var testDescription: String { "step 1 \(cameThroughStepOne ? "shown" : "never shown"), \(state)" }
    }

    @Test("Quay lại on step 2 by state: shown on ready, waiting and error once step 1 was part of the onboarding; not on done or failed; never when step 1 never showed",
          arguments: [
              BackCase(cameThroughStepOne: true, state: .ready, visible: true),
              BackCase(cameThroughStepOne: true, state: .waiting, visible: true),
              BackCase(cameThroughStepOne: true, state: .notEnabled, visible: false),   // "Chưa bật được" keeps its own buttons
              BackCase(cameThroughStepOne: true, state: .error, visible: true),
              BackCase(cameThroughStepOne: true, state: .done, visible: false),         // after Dấu is on: no going back
              BackCase(cameThroughStepOne: true, state: .typing, visible: true),        // step 3 → step 2
              BackCase(cameThroughStepOne: false, state: .ready, visible: false),
              BackCase(cameThroughStepOne: false, state: .waiting, visible: false),
              BackCase(cameThroughStepOne: false, state: .notEnabled, visible: false),
              BackCase(cameThroughStepOne: false, state: .error, visible: false),
              BackCase(cameThroughStepOne: false, state: .done, visible: false),
          ])
    func backVisibility(_ c: BackCase) async {
        let (flow, detector, installer) = flow(c.cameThroughStepOne ? [openKey] : [], status: .installed(version: nil))
        flow.start()
        #expect(flow.cameThroughOldInputMethods == c.cameThroughStepOne)
        if c.cameThroughStepOne {
            #expect(!flow.canGoBack)   // step 1 itself
            detector.found = []   // quit the other input method: step 1 is done
            flow.refresh()
        }
        #expect(flow.step == .enable)
        switch c.state {
        case .ready: #expect(flow.enableScreen == .ready)
        case .waiting:
            installer.enableWaits = true
            let run = Task { await flow.enable() }
            await settle { installer.enableWaiting }
            #expect(flow.enableScreen == .waiting)
            #expect(flow.canGoBack == c.visible)
            installer.release = .notEnabled
            await run.value
            return
        case .notEnabled:
            installer.enableOutcome = .notEnabled
            await flow.enable()
            #expect(flow.enableScreen == .notEnabled)
        case .error:
            installer.failure = .invalidSignature
            await flow.enable()
            #expect(flow.enableScreen == .error)
        case .done, .typing:
            await flow.enable()
            #expect(flow.enableScreen == .done)
            if c.state == .typing { flow.next(); #expect(flow.step == .typing) }
        }
        #expect(flow.canGoBack == c.visible)
    }

    @Test("Quay lại is ignored when step 1 never showed; an input method started later does not bring step 1 into this onboarding")
    func noBackWithoutStepOne() {
        let (flow, _, _) = flow(status: .installed(version: nil))
        flow.start()
        flow.back()   // ignored
        #expect(flow.step == .enable)
        let (later, detector, _) = self.flow(status: .installed(version: nil))
        later.start()
        detector.found = [openKey]
        later.refresh()
        #expect(later.step == .enable)
        #expect(!later.canGoBack)
    }

    @Test("Quay lại goes to step 1 and rechecks: still running shows the conflict screen")
    func backWhileRunning() {
        let (flow, _, _) = flow([openKey], status: .installed(version: nil))
        flow.start()
        flow.skip()
        flow.back()
        #expect(flow.step == .oldInputMethods)
        #expect(flow.oldInputMethodsScreen == .conflict)
        #expect(flow.conflicts.map(\.name) == ["OpenKey"])
        flow.next()   // "Tiếp tục" is not on the conflict screen
        #expect(flow.step == .oldInputMethods)
    }

    @Test("Quay lại with the old input method quit: \"Đã tắt bộ gõ cũ\", which stays on activation; Tiếp tục goes to step 2")
    func backToDone() async {
        let (flow, detector, installer) = flow([openKey], status: .installed(version: nil))
        flow.start()
        detector.found = []
        flow.refresh()
        #expect(flow.step == .enable)
        installer.failure = .invalidSignature
        await flow.enable()
        #expect(flow.enableScreen == .error)
        flow.back()
        #expect(flow.step == .oldInputMethods)
        #expect(flow.oldInputMethodsScreen == .done)
        #expect(flow.foundOldInputMethods.map(\.name) == ["OpenKey"])
        // Step 1 is still the current one in the sidebar (artboard OnboardingConflictDone).
        #expect(flow.state(of: .oldInputMethods) == .current)
        #expect(flow.state(of: .enable) == .pending)
        #expect(!flow.canGoBack)
        // The window becoming active again does not move on by itself.
        flow.refresh()
        #expect(flow.step == .oldInputMethods)
        #expect(flow.oldInputMethodsScreen == .done)
        flow.next()   // "Tiếp tục"
        #expect(flow.step == .enable)
        // The error was dropped on the way back: the screen is "ready" again.
        #expect(flow.enableScreen == .ready)
        #expect(flow.errorDetail == nil)
        #expect(flow.canGoBack)
    }

    @Test("on \"Đã tắt bộ gõ cũ\", an old input method running again brings back the conflict screen")
    func conflictReturns() {
        let (flow, detector, _) = flow([openKey], status: .installed(version: nil))
        flow.start()
        detector.found = []
        flow.refresh()
        flow.back()
        #expect(flow.oldInputMethodsScreen == .done)
        let evKey = FakeInputMethodDetector.running("EVKey", bundleID: "com.lamquangminh.evkey")
        detector.found = [openKey, evKey]
        flow.refresh()   // the window became active
        #expect(flow.step == .oldInputMethods)
        #expect(flow.oldInputMethodsScreen == .conflict)
        #expect(flow.conflicts.map(\.name) == ["OpenKey", "EVKey"])
        // Quit again: "Đã tắt bộ gõ cũ" lists every one found in this onboarding.
        detector.found = []
        flow.refresh()
        #expect(flow.step == .oldInputMethods)
        #expect(flow.oldInputMethodsScreen == .done)
        #expect(flow.foundOldInputMethods.map(\.name) == ["OpenKey", "EVKey"])
        // A new start that finds nothing running forgets step 1 and skips it.
        flow.start()
        #expect(flow.step == .enable)
        #expect(flow.foundOldInputMethods.isEmpty)
        #expect(!flow.cameThroughOldInputMethods)
        #expect(!flow.canGoBack)
    }


    @Test("Thử lại after an error asks again and clears the detail; a failed step shows each kind of error")
    func retryAfterError() async {
        let (flow, _, installer) = flow(status: .installed(version: nil), failure: .failed("TISRegisterInputSource -50"))
        flow.start()
        await flow.enable()
        #expect(flow.enableScreen == .error)
        #expect(flow.errorDetail == InputMethodInstallerError.failed("TISRegisterInputSource -50").detail)
        // Only words: the status code stays in the log.
        #expect(flow.errorDetail?.contains("TIS") == false)
        installer.failure = nil
        await flow.enable()
        #expect(flow.enableScreen == .done)
        #expect(flow.errorDetail == nil)
        #expect(OnboardingFlow.describe(InputMethodInstallerError.invalidSignature).isEmpty == false)
        let other = OnboardingFlow.describe(CocoaError(.fileWriteNoPermission))
        #expect(other == "Something went wrong while copying or registering the input method.")
        #expect(SnapshotLocalization.text(other, "vi") == "Có lỗi khi chép hoặc đăng ký bộ gõ.")
        #expect(InputMethodInstallerError.failed("swap errno 13").detail.contains("errno") == false)
    }

    @Test("an error says so; step 2 stays")
    func failure() async {
        let (flow, _, installer) = flow(status: .installed(version: nil), failure: .unavailable)
        flow.start()
        await flow.enable()
        #expect(flow.failed)
        #expect(flow.problem == .failed)
        #expect(flow.enableScreen == .error)
        // "Chi tiết" is the error's own description, not a placeholder (N5).
        #expect(flow.errorDetail == InputMethodInstallerError.unavailable.detail)
        #expect(flow.errorDetail?.contains("[") == false)
        #expect(installer.calls == ["enable"])
        #expect(flow.step == .enable)
        flow.next()
        #expect(flow.step == .enable)
    }

    @Test("other Vietnamese input sources are a soft note, not step 1")
    func otherSources() {
        let (flow, detector, _) = flow()
        detector.otherSources = ["Tiếng Việt – Telex"]
        flow.start()
        #expect(flow.step == .enable)
        #expect(flow.otherSources == ["Tiếng Việt – Telex"])
    }

    @Test("enabled screen carries the log-out hint with macOS's own menu name (D37, D38)")
    func logOutHint() {
        let names = SystemUINames(languages: ["en"], tables: [:]) { _, _ in nil }
        let line = EnableStep.logOutHintPlain(logOut: names.logOut)
        #expect(line == "If an app can’t select Dấu yet, log out ( › Log Out) and log back in once.")
        let key = "If an app can’t select Dấu yet, log out (%@ › %@) and log back in once."
        #expect(String(format: SnapshotLocalization.text(key, "vi"), "", "Đăng xuất")
                == "Nếu một ứng dụng chưa chọn được Dấu, hãy đăng xuất ( › Đăng xuất) rồi đăng nhập lại một lần.")
    }

    @Test("already enabled: step 2 is done and goes straight on")
    func alreadyEnabled() async {
        let (flow, _, installer) = flow(status: .selected)
        flow.start()
        #expect(flow.step == .enable)
        #expect(flow.enableScreen == .done)
        await flow.enable()   // nothing to do
        #expect(installer.calls.isEmpty)
        flow.next()
        #expect(flow.step == .typing)
        #expect(flow.state(of: .enable) == .done)
    }

    @Test("start over resets the session; a forced step applies once")
    func restart() async {
        let (flow, _, installer) = flow([openKey], status: .installed(version: nil))
        flow.forcedStartStep = .typing
        flow.start()
        #expect(flow.step == .typing)
        flow.start()
        #expect(flow.step == .oldInputMethods)
        flow.skip()
        installer.enableOutcome = .notEnabled
        await flow.enable()
        #expect(flow.problem == .notEnabled)
        flow.start()
        #expect(flow.problem == nil)
    }

    @Test("reads the shortcut and the English layout on start")
    func readsSystem() {
        let shortcut = InputSourceShortcut(keys: ["⌃", "Space"], globeKey: false)
        let (flow, _, _) = flow(shortcut: .shortcut(shortcut))
        flow.start()
        #expect(flow.shortcut == .shortcut(shortcut))
        #expect(flow.englishLayout == "U.S.")
    }

    // MARK: Before step 1: "Chuyển Dấu vào Applications" (D37)

    @Test("not the owner copy and nothing installed: the move screen before step 1, no step started, nothing installs")
    func moveToApplications() async {
        let (flow, _, installer) = flow([openKey], status: .notInstalled)
        installer.ownerCopy = false
        flow.start()
        #expect(flow.needsMoveToApplications)
        // Before step 1, even with another input method running: this copy will be quit.
        for step in OnboardingFlow.Step.allCases { #expect(flow.state(of: step) == .pending) }
        #expect(!flow.canGoBack)
        // None of the steps' actions does anything from this screen.
        let step = flow.step
        flow.skip(); flow.next(); flow.back()
        await flow.enable()
        #expect(flow.step == step)
        #expect(installer.calls.isEmpty)
        #expect(flow.needsMoveToApplications)
        #expect(LaunchRouter.opensOnboarding(installer.status()))
    }

    @Test("the move screen's buttons: one opens the Applications folder, one quits; nothing else happens")
    func moveToApplicationsButtons() {
        final class Pressed { var folder = 0, quit = 0 }
        let pressed = Pressed()
        let installer = FakeInputMethodInstaller(.notInstalled)
        installer.ownerCopy = false
        let flow = OnboardingFlow(detector: FakeInputMethodDetector(), installer: installer,
                                  shortcut: { .unknown }, englishLayout: { nil }, openKeyboardSettings: {},
                                  openApplicationsFolder: { pressed.folder += 1 }, quit: { pressed.quit += 1 })
        flow.start()
        #expect(flow.needsMoveToApplications)
        flow.openApplicationsFolder()
        #expect((pressed.folder, pressed.quit) == (1, 0))
        flow.quit()
        #expect((pressed.folder, pressed.quit) == (1, 1))
        #expect(installer.calls.isEmpty)
    }

    @Test("the owner copy, or a copy that finds the input method installed, never sees the move screen; a copy that is not the owner only enables")
    func moveToApplicationsOnlyWhenNeeded() async {
        let (owner, _, ownerInstaller) = flow(status: .notInstalled)
        owner.start()
        #expect(!owner.needsMoveToApplications)
        await owner.enable()
        #expect(ownerInstaller.calls == ["install", "enable"])

        for status in [InputMethodStatus.installed(version: nil), .enabled, .selected, .unknown] {
            let (flow, _, installer) = flow(status: status)
            installer.ownerCopy = false
            flow.start()
            #expect(!flow.needsMoveToApplications)
        }

        // Installed by the owner copy, not enabled: step 2 enables without copying.
        let (flow, _, installer) = flow(status: .installed(version: nil))
        installer.ownerCopy = false
        flow.start()
        #expect(flow.step == .enable)
        #expect(flow.state(of: .enable) == .current)
        await flow.enable()
        #expect(installer.calls == ["enable"])
        #expect(flow.enableScreen == .done)
    }

    @Test("the move screen follows the system: it goes once this copy is the owner copy or the input method got installed, and comes when the input method goes away")
    func moveToApplicationsFollowsTheSystem() async {
        let (flow, _, installer) = flow([openKey], status: .notInstalled)
        installer.ownerCopy = false
        flow.start()
        #expect(flow.needsMoveToApplications)
        // The user copied this very build to Applications while it runs: the hashes match.
        installer.ownerCopy = true
        flow.refresh()
        #expect(!flow.needsMoveToApplications)
        #expect(flow.step == .oldInputMethods)
        #expect(flow.state(of: .oldInputMethods) == .current)

        // Not the owner copy, waiting for Allow, and the input method is removed meanwhile
        // (another copy uninstalled it): the wait ends, the move screen shows.
        let (waiting, _, waitingInstaller) = self.flow(status: .installed(version: nil))
        waitingInstaller.ownerCopy = false
        waitingInstaller.enableWaits = true
        waiting.start()
        let run = Task { await waiting.enable() }
        await settle { waitingInstaller.enableWaiting }
        waitingInstaller.current = .notInstalled
        waiting.refresh()
        #expect(waiting.needsMoveToApplications)
        #expect(!waiting.isWorking)
        await run.value
        #expect(waitingInstaller.calls == ["enable"])
    }

    // MARK: Installed with a wrong signature (D37 × D14; artboard OnboardingEnableTampered)

    @Test("installed, not on, wrong signature, owner copy: step 2 shows Cài lại instead of Bật Dấu; Cài lại installs and enables nothing, then Bật Dấu shows and enables")
    func tamperedAsksToReinstall() async {
        let (flow, _, installer) = flow(status: .installed(version: nil))
        installer.genuine = false
        flow.start()
        #expect(LaunchRouter.opensOnboarding(installer.status()))
        #expect(flow.step == .enable)
        #expect(flow.installedTampered)
        #expect(flow.enableScreen == .tampered)
        #expect(!flow.canGoBack)   // step 1 never showed
        await flow.reinstall()
        #expect(installer.calls == ["install"])
        #expect(!flow.installedTampered && !flow.isReinstalling)
        #expect(flow.enableScreen == .ready)
        #expect(flow.status == .installed(version: nil))
        await flow.enable()
        #expect(installer.calls == ["install", "enable"])
        #expect(flow.enableScreen == .done)
    }

    @Test("the Cài lại screen follows the system on activation, and has Quay lại by the rule of step 2")
    func tamperedFollowsSystem() async {
        let (flow, detector, installer) = flow([openKey], status: .installed(version: nil))
        flow.start()
        flow.skip()
        #expect(flow.enableScreen == .ready)
        // Replaced while the window was in the back.
        installer.genuine = false
        flow.refresh()
        #expect(flow.enableScreen == .tampered)
        #expect(flow.canGoBack)
        flow.back()
        #expect(flow.step == .oldInputMethods)
        detector.found = []
        flow.next()
        #expect(flow.enableScreen == .tampered)
        // Put right outside Dấu: the usual screen is back.
        installer.genuine = true
        flow.refresh()
        #expect(flow.enableScreen == .ready)
        #expect(installer.calls.isEmpty)
    }

    @Test("Bật Dấu never enables a copy with a wrong signature: one replaced after the last check, or while waiting for Allow, leads to Cài lại")
    func tamperedNeverEnabled() async {
        // Replaced after the screen was read: the installer refuses, the screen follows.
        let (flow, _, installer) = flow(status: .installed(version: nil))
        flow.start()
        #expect(flow.enableScreen == .ready)
        installer.genuine = false
        await flow.enable()
        #expect(installer.calls == ["enable"])
        #expect(installer.status() == .installed(version: nil))
        #expect(flow.enableScreen == .tampered)
        #expect(flow.problem == nil)

        // Found on activation while a wait for Allow runs: the wait is cancelled.
        let (waiting, _, waitingInstaller) = self.flow(status: .installed(version: nil))
        waiting.start()
        waitingInstaller.enableWaits = true
        let task = Task { await waiting.enable() }
        for _ in 0..<400 where !waitingInstaller.enableWaiting { try? await Task.sleep(for: .milliseconds(5)) }
        #expect(waiting.enableScreen == .waiting)
        waitingInstaller.genuine = false
        waiting.refresh()
        #expect(waiting.enableScreen == .tampered)
        await task.value
        #expect(!waiting.isWorking)
        #expect(waitingInstaller.status() == .installed(version: nil))
    }

    @Test("a failed Cài lại shows the install error with its detail; Thử lại reinstalls, never enables")
    func tamperedReinstallFails() async {
        let (flow, _, installer) = flow(status: .installed(version: nil), failure: .invalidSignature)
        installer.genuine = false
        flow.start()
        await flow.reinstall()
        #expect(flow.enableScreen == .error)
        #expect(flow.errorDetail == InputMethodInstallerError.invalidSignature.detail)
        #expect(flow.installedTampered)
        // The window coming to the front keeps the error.
        flow.refresh()
        #expect(flow.enableScreen == .error)
        installer.failure = nil
        await flow.enable()   // "Thử lại"
        #expect(installer.calls == ["install", "install"])
        #expect(flow.enableScreen == .ready)
        #expect(flow.errorDetail == nil)
    }

    @Test("a copy that is not the owner copy does not check the signature: Bật Dấu as before; an enabled Dấu never shows Cài lại in onboarding (D37)")
    func tamperedNotOwnerOrEnabled() async {
        let (flow, _, installer) = flow(status: .installed(version: nil))
        installer.genuine = false
        installer.ownerCopy = false
        flow.start()
        #expect(!flow.installedTampered)
        #expect(flow.enableScreen == .ready)
        await flow.reinstall()   // no screen leads here; nothing happens
        #expect(installer.calls.isEmpty)
        await flow.enable()
        #expect(installer.calls == ["enable"])
        #expect(flow.enableScreen == .done)

        // Already on: the Settings window's banner asks, step 2 stays done.
        let (enabled, _, enabledInstaller) = self.flow(status: .enabled)
        enabledInstaller.genuine = false
        enabled.start()
        #expect(!enabled.installedTampered)
        #expect(enabled.enableScreen == .done)
    }

    @Test("launch opens onboarding only when Dấu is known to be missing or off")
    func launch() {
        #expect(LaunchRouter.opensOnboarding(.notInstalled))
        #expect(LaunchRouter.opensOnboarding(.installed(version: "1.0")))
        #expect(!LaunchRouter.opensOnboarding(.enabled))
        #expect(!LaunchRouter.opensOnboarding(.selected))
        #expect(!LaunchRouter.opensOnboarding(.unknown))
    }

    @Test("known input methods: one entry per app, unique bundle IDs, quit steps name the app")
    func knownList() {
        let ids = KnownInputMethods.all.flatMap(\.bundleIDs)
        #expect(Set(ids).count == ids.count)
        // Bundle IDs from the released apps (docs/research/InputMethodInstall.md section 8).
        #expect(Set(ids) == ["com.tuyenmai.openkey", "com.lamquangminh.evkey", "com.trankynam.GoTiengViet",
                             "com.codetay.XKey", "com.phamhungtien.phtv", "org.gonhanh.GoNhanh", "com.goxkey.app"])
        // XKey's IMK input method is an input source (soft note), not a conflict.
        #expect(!ids.contains("com.codetay.inputmethod.XKey"))
        for entry in KnownInputMethods.all {
            #expect(KnownInputMethods.quitSteps(for: entry.name).allSatisfy { $0.contains(entry.name) })
        }
        // Unverified apps get the generic steps, which name no menu item (N5).
        #expect(KnownInputMethods.quitSteps(for: "EVKey").count == 2)
    }
}

@Suite("Input source shortcut reading (N5)")
struct ShortcutReadingTests {
    func entry(_ enabled: Bool) -> [String: Any] {
        ["enabled": enabled, "value": ["parameters": [32, 49, 262_144], "type": "standard"]]
    }

    @Test("shortcut, none, unknown")
    func readings() {
        let control = InputSourceShortcut(keys: ["⌃", "Space"], globeKey: false)
        #expect(InputSourceShortcut.reading(hotKeys: ["60": entry(true)], fnUsage: nil) == .shortcut(control))
        #expect(InputSourceShortcut.reading(hotKeys: ["60": entry(false), "61": entry(false)], fnUsage: 2) == .none)
        // The 🌐 key alone is a shortcut.
        #expect(InputSourceShortcut.reading(hotKeys: ["60": entry(false), "61": entry(false)], fnUsage: 1)
                == .shortcut(InputSourceShortcut(keys: [], globeKey: true)))
        // Entries missing: the system default applies, which is not guessed.
        #expect(InputSourceShortcut.reading(hotKeys: [:], fnUsage: 2) == .unknown)
        #expect(InputSourceShortcut.reading(hotKeys: ["60": entry(false)], fnUsage: 2) == .unknown)
        // The 🌐 setting unknown: it may switch input sources.
        #expect(InputSourceShortcut.reading(hotKeys: ["60": entry(false), "61": entry(false)], fnUsage: nil) == .unknown)
        #expect(InputSourceShortcut.reading(hotKeys: nil, fnUsage: nil) == .unknown)
    }

    @Test("inline text for running sentences")
    func inline() {
        #expect(InputSourceShortcut(keys: ["⌃", "Space"], globeKey: false).inlineText == "⌃Space")
        #expect(InputSourceShortcut(keys: [], globeKey: true).inlineText == "🌐")
        #expect(InputSourceShortcut(keys: ["⌃", "Space"], globeKey: true).inlineText == "⌃Space or 🌐")
        #expect(String(format: SnapshotLocalization.text("%@ or 🌐", "vi"), "⌃Space") == "⌃Space hoặc 🌐")
    }
}

@MainActor
@Suite("Shortcut drawn as keycaps in onboarding sentences (N5)")
struct ShortcutSentenceTests {
    let control = InputSourceShortcut(keys: ["⌃", "Space"], globeKey: false)
    let marker = ShortcutSentence.marker

    @Test("the Done sentence splits around the keys, in English and Vietnamese")
    func doneSentence() throws {
        let english = ChooseDauLine.sentence(englishLayout: "U.S.")
        let parts = try #require(ShortcutSentence.parts(of: english))
        #expect(parts == ShortcutSentence.Parts(before: "Choose Dấu from the Input menu, or press",
                                                after: "to switch between Dấu and “U.S.”.",
                                                spaceBefore: true, spaceAfter: true))
        #expect(ShortcutSentence.spoken(english, shortcut: control)
                == "Choose Dấu from the Input menu, or press ⌃Space to switch between Dấu and “U.S.”.")
        let key = "Choose Dấu from the Input menu, or press %@ to switch between Dấu and “%@”."
        let vietnamese = String(format: SnapshotLocalization.text(key, "vi"), marker, "U.S.")
        let vi = try #require(ShortcutSentence.parts(of: vietnamese))
        #expect(vi.before == "Chọn Dấu trên menu nguồn đầu vào, hoặc nhấn")
        #expect(vi.after == "để chuyển giữa Dấu và “U.S.”.")
        // No English layout name: the other sentence, same split.
        let general = try #require(ShortcutSentence.parts(of: ChooseDauLine.sentence(englishLayout: nil)))
        #expect(general.after == "to switch between Dấu and an English keyboard.")
        // No placeholder line about the shortcut anywhere (N5).
        #expect(!english.contains("("))
    }

    @Test("the step 3 hint keeps the comma against the keys")
    func notActiveSentence() throws {
        let english = TypingStep.notActiveSentence(dauInputSource: "Dấu – Vietnamese")
        let parts = try #require(ShortcutSentence.parts(of: english))
        #expect(parts.before == "Dấu isn’t the current input source: choose “Dấu – Vietnamese” from the Input menu or press")
        #expect(parts.after == ", then try typing.")
        #expect(parts.spaceBefore && !parts.spaceAfter)
        let key = "Dấu isn’t the current input source: choose “%@” from the Input menu or press %@, then try typing."
        let vietnamese = String(format: SnapshotLocalization.text(key, "vi"), "Dấu – Tiếng Việt", marker)
        let vi = try #require(ShortcutSentence.parts(of: vietnamese))
        #expect(vi.before == "Dấu chưa phải nguồn đầu vào đang dùng: chọn “Dấu – Tiếng Việt” trên menu nguồn đầu vào hoặc nhấn")
        #expect(vi.after == "rồi gõ thử.")
        #expect(vi.spaceBefore && vi.spaceAfter)
        #expect(ShortcutSentence.words(vi.after) == ["rồi", "gõ", "thử."])
    }

    @Test("a sentence without the marker is not split")
    func noMarker() {
        #expect(ShortcutSentence.parts(of: "Choose Dấu from the Input menu.") == nil)
    }
}

@Suite("Onboarding try-it hint")
struct TryItSampleTests {
    @Test("the hint's keys type the mockup sentence (N5)", arguments: DauSettings.TypingMethod.allCases)
    func tryIt(_ method: DauSettings.TypingMethod) {
        #expect(SettingsSamples.tryIt(method).result == "tôi yêu tiếng Việt")
    }
}
