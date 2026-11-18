import Foundation
import Sparkle

// Sparkle in the host app (D7). The only file that imports Sparkle: the unit-test package
// (Apps/Dau/Tests) leaves it out and tests the rest through `UpdaterBackend`.

/// Starts Sparkle's standard updater at launch, on the official build only.
///
/// `SPUStandardUpdaterController` brings Sparkle's own windows (update found, download,
/// install; Vietnamese and English, D7, D41), so Dấu has no user driver of its own. Its
/// settings come from Info.plist: automatic checks on, once a day, never installing in the
/// background (`SUAllowsAutomaticUpdates` false: Sparkle asks first), no system profile
/// (D8). The feed URL and the public key exist only on the official build
/// (`UpdaterConfiguration`); any other build gets no updater, so Sparkle never runs there.
///
/// After an update Sparkle relaunches Dấu from where it installed it, and that launch's
/// `DauApp.reconcileAtLaunch` replaces the installed input method with the new embedded
/// one (D37), while the user is in Dấu rather than typing in another app (D7). Dấu adds no
/// relaunch step of its own.
@MainActor
enum SparkleUpdater {
    /// The updater for this app, started; nil when this build has no feed and key.
    static func startIfConfigured() -> UpdatesModel? {
        guard UpdaterConfiguration.isConfiguredForThisApp else { return nil }
        // The channel exists before Sparkle starts, so its delegate can always answer.
        let channels = ReleaseChannels(store: DefaultsReleaseChannelStore())
        return UpdatesModel(backend: SparkleUpdaterBackend(channels: channels), channels: channels)
    }
}

/// `UpdaterBackend` on Sparkle's `SPUUpdater`. The three properties the page shows are
/// KVO compliant in Sparkle 2 (SPUUpdater.h; `lastUpdateCheckDate` posts its change in
/// `updateLastUpdateCheckDate`), so the page follows them by key-value observing.
@MainActor
final class SparkleUpdaterBackend: UpdaterBackend {
    private let controller: SPUStandardUpdaterController
    /// Sparkle holds its delegate weakly: this keeps it alive as long as the updater.
    private let delegate: SparkleChannelDelegate
    private var observations: [NSKeyValueObservation] = []

    init(channels: ReleaseChannels) {
        delegate = SparkleChannelDelegate(channels: channels)
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: delegate, userDriverDelegate: nil)
    }

    private var updater: SPUUpdater { controller.updater }

    var canCheckForUpdates: Bool { updater.canCheckForUpdates }
    var lastUpdateCheckDate: Date? { updater.lastUpdateCheckDate }

    var automaticallyChecksForUpdates: Bool {
        get { updater.automaticallyChecksForUpdates }
        set { updater.automaticallyChecksForUpdates = newValue }
    }

    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }

    func observeChanges(_ changed: @escaping @MainActor @Sendable () -> Void) {
        // Sparkle changes these on the main thread; hop there anyway, KVO calls back on
        // the thread that made the change.
        let notify: @Sendable () -> Void = { Task { @MainActor in changed() } }
        observations = [
            updater.observe(\.canCheckForUpdates) { _, _ in notify() },
            updater.observe(\.lastUpdateCheckDate) { _, _ in notify() },
            updater.observe(\.automaticallyChecksForUpdates) { _, _ in notify() },
        ]
    }

    func allowedChannelsChanged() {
        // SPUUpdater.h: "should only be called in response to a user changing updater
        // settings … may trigger a new update check … if … allowed channels has changed".
        // The short delay lets a quick change back cancel it.
        updater.resetUpdateCycleAfterShortDelay()
    }
}

/// Sparkle's updater delegate for the release channel (D7, "Kênh"); the logic and the
/// call order it relies on are documented on `ReleaseChannels` (Updater.swift).
/// `SPUUpdaterDelegate` is `NS_SWIFT_UI_ACTOR` in Sparkle 2.10.1: both calls come on the
/// main actor.
final class SparkleChannelDelegate: NSObject, SPUUpdaterDelegate {
    private let channels: ReleaseChannels

    init(channels: ReleaseChannels) {
        self.channels = channels
    }

    /// `allowedChannelsForUpdater:`: Sparkle filters the loaded appcast with this set
    /// (the default channel is always included).
    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        channels.allowedAppcastChannels
    }

    /// `updater:didFinishLoadingAppcast:`: called after a successful download and parse,
    /// with every item of the feed (before the channel filter), and before Sparkle asks
    /// for the allowed channels in the same pass (SUAppcastDriver.m, 2.10.1).
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        // A feed whose signature failed (Sparkle may go on for a while to report the
        // error later) decides nothing.
        guard appcast.signingValidationStatus != .failed else { return }
        // The items Sparkle would consider at all: macOS, full (not delta) updates.
        let items = appcast.items.filter { $0.isMacOsUpdate && !$0.isDeltaUpdate }
        channels.appcastLoaded(itemChannels: items.map(\.channel))
    }
}
