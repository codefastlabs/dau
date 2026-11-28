import Foundation
import Observation
import DauShared
import os

/// The host app's view of the shared settings. Every change is saved right away to the
/// App Group suite, which posts the change notification the input method listens to.
/// Changes made elsewhere (the input method's "Typing method" menu) are reloaded the same way.
@MainActor
@Observable
final class SettingsModel {
    var settings: DauSettings {
        didSet {
            guard settings != oldValue, !isReloading else { return }
            store.save(settings)
            keepBackup()
        }
    }

    /// Apps labelled "Suggested" on the Apps page (D13). Bundled with the app and updated
    /// with it (D7). Not shared with the input method.
    @ObservationIgnored let compatibility: CompatibilityList
    @ObservationIgnored private let store: SettingsStore
    /// The copy of the App Group in the app's own defaults, refreshed at every load and
    /// save (D24); nil when the store is not an App Group.
    @ObservationIgnored private let backup: SettingsBackup?
    @ObservationIgnored private var observer: SettingsChangeObserver?
    @ObservationIgnored private var isReloading = false

    init(store: SettingsStore, backup: SettingsBackup? = nil,
         compatibility: CompatibilityList = .bundled()) {
        self.store = store
        self.backup = backup
        self.compatibility = compatibility
        self.settings = store.load()
        keepBackup()
        observer = store.observeChanges { [weak self] in
            // Delivered on the main queue (observeChanges default).
            MainActor.assumeIsolated { self?.reload() }
        }
    }

    /// The App Group store declared in Info.plist, after bringing the settings of a
    /// previous App Group into it when it is empty (D24). Falls back to the app's own
    /// defaults when no App Group is available, so Settings stays usable; the input
    /// method will not see those changes.
    static func appGroup() -> SettingsModel {
        if let store = SettingsStore.appGroup(), let group = SettingsStore.appGroupIdentifier() {
            let backup = SettingsBackup(defaults: .standard, groupIdentifier: group)
            logCarryOver(backup.carryOver(into: store))
            return SettingsModel(store: store, backup: backup)
        }
        Logger.settings.error("No App Group suite; settings stay local to the app")
        return SettingsModel(store: SettingsStore(
            defaults: .standard, suiteName: Bundle.main.bundleIdentifier ?? "Dau"))
    }

    private static func logCarryOver(_ outcome: SettingsCarryOver) {
        if case .carriedOver(let source) = outcome {
            Logger.settings.notice("event=settings-carried-over from=\(source, privacy: .public)")
        }
    }

    private func keepBackup() {
        backup?.record(store)
    }

    private func reload() {
        let loaded = store.load()
        keepBackup()
        guard loaded != settings else { return }
        isReloading = true
        settings = loaded
        isReloading = false
    }
}

extension Logger {
    static let settings = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Dau", category: "settings")
}
