import Foundation
import Observation
import SwiftUI

// The update part of "Cập nhật & hỗ trợ" (D7), without Sparkle: the Sparkle-backed side
// is SparkleUpdater.swift, left out of the unit-test package, so the choice of build,
// the page's state and its wording are tested without linking Sparkle.

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
    /// "Kiểm tra bản mới…": Sparkle's own windows show the result (D7).
    func checkForUpdates()
    /// Calls `changed` on the main actor whenever one of the three properties changes.
    func observeChanges(_ changed: @escaping @MainActor @Sendable () -> Void)
}

/// The updater's state as the page shows it. Exists only on a build with an updater
/// (`UpdaterConfiguration`); the page hides the update rows when there is none.
@MainActor
@Observable
final class UpdatesModel {
    private(set) var canCheck: Bool
    private(set) var lastCheck: Date?
    /// "Tự động kiểm tra bản mới". Sparkle stores the choice in the app's defaults; its
    /// default is `SUEnableAutomaticChecks` in Info.plist (D7).
    var automaticChecks: Bool {
        didSet {
            guard automaticChecks != oldValue, backend.automaticallyChecksForUpdates != automaticChecks else { return }
            backend.automaticallyChecksForUpdates = automaticChecks
        }
    }

    @ObservationIgnored private let backend: UpdaterBackend

    init(backend: UpdaterBackend) {
        self.backend = backend
        canCheck = backend.canCheckForUpdates
        lastCheck = backend.lastUpdateCheckDate
        automaticChecks = backend.automaticallyChecksForUpdates
        backend.observeChanges { [weak self] in self?.reload() }
    }

    func checkForUpdates() {
        guard backend.canCheckForUpdates else { return }
        backend.checkForUpdates()
    }

    /// Reads the backend again (after a change it reported).
    func reload() {
        canCheck = backend.canCheckForUpdates
        lastCheck = backend.lastUpdateCheckDate
        if automaticChecks != backend.automaticallyChecksForUpdates {
            automaticChecks = backend.automaticallyChecksForUpdates
        }
    }

    /// "Kiểm tra lần cuối: hôm nay lúc 9:41" (artboard SettingsAbout). Before the first
    /// check Sparkle has no date: the line says so rather than show a time (N5).
    static func lastCheckLine(_ date: Date?, now: Date = Date(), calendar: Calendar = .current,
                              locale: Locale = .current) -> String {
        guard let date else { return String(localized: "Not checked yet") }
        return String(localized: "Last checked: \(when(date, now: now, calendar: calendar, locale: locale))")
    }

    /// "today at 9:41", "yesterday at 9:41", else the date "at" the time. Built from the
    /// catalog rather than `DateFormatter.doesRelativeDateFormatting`: the Vietnamese
    /// relative style puts the time first ("9:41 Hôm nay"), not the artboard's "hôm nay
    /// lúc 9:41". The date and time themselves follow the user's region (`locale`).
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
