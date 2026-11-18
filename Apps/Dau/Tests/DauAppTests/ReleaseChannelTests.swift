import AppKit
import SwiftUI
import Testing
import DauShared
@testable import Dau

// D7, "Kênh": beta items carry Sparkle's channel `beta`, untagged items are stable. The
// default is written once, at the first appcast load (no stable item: Beta; one: Stable);
// afterwards only the user changes it. Sparkle is not linked here: the appcast is the
// list of item channels its delegate passes on (`SparkleChannelDelegate`), the store an
// in-memory fake: no test writes the user's preferences. No network, no window on screen.

@MainActor
final class FakeChannelStore: ReleaseChannelStore {
    var channel: ReleaseChannel?
    var stableReleaseExists: Bool?
    init(channel: ReleaseChannel? = nil, stableReleaseExists: Bool? = nil) {
        self.channel = channel
        self.stableReleaseExists = stableReleaseExists
    }
}

/// Appcasts as `SUAppcast.items.map(\.channel)`.
private enum Feed {
    /// Before the first stable release: betas only.
    static let betasOnly: [String?] = ["beta", "beta"]
    /// After it: the promoted last beta has lost its tag, a newer beta follows.
    static let withStable: [String?] = ["beta", nil, "beta"]
}

@MainActor
@Suite("Release channel (D7)")
struct ReleaseChannelTests {
    @Test("before the first appcast: no channel, only the default (stable) channel allowed")
    func beforeFirstLoad() {
        let channels = ReleaseChannels(store: FakeChannelStore())
        #expect(channels.channel == nil && channels.stableReleaseExists == nil)
        // Whatever order Sparkle asks in, this never offers a beta to a future Stable user.
        #expect(channels.allowedAppcastChannels.isEmpty)
        #expect(!channels.canChoose(.stable))
    }

    @Test("installed before any stable release: Beta is the default, Stable is off")
    func defaultBeta() {
        let store = FakeChannelStore()
        let channels = ReleaseChannels(store: store)
        channels.appcastLoaded(itemChannels: Feed.betasOnly)
        #expect(channels.channel == .beta && store.channel == .beta)
        #expect(channels.stableReleaseExists == false && store.stableReleaseExists == false)
        #expect(channels.allowedAppcastChannels == ["beta"])
        #expect(!channels.canChoose(.stable))
        #expect(!channels.choose(.stable))
        #expect(channels.channel == .beta)
    }

    @Test("installed once a stable release exists: Stable is the default")
    func defaultStable() {
        let store = FakeChannelStore()
        let channels = ReleaseChannels(store: store)
        channels.appcastLoaded(itemChannels: Feed.withStable)
        #expect(channels.channel == .stable && store.channel == .stable)
        #expect(channels.stableReleaseExists == true)
        #expect(channels.allowedAppcastChannels == [])
    }

    @Test("a stable release appearing later switches nobody; Stable becomes choosable")
    func noAutoSwitch() {
        let store = FakeChannelStore()
        let first = ReleaseChannels(store: store)
        first.appcastLoaded(itemChannels: Feed.betasOnly)
        first.appcastLoaded(itemChannels: Feed.withStable)
        #expect(first.channel == .beta && first.stableReleaseExists == true)
        #expect(first.canChoose(.stable))
        // Next launch: read back from the store, and still Beta after another load.
        let next = ReleaseChannels(store: store)
        #expect(next.channel == .beta && next.stableReleaseExists == true)
        next.appcastLoaded(itemChannels: Feed.withStable)
        #expect(next.channel == .beta)
    }

    @Test("the user's choice sticks and sets the allowed channels")
    func choose() {
        let store = FakeChannelStore(channel: .beta, stableReleaseExists: true)
        let channels = ReleaseChannels(store: store)
        #expect(channels.choose(.stable))
        #expect(store.channel == .stable && channels.allowedAppcastChannels == [])
        #expect(!channels.choose(.stable))
        channels.appcastLoaded(itemChannels: Feed.withStable)
        #expect(channels.channel == .stable)
        #expect(channels.choose(.beta))
        #expect(store.channel == .beta && channels.allowedAppcastChannels == ["beta"])
    }

    @Test("allowed channels per choice")
    func allowed() {
        #expect(ReleaseChannel.beta.allowedAppcastChannels == ["beta"])
        #expect(ReleaseChannel.stable.allowedAppcastChannels == [])
    }

    @Test("a stable release is an untagged item; other channels and an empty feed are not")
    func stableDetection() {
        func exists(_ items: [String?]) -> Bool? {
            let channels = ReleaseChannels(store: FakeChannelStore())
            channels.appcastLoaded(itemChannels: items)
            return channels.stableReleaseExists
        }
        #expect(exists([nil]) == true)
        #expect(exists(["beta", nil]) == true)
        #expect(exists(["beta"]) == false)
        #expect(exists(["nightly", "beta"]) == false)
        #expect(exists([]) == false)
    }

    @Test("the page passes a change on to the updater, once, and nothing when it is refused")
    func model() {
        let fake = FakeUpdater()
        let channels = ReleaseChannels(store: FakeChannelStore())
        let model = UpdatesModel(backend: fake, channels: channels)
        channels.appcastLoaded(itemChannels: Feed.betasOnly)
        model.chooseChannel(.stable)
        model.chooseChannel(.beta)
        #expect(fake.channelResets == 0)
        channels.appcastLoaded(itemChannels: Feed.withStable)
        model.chooseChannel(.stable)
        model.chooseChannel(.stable)
        #expect(fake.channelResets == 1 && channels.channel == .stable)
    }

