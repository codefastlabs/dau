import AppKit
import DauShared
import Foundation

/// The content of "Report a Typing Problem" (artboard Report, `ReportSheet`) and the GitHub
/// issue it opens (D8: reports go only through a prefilled GitHub issue that the user
/// reviews and sends; Dấu sends nothing itself, N2).
///
/// Everything the issue URL carries is on the sheet: the four fields and the "Included"
/// line. Nothing else goes in it (the sheet says "Only what’s shown here is sent."),
/// so no bundle ID, no path, no other setting.
struct ProblemReport: Equatable {
    /// "Problem".
    enum Kind: String, CaseIterable, Identifiable {
        case missingText, repeatedText, wrongMarks, other
        var id: String { rawValue }

        var title: String {
            switch self {
            case .missingText: String(localized: "Missing Text")
            case .repeatedText: String(localized: "Repeated Text")
            case .wrongMarks: String(localized: "Wrong Marks")
            case .other: String(localized: "Other", comment: "Kind of typing problem: none of the others.")
            }
        }
    }

    /// "App": the app's name as the popup shows it.
    var app: String
    /// "Website" (optional).
    var website: String = ""
    var kind: Kind = .missingText
    /// "What you typed".
    var example: String = ""
    // "Included":
    /// "macOS 27.2".
    var macOS: String
    /// `AppVersion.reportVersion` (D25): "Dấu 0.1.0 (6520, a1b2c3d)" on the official build,
    /// the page's version line ("Dấu 1.0.0 (a1b2c3d)") on a development build.
    var dauVersion: String
    /// "Telex", "VNI", "Simple Telex".
    var typingMethod: String
    /// The underline rule of the chosen app: "Underline" or "No Underline" (D5, D13).
    var underline: String
    /// The chosen app's version, when its bundle has one (never made up, N5).
    var appVersion: String?

    /// Where the issue is filed, and the issue form it opens
    /// (.github/ISSUE_TEMPLATE/typing-problem.yml).
    static let newIssueURL = URL(string: "https://github.com/codefastlabs/dau/issues/new")!
    static let template = "typing-problem.yml"

    /// The "Included" items, in the artboard's order: macOS, Dấu, typing method, underline,
    /// the app and its version.
    var included: [String] {
        [macOS, dauVersion, typingMethod, underline, appVersion.map { "\(app) \($0)" }].compactMap { $0 }
    }

    /// "macOS 27 · Dấu 0.1.0 (6520, a1b2c3d) · Telex · No Underline · Chrome 131.0".
    var includedLine: String { included.joined(separator: " · ") }

    /// The issue title: the app and the kind, both shown on the sheet.
    var title: String { "\(app): \(kind.title)" }

    /// The issue form's fields, by their `id` in typing-problem.yml (GitHub fills an issue
    /// form's fields from URL query parameters named after the field ids). Empty fields
    /// are left out.
    var fields: [(id: String, value: String)] {
        let all: [(String, String?)] = [
            ("app", app),
            ("app-version", appVersion),
            ("website", website.trimmingCharacters(in: .whitespacesAndNewlines)),
            ("problem", kind.title),
            ("example", example),
            ("macos", macOS),
            ("dau-version", dauVersion),
            ("settings", "\(typingMethod) · \(underline)"),
        ]
        return all.compactMap { id, value in
            guard let value, !value.isEmpty else { return nil }
            return (id, value)
        }
    }

    /// The prefilled "new issue" URL. Values are percent-encoded down to RFC 3986's
    /// unreserved characters: `URLQueryItem` leaves "+" as is, which GitHub reads as a
    /// space, and "&", "=" or "#" in a field must not cut the query.
    func issueURL() -> URL {
        let items = [("template", Self.template), ("title", title)] + fields.map { ($0.id, $0.value) }
        var components = URLComponents(url: Self.newIssueURL, resolvingAgainstBaseURL: false)!
        components.percentEncodedQuery = items
            .map { "\($0.0)=\(Self.encode($0.1))" }
            .joined(separator: "&")
        return components.url!
    }

    static func encode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: unreserved) ?? ""
    }

    private static let unreserved = CharacterSet(charactersIn:
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    /// "macOS 27.2" (the patch number only when there is one).
    static func macOSName(_ version: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion) -> String {
        var name = "macOS \(version.majorVersion).\(version.minorVersion)"
        if version.patchVersion > 0 { name += ".\(version.patchVersion)" }
        return name
    }

    /// The underline rule of `bundleID` as the Apps page names it (D5, D13): no rule means
    /// no underline.
    static func underlineName(_ settings: DauSettings, bundleID: String?) -> String {
        let on = bundleID.flatMap { settings.rule(for: $0)?.underline } ?? false
        return on ? String(localized: "Underline") : String(localized: "No Underline")
    }
}

/// An app the report can be about.
struct ReportedApp: Identifiable, Equatable, Sendable {
    let bundleID: String
    let name: String
    /// `CFBundleShortVersionString`, else nil.
    let version: String?
    var id: String { bundleID }

    init(bundleID: String, name: String, version: String?) {
        self.bundleID = bundleID
        self.name = name
        self.version = version
    }

    /// From the app's bundle on disk.
    init?(bundleID: String?, url: URL?, fallbackName: String?) {
        guard let bundleID, !bundleID.isEmpty else { return nil }
        let name = url.map(AppDirectory.name(at:)) ?? fallbackName ?? bundleID
        let info = url.flatMap { Bundle(url: $0)?.infoDictionary }
        let version = (info?["CFBundleShortVersionString"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        self.init(bundleID: bundleID, name: name, version: version)
    }

    init?(_ app: NSRunningApplication) {
        self.init(bundleID: app.bundleIdentifier, url: app.bundleURL, fallbackName: app.localizedName)
    }

    /// The popup's list: the regular running apps, without Dấu, by name, plus `previous`
    /// when it has quit since (it is still the likely subject).
    static func choices(running: [ReportedApp], previous: ReportedApp?, own: String?) -> [ReportedApp] {
        var seen = Set<String>()
        var list = (running + [previous].compactMap { $0 })
            .filter { $0.bundleID != own && seen.insert($0.bundleID).inserted }
        list.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        return list
    }
}

/// The app the user was in right before Dấu, to fill "App" (artboard Report: the
/// field is filled in for the user).
///
/// Why this app: people open "Report a Problem…" right after an app typed wrong, by switching to
/// Dấu from it (its input menu's "Dấu Settings…" or the Dock), so the last other app that
/// was frontmost is the likely subject. macOS keeps no history of the frontmost app, so
/// Dấu follows `NSWorkspace.didActivateApplicationNotification` from launch, and takes
/// the frontmost app at launch (still the one Dấu was opened from). The user can pick
/// another app in the popup.
///
/// Kept in memory only for the sheet: never stored, logged or sent (D8).
@MainActor
final class PreviousAppTracker {
    static let shared = PreviousAppTracker()

    private(set) var previous: ReportedApp?
    private var observer: NSObjectProtocol?
    private let own = Bundle.main.bundleIdentifier

    func start() {
        guard observer == nil else { return }
        if let app = NSWorkspace.shared.frontmostApplication { record(app) }
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
        ) { [weak self] note in
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            let candidate = app.flatMap { $0.activationPolicy == .regular ? ReportedApp($0) : nil }
            MainActor.assumeIsolated { self?.record(candidate) }
        }
    }

    private func record(_ app: NSRunningApplication) {
        guard app.activationPolicy == .regular else { return }
        record(ReportedApp(app))
    }

    private func record(_ app: ReportedApp?) {
        guard let app, app.bundleID != own else { return }
        previous = app
    }
}
