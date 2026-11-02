/// Who started the input method process, and what to do about it.
///
/// The bundle is `LSBackgroundOnly`: launched by the user (Finder double-click) it would
/// show nothing. So a user launch opens the host app (Dấu, Settings) and the process
/// quits; a launch by the system to serve typing keeps running as before.
///
/// Signals measured on macOS 27.2 (02/11/2026, ARCHITECTURE.md "Khởi chạy bộ gõ"):
/// - System (imklaunchagent asks LaunchServices, no launch event, flags dontSwitch):
///   no Apple event reaches the app; in `applicationDidFinishLaunching` the current
///   event is the `aevt/oapp` that AppKit makes up, whose sender is the process itself.
/// - Finder double-click (Finder › Open): LaunchServices sends a real `aevt/oapp`; its
///   sender PID is another process.
/// - Any launch request while the process already runs (Finder, `open`, NSWorkspace,
///   with or without dontSwitch): no new process; the running one gets `aevt/rapp`.
/// - `open` from Terminal with no process running: no Apple event either, same as the
///   system. Indistinguishable with public API (only LaunchServices sees the flags), so
///   it is treated as a system launch: keep running (the safe default).
///
/// Pure value logic, unit-tested; `InputMethodAppDelegate` reads the event.
enum LaunchOrigin: String, Equatable, Sendable {
    case user
    case system
}

/// The launch Apple event as seen in `applicationDidFinishLaunching`.
struct LaunchEvent: Equatable, Sendable {
    /// `kCoreEventClass` ('aevt').
    static let coreEventClass: UInt32 = 0x6165_7674
    /// `kAEOpenApplication` ('oapp').
    static let openApplication: UInt32 = 0x6F61_7070

    /// nil: no current Apple event.
    var eventClass: UInt32?
    var eventID: UInt32?
    /// `keySenderPIDAttr` of the event; nil if missing.
    var senderPID: Int32?

    init(eventClass: UInt32?, eventID: UInt32?, senderPID: Int32?) {
        self.eventClass = eventClass
        self.eventID = eventID
        self.senderPID = senderPID
    }

    /// For the log (D8: flags only).
    func senderKind(ownPID: Int32) -> String {
        guard let senderPID else { return "none" }
        return senderPID == ownPID ? "self" : "other"
    }
}

enum LaunchPolicy {
    /// Reopen events in this window after launch are ignored: a second launch request
    /// that raced the first one (not observed; precaution against the system asking
    /// twice while the process starts) must not open the host app.
    static let reopenSettleSeconds: Double = 1

    /// User only for a real "open application" event sent by another process.
    /// Anything else (no event, the event AppKit makes up, another event, an unknown
    /// sender) is a system launch: keep running.
    static func origin(of event: LaunchEvent, ownPID: Int32) -> LaunchOrigin {
        guard event.eventClass == LaunchEvent.coreEventClass,
              event.eventID == LaunchEvent.openApplication,
              let sender = event.senderPID, sender > 0, sender != ownPID else { return .system }
        return .user
    }

    /// Reopen (the user opened the bundle while this process runs): open the host app,
    /// unless it comes right after launch. Never quits: this process may be serving typing.
    static func opensHostAppOnReopen(secondsSinceLaunch: Double?) -> Bool {
        guard let secondsSinceLaunch, secondsSinceLaunch.isFinite else { return false }
        return secondsSinceLaunch >= reopenSettleSeconds
    }

    /// Quit after a user launch only if no client has activated the input method
    /// meanwhile (D18 spirit: never exit while typing could need it).
    static func quitsAfterOpeningHostApp(origin: LaunchOrigin, clientActivated: Bool) -> Bool {
        origin == .user && !clientActivated
    }
}
