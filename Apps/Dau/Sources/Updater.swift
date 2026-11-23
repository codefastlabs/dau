import Foundation
import Observation
import SwiftUI

// The update part of "Updates & Support" (D7), without Sparkle: the Sparkle-backed side
// is SparkleUpdater.swift, left out of the unit-test package, so the choice of build,
// the page's state, the release channel and the wording are tested without linking Sparkle.

/// Whether this build updates itself (D7): only the official build has an appcast URL and
/// a public EdDSA key, written into its Info.plist by the "Sparkle keys" phase of
/// project.yml. Every other build has neither, so Sparkle is never created there and a
/// development build is never replaced by a build of another team.
enum UpdaterConfiguration {
    /// True when `info` (a bundle's Info.plist) carries both `SUFeedURL` and
    /// `SUPublicEDKey` as non-empty strings. Both are required: Sparkle refuses an update
    /// it cannot check against the key, so a feed without one would only fail.
    static func isConfigured(info: [String: Any]?) -> Bool {
        func value(_ key: String) -> String? {
            guard let text = info?[key] as? String else { return nil }
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            // An unexpanded build setting is not a value.
            return trimmed.isEmpty || trimmed.contains("$(") ? nil : trimmed
        }
        guard let feed = value("SUFeedURL"), URL(string: feed)?.scheme == "https" else { return false }
        return value("SUPublicEDKey") != nil
    }

    /// This app's Info.plist.
    static let isConfiguredForThisApp = isConfigured(info: Bundle.main.infoDictionary)
}

/// What the page needs from the updater: Sparkle's `SPUUpdater` in the app
/// (`SparkleUpdaterBackend`), a fake in tests.
@MainActor
protocol UpdaterBackend: AnyObject {
    var canCheckForUpdates: Bool { get }
    var lastUpdateCheckDate: Date? { get }
    var automaticallyChecksForUpdates: Bool { get set }
    /// "Check for Updates…": Sparkle's own windows show the result (D7).
    func checkForUpdates()
    /// Calls `changed` on the main actor whenever one of the three properties changes.
    func observeChanges(_ changed: @escaping @MainActor @Sendable () -> Void)
    /// The user picked another release channel: the updater re-reads the allowed channels
    /// (Sparkle: `resetUpdateCycleAfterShortDelay`, which checks in the background when
    /// the allowed channels changed since the last check).
    func allowedChannelsChanged()
}

// MARK: - Release channel (D7)

/// The release channels of D7. In the appcast a beta item carries Sparkle's channel
/// `beta`; an item without a channel is a stable release, which every channel sees.
enum ReleaseChannel: String, CaseIterable, Sendable {
    case beta
    case stable

    /// The appcast channel of beta items (`<sparkle:channel>beta</sparkle:channel>`).
    static let betaAppcastChannel = "beta"

    /// What the updater delegate returns from Sparkle's `allowedChannels(for:)`: the
    /// default channel (untagged, stable items) is always allowed, so Stable is the empty
    /// set and Beta adds `beta`.
    var allowedAppcastChannels: Set<String> {
        switch self {
        case .beta: [Self.betaAppcastChannel]
        case .stable: []
        }
    }
}

/// Where the channel and what the last appcast said are kept: the app's own defaults
/// (`DefaultsReleaseChannelStore`), a fake in tests. nil means "never decided / never read".
@MainActor
protocol ReleaseChannelStore: AnyObject {
    var channel: ReleaseChannel? { get set }
    var stableReleaseExists: Bool? { get set }
}

/// The app's defaults (not the App Group: the input method has no use for them, N2).
@MainActor
final class DefaultsReleaseChannelStore: ReleaseChannelStore {
    static let channelKey = "DauReleaseChannel"
    static let stableReleaseExistsKey = "DauStableReleaseExists"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var channel: ReleaseChannel? {
        // A value this build does not know is as good as none: decided again at the next load.
        get { defaults.string(forKey: Self.channelKey).flatMap(ReleaseChannel.init(rawValue:)) }
        set { defaults.set(newValue?.rawValue, forKey: Self.channelKey) }
    }

    var stableReleaseExists: Bool? {
        get { defaults.object(forKey: Self.stableReleaseExistsKey) as? Bool }
        set { defaults.set(newValue, forKey: Self.stableReleaseExistsKey) }
    }
}

/// The release channel (D7): the user's choice, and whether the appcast has a
/// stable release yet. Both come from the appcast as Sparkle loads it, never from a build
/// flag: the stable release is the unchanged file of the last beta, built while no
/// stable release existed.
///
/// Sparkle 2.10.1 (`SUAppcastDriver.m`, `downloadDriverDidDownloadData:`): after a successful
/// parse it calls the updater delegate's `updater(_:didFinishLoading:)` with the whole
/// appcast, unfiltered (every item, every channel), and only then asks
/// `allowedChannels(for:)` to filter that same appcast. `SPUUpdater` also asks
/// `allowedChannels(for:)` at the start of each check and in `resetUpdateCycle`, before
/// any appcast is read, only to compare with the next answer. So:
/// - The default is written in `appcastLoaded`, the first time an appcast loads: no
///   stable item, Beta; a stable item, Stable. Afterwards only `choose` changes it; a
///   stable release appearing later switches nobody (D7).
/// - Before that first load `allowedAppcastChannels` is the default channel only (the
///   stable items). That answer is never wrong whatever the call order: it can only hide
///   a beta for one check, never offer a beta to someone who will be on Stable; and
///   in 2.10.1's order the first filtering already sees the decided default.
@MainActor
@Observable
final class ReleaseChannels {
    /// nil until the first appcast load (D7: the default depends on the appcast).
    private(set) var channel: ReleaseChannel?
    /// Whether the last appcast loaded had a stable item; nil before the first load.
    private(set) var stableReleaseExists: Bool?

