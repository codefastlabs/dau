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
        return UpdatesModel(backend: SparkleUpdaterBackend())
    }
}

/// `UpdaterBackend` on Sparkle's `SPUUpdater`. The three properties the page shows are
/// KVO compliant in Sparkle 2 (SPUUpdater.h; `lastUpdateCheckDate` posts its change in
/// `updateLastUpdateCheckDate`), so the page follows them by key-value observing.
@MainActor
final class SparkleUpdaterBackend: UpdaterBackend {
    private let controller: SPUStandardUpdaterController
    private var observations: [NSKeyValueObservation] = []

    init() {
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
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
}