    @Test("the Vietnamese wording follows the artboard")
    func vietnamese() {
        #expect(Catalog.text("Release channel", "vi") == "Kênh phát hành")
        #expect(Catalog.text("Beta", "vi") == "Beta")
        #expect(Catalog.text("Stable", "vi") == "Chính thức")
        #expect(Catalog.text("Beta: the latest builds, for trying out and giving feedback. There is no stable release yet; once there is, you can choose the Stable channel.", "vi")
                == "Beta: bản mới nhất, để dùng thử và góp ý. Chưa có bản chính thức nào; khi có, bạn chọn được kênh Chính thức.")
        #expect(Catalog.text("Beta: the latest builds, for trying out and giving feedback. Stable: finished releases only. If you switch to Stable, Dấu keeps the version you have until a newer stable release comes out.", "vi")
                == "Beta: bản mới nhất, để dùng thử và góp ý. Chính thức: chỉ bản đã chốt. Chuyển sang Chính thức thì Dấu giữ bản đang dùng tới khi có bản chính thức mới hơn.")
    }
}

/// The row on the page, laid out in a window that is never shown: absent before the
/// first appcast, then the system segmented control with Stable off until a stable
/// release exists (artboard SettingsAbout, `stage`).
@MainActor
@Suite("Release channel row (D7)")
struct ReleaseChannelRowTests {
    func segmentedControls(in view: NSView) -> [NSSegmentedControl] {
        view.subviews.flatMap { ($0 as? NSSegmentedControl).map { [$0] } ?? segmentedControls(in: $0) }
    }

    /// The Updates & Support page with `channels`; the segmented controls on it and
    /// whether the row reported a frame.
    func layout(_ channels: ReleaseChannels) -> (controls: [NSSegmentedControl], row: Bool) {
        // The page needs a settings model; its store is only read here (nothing is saved,
        // so no preferences file is made). A fresh suite name each time: never an earlier
        // run's state, and nothing to delete afterwards.
        let suite = "dau.tests.channelrow.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        let model = SettingsModel(store: SettingsStore(defaults: defaults, suiteName: suite))
        var frames: [String: CGRect] = [:]
        let environment = SettingsEnvironment(
            model: model, inputSource: InputSourceStatus(fixed: true), actions: nil,
            layoutProbe: { name, frame in frames[name] = frame.isNull ? nil : frame },
            openWindow: nil,
            updates: UpdatesModel(backend: FakeUpdater(), channels: channels))
        let state = SettingsWindowState(.updates)
        let controller = SettingsSplitViewController(sidebar: SettingsSidebarRoot(state: state, environment: environment),
                                                     detail: SettingsDetailRoot(state: state, environment: environment))
        let window = NSWindow(contentRect: CGRect(origin: .zero, size: SettingsScene.defaultSize),
                              styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                              backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        window.contentViewController = controller
        for _ in 0..<20 {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
            controller.view.layoutSubtreeIfNeeded()
        }
        let controls = segmentedControls(in: controller.view)
        // Read before taking the page down: its probes then report `.null`.
        let row = frames["releaseChannel"] != nil
        window.contentViewController = nil
        return (controls, row)
    }

    @Test("no row before the first appcast (N5: the stage is unknown)")
    func hiddenBeforeLoad() {
        let result = layout(ReleaseChannels(store: FakeChannelStore()))
        #expect(!result.row && result.controls.isEmpty)
    }

    @Test("no stable release: Beta selected, Stable shown but off")
    func noStable() throws {
        let channels = ReleaseChannels(store: FakeChannelStore())
        channels.appcastLoaded(itemChannels: Feed.betasOnly)
        let result = layout(channels)
        #expect(result.row)
        let control = try #require(result.controls.first)
        #expect(control.segmentCount == 2)
        #expect(control.selectedSegment == 0)
        #expect(control.isEnabled(forSegment: 0) && !control.isEnabled(forSegment: 1))
    }

    @Test("a stable release exists: both on, the user's channel selected")
    func withStable() throws {
        let channels = ReleaseChannels(store: FakeChannelStore())
        channels.appcastLoaded(itemChannels: Feed.withStable)
        let control = try #require(layout(channels).controls.first)
        #expect(control.selectedSegment == 1)
        #expect(control.isEnabled(forSegment: 0) && control.isEnabled(forSegment: 1))
    }

    /// Regression (18/11/2026, `--capture-updates`): SwiftUI read the control's binding on
    /// NSHostingView's asynchronous rendering thread, and a `Binding(get:set:)` made of
    /// main-actor closures trapped there (Swift 6 executor check). A window that is never
    /// shown renders on the main thread only, so the test reads the row's binding off the
    /// main thread itself, as that rendering does.
    @Test("the channel binding can be read off the main thread")
    func bindingOffMain() async {
        let channels = ReleaseChannels(store: FakeChannelStore())
        channels.appcastLoaded(itemChannels: Feed.withStable)
        let binding = ReleaseChannelRow.selection(UpdatesModel(backend: FakeUpdater(), channels: channels))
        let read = await withCheckedContinuation { (continuation: CheckedContinuation<ReleaseChannel, Never>) in
            let box = UncheckedBox(binding)
            Thread.detachNewThread { continuation.resume(returning: box.value.wrappedValue) }
        }
        #expect(read == .stable)
    }
}

/// Hands a value to another thread in a test (the binding is read there on purpose).
final class UncheckedBox<Value>: @unchecked Sendable {
    let value: Value
    init(_ value: Value) { self.value = value }
}