    @ObservationIgnored private let store: ReleaseChannelStore

    init(store: ReleaseChannelStore) {
        self.store = store
        channel = store.channel
        stableReleaseExists = store.stableReleaseExists
    }

    /// Sparkle loaded the appcast: `itemChannels` holds each item's `channel` (nil for an
    /// untagged item, a stable release).
    func appcastLoaded(itemChannels: [String?]) {
        let exists = itemChannels.contains { $0 == nil }
        if stableReleaseExists != exists {
            stableReleaseExists = exists
            store.stableReleaseExists = exists
        }
        guard channel == nil else { return }
        let first: ReleaseChannel = exists ? .stable : .beta
        channel = first
        store.channel = first
    }

    /// The answer to Sparkle's `allowedChannels(for:)`.
    var allowedAppcastChannels: Set<String> {
        channel?.allowedAppcastChannels ?? []
    }

    /// Stable can be picked only once the appcast has a stable release (the segment is
    /// off before that, docs/UI.md).
    func canChoose(_ choice: ReleaseChannel) -> Bool {
        choice == .beta || stableReleaseExists == true
    }

    /// The user picked `choice`. True when the channel changed.
    @discardableResult
    func choose(_ choice: ReleaseChannel) -> Bool {
        guard choice != channel, canChoose(choice) else { return false }
        channel = choice
        store.channel = choice
        return true
    }
}

/// The updater's state as the page shows it. Exists only on a build with an updater
/// (`UpdaterConfiguration`); the page hides the update rows when there is none.
@MainActor
@Observable
final class UpdatesModel {
    private(set) var canCheck: Bool
    private(set) var lastCheck: Date?
    /// "Automatically check for updates". Sparkle stores the choice in the app's defaults; its
    /// default is `SUEnableAutomaticChecks` in Info.plist (D7).
    var automaticChecks: Bool {
        didSet {
            guard automaticChecks != oldValue, backend.automaticallyChecksForUpdates != automaticChecks else { return }
            backend.automaticallyChecksForUpdates = automaticChecks
        }
    }

    /// "Release channel" (D7). The same object answers Sparkle's delegate
    /// (`SparkleUpdaterBackend`), so the page and the updater never disagree.
    let channels: ReleaseChannels

    @ObservationIgnored private let backend: UpdaterBackend

    init(backend: UpdaterBackend, channels: ReleaseChannels) {
        self.backend = backend
        self.channels = channels
        canCheck = backend.canCheckForUpdates
        lastCheck = backend.lastUpdateCheckDate
        automaticChecks = backend.automaticallyChecksForUpdates
        backend.observeChanges { [weak self] in self?.reload() }
    }

    func checkForUpdates() {
        guard backend.canCheckForUpdates else { return }
        backend.checkForUpdates()
    }

    /// The selection of "Release channel", for a key-path binding (`$updates.channel` through
    /// `@Bindable`, as every other Settings row binds). Beta until the first appcast load,
    /// when the row is not shown anyway. Setting it is `chooseChannel`.
    var channel: ReleaseChannel {
        get { channels.channel ?? .beta }
        set { chooseChannel(newValue) }
    }

    /// The user picked a channel in "Release channel".
    func chooseChannel(_ choice: ReleaseChannel) {
        guard channels.choose(choice) else { return }
        backend.allowedChannelsChanged()
    }

    /// Reads the backend again (after a change it reported).
    func reload() {
        canCheck = backend.canCheckForUpdates
        lastCheck = backend.lastUpdateCheckDate
        if automaticChecks != backend.automaticallyChecksForUpdates {
            automaticChecks = backend.automaticallyChecksForUpdates
        }
    }

    /// "Last checked: today at 9:41" (artboard SettingsAbout). Before the first
    /// check Sparkle has no date: the line says so rather than show a time (N5).
    static func lastCheckLine(_ date: Date?, now: Date = Date(), calendar: Calendar = .current,
                              locale: Locale = .current) -> String {
        guard let date else { return String(localized: "Not checked yet") }
        return String(localized: "Last checked: \(when(date, now: now, calendar: calendar, locale: locale))")
    }

    /// "today at 9:41", "yesterday at 9:41", else the date "at" the time. Built from the
    /// catalog rather than `DateFormatter.doesRelativeDateFormatting`: the Vietnamese
    /// relative style puts the time first ("9:41 Hôm nay"), where the catalog's "today
    /// at %@" puts it last. The date and time themselves follow the user's region (`locale`).
    static func when(_ date: Date, now: Date, calendar: Calendar, locale: Locale) -> String {
        let time = date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, calendar: calendar, timeZone: calendar.timeZone))
        if calendar.isDate(date, inSameDayAs: now) {
            return String(localized: "today at \(time)")
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(date, inSameDayAs: yesterday) {
            return String(localized: "yesterday at \(time)")
        }
        let day = date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: locale, calendar: calendar, timeZone: calendar.timeZone))
        return String(localized: "\(day) at \(time)")
    }
}

extension EnvironmentValues {
    /// The updater of the official build; nil on every other build (D7).
    @Entry var updates: UpdatesModel?
}
