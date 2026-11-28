import Foundation
import Testing
import DauShared
@testable import Dau

/// D24: the Settings model keeps the app's copy of the App Group current, at load and at
/// every save, so the copy is there when a build of another team opens an empty group.
@MainActor
@Suite("Settings copy kept by the model (D24)")
struct SettingsBackupModelTests {
    /// A suite whose plist lives in the temporary directory, removed after the test.
    final class TemporaryDefaults {
        let name: String
        let defaults: UserDefaults

        init(_ label: String) {
            name = FileManager.default.temporaryDirectory.appendingPathComponent("dau-tests-backup-\(label)").path
            defaults = UserDefaults(suiteName: name)!
            defaults.removePersistentDomain(forName: name)
        }

        deinit {
            defaults.removePersistentDomain(forName: name)
            try? FileManager.default.removeItem(atPath: name + ".plist")
        }
    }

    @Test("loading settings that exist copies them; each save refreshes the copy")
    func copyFollowsLoadAndSave() throws {
        let host = TemporaryDefaults("modelHost"), group = TemporaryDefaults("modelGroup")
        let store = SettingsStore(defaults: group.defaults, suiteName: group.name)
        store.save(DauSettings(typingMethod: .vni))
        let backup = SettingsBackup(defaults: host.defaults, groupIdentifier: "TEAM.com.codefastlabs.dau.shared")

        let model = SettingsModel(store: store, backup: backup, compatibility: .empty)
        func copied() -> DauSettings? {
            guard let data = backup.snapshot?.values[SettingsStore.settingsKey] as? Data else { return nil }
            return try? JSONDecoder().decode(DauSettings.self, from: data)
        }
        #expect(backup.snapshot?.groupIdentifier == "TEAM.com.codefastlabs.dau.shared")
        #expect(copied()?.typingMethod == .vni)

        model.settings.typingMethod = .simpleTelex
        #expect(copied()?.typingMethod == .simpleTelex)
    }
}
