import AppKit
import os

/// Application delegate of the input method process: tells a user launch from a system
/// launch (`LaunchPolicy`) and opens the host app for the user.
///
/// - User launch (Finder double-click): open the host app, then quit unless a client
///   activated the input method meanwhile.
/// - Reopen (the user opens the bundle while this process runs, e.g. `open` or Finder):
///   open the host app, keep running (this process may be serving typing).
/// - System launch: nothing changes.
@MainActor
final class InputMethodAppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DauInputMethod", category: "launch")
    /// `ProcessInfo.systemUptime` at `applicationDidFinishLaunching`.
    private var launchedAt: TimeInterval?
    private var clientActivated = false
    private var activationObserver: NSObjectProtocol?

    override init() {
        super.init()
        activationObserver = NotificationCenter.default.addObserver(
            forName: .dauClientActivated, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.clientActivated = true }
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        launchedAt = ProcessInfo.processInfo.systemUptime
        let ownPID = ProcessInfo.processInfo.processIdentifier
        let event = Self.currentLaunchEvent()
        let origin = LaunchPolicy.origin(of: event, ownPID: ownPID)
        logger.notice("event=launch origin=\(origin.rawValue, privacy: .public) oapp=\(event.eventID == LaunchEvent.openApplication, privacy: .public) sender=\(event.senderKind(ownPID: ownPID), privacy: .public)")
        guard origin == .user else { return }
        HostApp.open(logger: logger) { [weak self] _ in
            guard let self else { return }
            if LaunchPolicy.quitsAfterOpeningHostApp(origin: origin, clientActivated: self.clientActivated) {
                self.logger.notice("event=user-launch-quit")
                exit(0)
            }
            self.logger.notice("event=user-launch-stay reason=client-activated")
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        let since = launchedAt.map { ProcessInfo.processInfo.systemUptime - $0 }
        if LaunchPolicy.opensHostAppOnReopen(secondsSinceLaunch: since) {
            logger.notice("event=reopen action=open-host-app")
            HostApp.open(logger: logger)
        } else {
            logger.notice("event=reopen action=ignored-settling")
        }
        return false
    }

    /// The Apple event being handled (the launch `oapp` inside
    /// `applicationDidFinishLaunching`); empty fields if none (D18).
    private static func currentLaunchEvent() -> LaunchEvent {
        guard let event = NSAppleEventManager.shared().currentAppleEvent else {
            return LaunchEvent(eventClass: nil, eventID: nil, senderPID: nil)
        }
        let sender = event.attributeDescriptor(forKeyword: AEKeyword(keySenderPIDAttr))?.int32Value
        return LaunchEvent(eventClass: event.eventClass, eventID: event.eventID, senderPID: sender)
    }
}
