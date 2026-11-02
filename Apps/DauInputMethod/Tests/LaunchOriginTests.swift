import Testing

/// Signals as measured on macOS 27.2 (02/11/2026): see LaunchOrigin.swift.
@Suite("LaunchPolicy (user launch opens the host app)")
struct LaunchOriginTests {
    static let ownPID: Int32 = 38_139
    static let aevt = LaunchEvent.coreEventClass
    static let oapp = LaunchEvent.openApplication
    /// 'rapp' (kAEReopenApplication), 'odoc' (kAEOpenDocuments).
    static let rapp: UInt32 = 0x7261_7070
    static let odoc: UInt32 = 0x6F64_6F63

    @Test("system launch: the oapp AppKit makes up, sent by the process itself")
    func systemLaunch() {
        let event = LaunchEvent(eventClass: Self.aevt, eventID: Self.oapp, senderPID: Self.ownPID)
        #expect(LaunchPolicy.origin(of: event, ownPID: Self.ownPID) == .system)
        #expect(event.senderKind(ownPID: Self.ownPID) == "self")
    }

    @Test("Finder double-click: a real oapp from another process")
    func finderLaunch() {
        let event = LaunchEvent(eventClass: Self.aevt, eventID: Self.oapp, senderPID: 47_570)
        #expect(LaunchPolicy.origin(of: event, ownPID: Self.ownPID) == .user)
        #expect(event.senderKind(ownPID: Self.ownPID) == "other")
    }

    @Test("no event, unknown sender or another event: keep running (system)")
    func unsureIsSystem() {
        let cases = [
            LaunchEvent(eventClass: nil, eventID: nil, senderPID: nil),
            LaunchEvent(eventClass: Self.aevt, eventID: Self.oapp, senderPID: nil),
            LaunchEvent(eventClass: Self.aevt, eventID: Self.oapp, senderPID: 0),
            LaunchEvent(eventClass: Self.aevt, eventID: Self.oapp, senderPID: -1),
            LaunchEvent(eventClass: Self.aevt, eventID: Self.rapp, senderPID: 47_570),
            LaunchEvent(eventClass: Self.aevt, eventID: Self.odoc, senderPID: 47_570),
            LaunchEvent(eventClass: 0x6D69_7363 /* misc */, eventID: Self.oapp, senderPID: 47_570),
        ]
        for event in cases {
            #expect(LaunchPolicy.origin(of: event, ownPID: Self.ownPID) == .system)
        }
        #expect(LaunchEvent(eventClass: nil, eventID: nil, senderPID: nil).senderKind(ownPID: 1) == "none")
    }

    @Test("quit after a user launch only while no client has activated")
    func quit() {
        #expect(LaunchPolicy.quitsAfterOpeningHostApp(origin: .user, clientActivated: false))
        #expect(!LaunchPolicy.quitsAfterOpeningHostApp(origin: .user, clientActivated: true))
        #expect(!LaunchPolicy.quitsAfterOpeningHostApp(origin: .system, clientActivated: false))
        #expect(!LaunchPolicy.quitsAfterOpeningHostApp(origin: .system, clientActivated: true))
    }

    @Test("reopen opens the host app once the launch has settled")
    func reopen() {
        #expect(LaunchPolicy.opensHostAppOnReopen(secondsSinceLaunch: 12))
        #expect(LaunchPolicy.opensHostAppOnReopen(secondsSinceLaunch: LaunchPolicy.reopenSettleSeconds))
        #expect(!LaunchPolicy.opensHostAppOnReopen(secondsSinceLaunch: 0.2))
        #expect(!LaunchPolicy.opensHostAppOnReopen(secondsSinceLaunch: nil))
        #expect(!LaunchPolicy.opensHostAppOnReopen(secondsSinceLaunch: .nan))
        #expect(!LaunchPolicy.opensHostAppOnReopen(secondsSinceLaunch: -.infinity))
    }
}
