import Foundation
import Testing
@testable import DauShared

/// D24, D7 "Chuyển danh tính ký": the App Group follows the Team ID, so the host app keeps
/// a copy in its own defaults and brings it into an empty group once. Every suite here is
/// a `TemporarySuite`: the host's own defaults, the old group and the new group.
@Suite("SettingsBackup")
struct SettingsBackupTests {
    static let oldGroup = "M58DANM3ZP.com.codefastlabs.dau.shared"
    static let newGroup = "ABCDE12345.com.codefastlabs.dau.shared"

    static func settings() -> DauSettings {
        var settings = DauSettings(typingMethod: .vni, tonePlacement: .classic, advanced: .consonantShortcuts)
        settings.upsert(AppRule(bundleID: "com.apple.Terminal", displayName: "Terminal", underline: true))
        return settings
    }

    @Test("decision: carry over only into an empty group, from a copy of another group", arguments: [
        (false, "A", "B", SettingsCarryOver.carriedOver(from: "A")),
        (true, "A", "B", .groupHasSettings),
        (false, "B", "B", .copyFromThisGroup),
        (false, nil, "B", .noCopy),
        (true, nil, "B", .groupHasSettings),
    ] as [(Bool, String?, String, SettingsCarryOver)])
    func decision(groupHasSettings: Bool, copiedFrom: String?, group: String, expected: SettingsCarryOver) {
        #expect(SettingsCarryOver.decide(groupHasSettings: groupHasSettings, copiedFrom: copiedFrom, group: group) == expected)
    }

    @Test("round trip: settings saved in the old group reach the empty new group unchanged, with the change notification")
    func roundTrip() throws {
        let host = TemporarySuite("roundTripHost"), old = TemporarySuite("roundTripOld"), new = TemporarySuite("roundTripNew")
        let oldStore = SettingsStore(defaults: old.defaults, suiteName: old.name)
        oldStore.save(Self.settings())
        SettingsBackup(defaults: host.defaults, groupIdentifier: Self.oldGroup).record(oldStore)

        let newStore = SettingsStore(defaults: new.defaults, suiteName: new.name)
        let heard = DispatchSemaphore(value: 0)
        let observer = try #require(newStore.observeChanges(on: DispatchQueue(label: "dau.tests.carry-over")) {
            heard.signal()
        })
        let backup = SettingsBackup(defaults: host.defaults, groupIdentifier: Self.newGroup)
        #expect(backup.carryOver(into: newStore) == .carriedOver(from: Self.oldGroup))
        #expect(heard.wait(timeout: .now() + 2) == .success)
        withExtendedLifetime(observer) {}

        #expect(newStore.load() == Self.settings())
        #expect(new.defaults.data(forKey: SettingsStore.settingsKey) == old.defaults.data(forKey: SettingsStore.settingsKey))
        // The copy now names the new group: a second launch does nothing.
        #expect(backup.snapshot?.groupIdentifier == Self.newGroup)
        #expect(backup.carryOver(into: newStore) == .groupHasSettings)
    }

    @Test("a group that already has settings is never overwritten")
    func groupWithSettingsKept() {
        let host = TemporarySuite("keptHost"), old = TemporarySuite("keptOld"), new = TemporarySuite("keptNew")
        let oldStore = SettingsStore(defaults: old.defaults, suiteName: old.name)
        oldStore.save(Self.settings())
        SettingsBackup(defaults: host.defaults, groupIdentifier: Self.oldGroup).record(oldStore)

        let newStore = SettingsStore(defaults: new.defaults, suiteName: new.name)
        let own = DauSettings(typingMethod: .simpleTelex)
        newStore.save(own)
        #expect(SettingsBackup(defaults: host.defaults, groupIdentifier: Self.newGroup).carryOver(into: newStore)
                == .groupHasSettings)
        #expect(newStore.load() == own)
    }

    @Test("a copy taken from this same group is not brought back into it")
    func copyFromSameGroup() {
        let host = TemporarySuite("sameHost"), group = TemporarySuite("sameGroup")
        let store = SettingsStore(defaults: group.defaults, suiteName: group.name)
        store.save(Self.settings())
        let backup = SettingsBackup(defaults: host.defaults, groupIdentifier: Self.newGroup)
        backup.record(store)
        group.defaults.removePersistentDomain(forName: group.name)

        #expect(backup.carryOver(into: store) == .copyFromThisGroup)
        #expect(store.storedValues.isEmpty)
    }

    @Test("no copy: the empty group stays empty")
    func noCopy() {
        let host = TemporarySuite("noCopyHost"), group = TemporarySuite("noCopyGroup")
        let store = SettingsStore(defaults: group.defaults, suiteName: group.name)
        #expect(SettingsBackup(defaults: host.defaults, groupIdentifier: Self.newGroup).carryOver(into: store) == .noCopy)
        #expect(store.storedValues.isEmpty)
    }

    @Test("record: an empty group leaves the copy as it is; a group with settings replaces it")
    func recordKeepsCopyOfEmptyGroup() {
        let host = TemporarySuite("recordHost"), old = TemporarySuite("recordOld"), new = TemporarySuite("recordNew")
        let oldStore = SettingsStore(defaults: old.defaults, suiteName: old.name)
        oldStore.save(Self.settings())
        SettingsBackup(defaults: host.defaults, groupIdentifier: Self.oldGroup).record(oldStore)

        let newStore = SettingsStore(defaults: new.defaults, suiteName: new.name)
        let backup = SettingsBackup(defaults: host.defaults, groupIdentifier: Self.newGroup)
        backup.record(newStore)
        #expect(backup.snapshot?.groupIdentifier == Self.oldGroup)

        newStore.save(DauSettings(typingMethod: .simpleTelex))
        backup.record(newStore)
        #expect(backup.snapshot?.groupIdentifier == Self.newGroup)
        #expect(backup.snapshot?.values[SettingsStore.settingsKey] as? Data
                == new.defaults.data(forKey: SettingsStore.settingsKey))
    }

    @Test("remove deletes the copy: deleted settings are not carried into a new group")
    func removedCopyIsNotCarriedOver() {
        let host = TemporarySuite("removeHost"), old = TemporarySuite("removeOld"), new = TemporarySuite("removeNew")
        let oldStore = SettingsStore(defaults: old.defaults, suiteName: old.name)
        oldStore.save(Self.settings())
        SettingsBackup(defaults: host.defaults, groupIdentifier: Self.oldGroup).record(oldStore)
        SettingsBackup(defaults: host.defaults, groupIdentifier: Self.oldGroup).remove()

        let newStore = SettingsStore(defaults: new.defaults, suiteName: new.name)
        #expect(SettingsBackup(defaults: host.defaults, groupIdentifier: Self.newGroup).carryOver(into: newStore) == .noCopy)
        #expect(newStore.storedValues.isEmpty)
    }

    @Test("every stored key is copied: storedKeys covers what SettingsStore writes")
    func storedKeysCoverSave() {
        let group = TemporarySuite("keysGroup")
        let store = SettingsStore(defaults: group.defaults, suiteName: group.name)
        store.save(Self.settings())
        let written = Set(group.defaults.persistentDomain(forName: group.name).map { Array($0.keys) } ?? [])
        #expect(written == Set(SettingsStore.storedKeys))
        #expect(Set(store.storedValues.keys) == written)
    }
}
