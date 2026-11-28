import Foundation

/// A copy of everything Dấu stores in the App Group, kept in the host app's own
/// defaults together with the group it came from, so the settings survive a change of
/// App Group.
///
/// The App Group carries the Team ID (D24), so a build signed by another team opens an
/// empty group; the host app's own defaults follow the bundle ID and do not change (D7,
/// "Chuyển danh tính ký"). Only the host app keeps the copy: the input method is
/// sandboxed and cannot write the host's defaults. The old group is never read directly:
/// on macOS 15 and later, reading another team's group container can make macOS ask the
/// user for permission.
public struct SettingsBackup: @unchecked Sendable {
    // @unchecked: `UserDefaults` is documented as thread-safe.

    /// Key, in the host app's own defaults, of the copy.
    public static let backupKey = "appGroupBackup"
    private static let groupField = "group"
    private static let valuesField = "values"

    /// The host app's own defaults (`UserDefaults.standard` in the app).
    public let defaults: UserDefaults
    /// The App Group this build opens: where `record` copies from and `carryOver` writes to.
    public let groupIdentifier: String

    public init(defaults: UserDefaults, groupIdentifier: String) {
        self.defaults = defaults
        self.groupIdentifier = groupIdentifier
    }

    /// The copy as stored: the App Group it came from and the stored values by key.
    public struct Snapshot {
        public let groupIdentifier: String
        public let values: [String: Any]
    }

    /// The copy, or nil when there is none or it is unreadable.
    public var snapshot: Snapshot? {
        guard let stored = defaults.dictionary(forKey: Self.backupKey),
              let group = stored[Self.groupField] as? String, !group.isEmpty,
              let values = stored[Self.valuesField] as? [String: Any], !values.isEmpty else { return nil }
        return Snapshot(groupIdentifier: group, values: values)
    }

    /// Copies what `store`, the App Group `groupIdentifier`, holds. An empty group leaves
    /// the copy as it is: either the group is new and the copy is what `carryOver` brings
    /// to it, or the user deleted the settings, which also removes the copy (`remove`).
    public func record(_ store: SettingsStore) {
        let values = store.storedValues
        guard !values.isEmpty else { return }
        defaults.set([Self.groupField: groupIdentifier, Self.valuesField: values], forKey: Self.backupKey)
    }

    /// Deletes the copy. Deleting the App Group's settings must call it too, or a build of
    /// another team would carry the deleted settings over.
    public func remove() {
        defaults.removeObject(forKey: Self.backupKey)
    }

    /// Writes the copy into `store`, the App Group `groupIdentifier`, when
    /// `SettingsCarryOver.decide` says so, and announces the change so the input method
    /// reads it.
    @discardableResult
    public func carryOver(into store: SettingsStore) -> SettingsCarryOver {
        let copy = snapshot
        let decision = SettingsCarryOver.decide(groupHasSettings: !store.storedValues.isEmpty,
                                                copiedFrom: copy?.groupIdentifier,
                                                group: groupIdentifier)
        guard case .carriedOver = decision, let copy else { return decision }
        for key in SettingsStore.storedKeys {
            if let value = copy.values[key] { store.defaults.set(value, forKey: key) }
        }
        store.postChange()
        record(store)
        return decision
    }
}

/// What `SettingsBackup.carryOver` does with the copy at launch.
public enum SettingsCarryOver: Equatable, Sendable {
    /// The group was empty and the copy came from another group: the copy was written
    /// into the group.
    case carriedOver(from: String)
    /// The group already holds Dấu's settings, which are never overwritten.
    case groupHasSettings
    /// There is no copy.
    case noCopy
    /// The copy came from this group: it was emptied here, so the copy is not brought back.
    case copyFromThisGroup

    /// The decision alone: carry over only into an empty group, from a copy of another group.
    public static func decide(groupHasSettings: Bool, copiedFrom source: String?, group: String) -> SettingsCarryOver {
        if groupHasSettings { return .groupHasSettings }
        guard let source else { return .noCopy }
        if source == group { return .copyFromThisGroup }
        return .carriedOver(from: source)
    }
}
