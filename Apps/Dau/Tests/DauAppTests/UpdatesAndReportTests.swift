import Foundation
import Testing
import DauShared
@testable import Dau

// D7: only a build whose Info.plist has the feed URL and the public key gets an updater;
// the page follows the updater. D8: the problem report opens a prefilled GitHub issue that
// carries only what the sheet shows. The views' strings are read from `Bundle.main` (the
// test runner's), so the tests see the English keys.

@Suite("Updater choice (D7)")
struct UpdaterConfigurationTests {
    @Test("an updater only with both SUFeedURL (https) and SUPublicEDKey")
    func choice() {
        let feed = "https://dau.codefastlabs.com/appcast.xml"
        #expect(UpdaterConfiguration.isConfigured(info: ["SUFeedURL": feed, "SUPublicEDKey": "abc="]))
        // The development build: neither key (the "Sparkle keys" phase deletes them).
        #expect(!UpdaterConfiguration.isConfigured(info: ["SUEnableAutomaticChecks": true]))
        #expect(!UpdaterConfiguration.isConfigured(info: nil))
        #expect(!UpdaterConfiguration.isConfigured(info: ["SUFeedURL": feed]))
        #expect(!UpdaterConfiguration.isConfigured(info: ["SUPublicEDKey": "abc="]))
        #expect(!UpdaterConfiguration.isConfigured(info: ["SUFeedURL": feed, "SUPublicEDKey": " "]))
        #expect(!UpdaterConfiguration.isConfigured(info: ["SUFeedURL": "", "SUPublicEDKey": "abc="]))
        #expect(!UpdaterConfiguration.isConfigured(info: ["SUFeedURL": "$(DAU_SPARKLE_FEED_URL)", "SUPublicEDKey": "abc="]))
        #expect(!UpdaterConfiguration.isConfigured(info: ["SUFeedURL": "http://dau.codefastlabs.com/appcast.xml", "SUPublicEDKey": "abc="]))
        #expect(!UpdaterConfiguration.isConfigured(info: ["SUFeedURL": 1, "SUPublicEDKey": "abc="]))
    }

    @Test("the test runner, like a development build, has no updater and no update search words")
    func thisBuild() {
        #expect(!UpdaterConfiguration.isConfiguredForThisApp)
        let words = SettingsSection.updates.keywordResources.map(\.key)
        #expect(!words.contains("Check for Updates…"))
        #expect(words.contains("Report a Problem…"))
    }
}

@MainActor
final class FakeUpdater: UpdaterBackend {
    var canCheckForUpdates = true
    var lastUpdateCheckDate: Date?
    var automaticallyChecksForUpdates = true
    var checks = 0
    var changed: (@MainActor @Sendable () -> Void)?

    var channelResets = 0
    func checkForUpdates() { checks += 1 }
    func allowedChannelsChanged() { channelResets += 1 }
    func observeChanges(_ changed: @escaping @MainActor @Sendable () -> Void) { self.changed = changed }
}

@Suite("Updates on the page (D7)")
@MainActor
struct UpdatesModelTests {
    @Test("the page follows the updater and writes the switch back")
    func follows() {
        let fake = FakeUpdater()
        let model = UpdatesModel(backend: fake, channels: ReleaseChannels(store: FakeChannelStore()))
        #expect(model.canCheck && model.automaticChecks && model.lastCheck == nil)

        let date = Date(timeIntervalSince1970: 1_800_000_000)
        fake.canCheckForUpdates = false
        fake.lastUpdateCheckDate = date
        fake.automaticallyChecksForUpdates = false
        fake.changed?()
        #expect(!model.canCheck && model.lastCheck == date && !model.automaticChecks)
        // Reading the updater's value back does not write it again.
        #expect(!fake.automaticallyChecksForUpdates)

        model.automaticChecks = true
        #expect(fake.automaticallyChecksForUpdates)
    }

    @Test("\"Check for Updates…\" only reaches the updater when a check is allowed")
    func check() {
        let fake = FakeUpdater()
        let model = UpdatesModel(backend: fake, channels: ReleaseChannels(store: FakeChannelStore()))
        model.checkForUpdates()
        fake.canCheckForUpdates = false
        model.checkForUpdates()
        #expect(fake.checks == 1)
    }

    @Test("last check: none yet, today, yesterday, an earlier day")
    func lastCheckLine() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let locale = Locale(identifier: "en_US_POSIX")
        let now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: 15))!
        func line(_ date: Date?) -> String {
            UpdatesModel.lastCheckLine(date, now: now, calendar: calendar, locale: locale)
        }
        // N5: no date is never shown as a time.
        #expect(line(nil) == "Not checked yet")
        let today = calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: 9, minute: 41))!
        #expect(line(today).hasPrefix("Last checked: today at "))
        #expect(line(today).contains("9:41"))
        let yesterday = calendar.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: 23, minute: 5))!
        #expect(line(yesterday).hasPrefix("Last checked: yesterday at "))
        let earlier = calendar.date(from: DateComponents(year: 2026, month: 11, day: 3, hour: 8))!
        let text = line(earlier)
        #expect(text.hasPrefix("Last checked: ") && text.contains("2026") && text.contains(" at "))
    }

    @Test("the Vietnamese wording follows the artboard (\"hôm nay lúc 9:41\")")
    func vietnamese() {
        #expect(Catalog.text("Last checked: %@", "vi") == "Kiểm tra lần cuối: %@")
        #expect(Catalog.text("today at %@", "vi") == "hôm nay lúc %@")
        #expect(Catalog.text("Check for Updates…", "vi") == "Kiểm tra bản mới…")
        #expect(Catalog.text("Automatically check for updates", "vi") == "Tự động kiểm tra bản mới")
    }
}

@Suite("Problem report (D8)")
struct ProblemReportTests {
    private func sample(website: String = "docs.google.com", example: String = "tieengs Vieetj",
                        appVersion: String? = "131.0") -> ProblemReport {
        ProblemReport(app: "Google Chrome", website: website, kind: .missingText, example: example,
                      macOS: "macOS 27.2", dauVersion: "Dấu 0.1.0 (6520, a1b2c3d)", typingMethod: "Telex",
                      underline: "No Underline", appVersion: appVersion)
    }

    /// The query of `url` as (name, value) pairs, decoded.
    private func query(_ url: URL) -> [(String, String)] {
        URLComponents(url: url, resolvingAgainstBaseURL: false)!.percentEncodedQuery!
            .split(separator: "&")
            .map { pair in
                let parts = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
                return (String(parts[0]), String(parts[1]).removingPercentEncoding!)
            }
    }

    @Test("\"Gửi kèm\": macOS, Dấu, typing method, underline, then the app and its version")
    func included() {
        #expect(sample().included == ["macOS 27.2", "Dấu 0.1.0 (6520, a1b2c3d)", "Telex", "No Underline", "Google Chrome 131.0"])
        #expect(sample().includedLine == "macOS 27.2 · Dấu 0.1.0 (6520, a1b2c3d) · Telex · No Underline · Google Chrome 131.0")
        // No version read from the app's bundle: none is made up (N5).
        #expect(sample(appVersion: nil).included.last == "No Underline")
    }

    @Test("the URL opens the issue form of codefastlabs/dau with every field, nothing else")
    func url() {
        let report = sample()
        let url = report.issueURL()
        #expect(url.scheme == "https" && url.host == "github.com" && url.path == "/codefastlabs/dau/issues/new")
        let items = query(url)
        #expect(items.map(\.0) == ["template", "title", "app", "app-version", "website", "problem",
                                   "example", "macos", "dau-version", "settings"])
        let values = Dictionary(uniqueKeysWithValues: items)
        #expect(values["template"] == "typing-problem.yml")
        #expect(values["title"] == "Google Chrome: Missing Text")
        #expect(values["app"] == "Google Chrome")
        #expect(values["app-version"] == "131.0")
        #expect(values["website"] == "docs.google.com")
        #expect(values["problem"] == "Missing Text")
        #expect(values["example"] == "tieengs Vieetj")
        #expect(values["macos"] == "macOS 27.2")
        #expect(values["dau-version"] == "Dấu 0.1.0 (6520, a1b2c3d)")
        #expect(values["settings"] == "Telex · No Underline")
        // Every value is made of what the sheet shows: its fields and the "Gửi kèm" line.
        let shown = [report.app, report.website, report.kind.title, report.example, report.includedLine]
        for (name, value) in items where name != "template" {
            for part in value.components(separatedBy: CharacterSet(charactersIn: ":·")) {
                let part = part.trimmingCharacters(in: .whitespaces)
                #expect(part.isEmpty || shown.contains { $0.contains(part) }, "\(name): \(part)")
            }
        }
    }

    @Test("empty fields are left out")
    func emptyFields() {
        let names = query(sample(website: "  ", example: "", appVersion: nil).issueURL()).map(\.0)
        #expect(!names.contains("website") && !names.contains("example") && !names.contains("app-version"))
    }

    @Test("values are percent-encoded: +, &, =, #, spaces, line breaks and Vietnamese survive")
    func encoding() {
        let example = "C++ & a=b #1 100%\nđã gõ: “tiếng Việt”"
        let url = sample(example: example).issueURL()
        let raw = URLComponents(url: url, resolvingAgainstBaseURL: false)!.percentEncodedQuery!
        #expect(!raw.contains("+") && !raw.contains(" ") && !raw.contains("#"))
        #expect(raw.components(separatedBy: "&").count == 10)
        #expect(Dictionary(uniqueKeysWithValues: query(url))["example"] == example)
    }

    @Test("macOS name, and the underline rule of the chosen app (D5, D13)")
    func helpers() {
        #expect(ProblemReport.macOSName(OperatingSystemVersion(majorVersion: 27, minorVersion: 2, patchVersion: 0)) == "macOS 27.2")
        #expect(ProblemReport.macOSName(OperatingSystemVersion(majorVersion: 27, minorVersion: 2, patchVersion: 1)) == "macOS 27.2.1")
        let settings = DauSettings(appRules: [AppRule(bundleID: "com.google.Chrome", underline: true)])
        #expect(ProblemReport.underlineName(settings, bundleID: "com.google.Chrome") == "Underline")
        #expect(ProblemReport.underlineName(settings, bundleID: "com.apple.Safari") == "No Underline")
        #expect(ProblemReport.underlineName(settings, bundleID: nil) == "No Underline")
    }

    @Test("the app popup: running apps by name, without Dấu, the previous app kept after it quit")
    func choices() {
        let chrome = ReportedApp(bundleID: "com.google.Chrome", name: "Google Chrome", version: "131.0")
        let notes = ReportedApp(bundleID: "com.apple.Notes", name: "Notes", version: nil)
        let dau = ReportedApp(bundleID: "com.codefastlabs.dau", name: "Dấu", version: "1.0.0")
        let zalo = ReportedApp(bundleID: "com.vng.zalo", name: "Zalo", version: "24.1")
        let list = ReportedApp.choices(running: [notes, dau, chrome], previous: zalo, own: "com.codefastlabs.dau")
        #expect(list.map(\.name) == ["Google Chrome", "Notes", "Zalo"])
        #expect(ReportedApp.choices(running: [chrome, chrome], previous: chrome, own: nil).count == 1)
    }

    @Test("the sheet's Vietnamese wording follows the artboard")
    func vietnamese() {
        #expect(Catalog.text("Report a Typing Problem", "vi") == "Báo ứng dụng gõ lỗi")
        #expect(Catalog.text("Open on GitHub", "vi") == "Mở trên GitHub")
        #expect(Catalog.text("%@. Only what’s shown here is sent.", "vi") == "%@. Chỉ gửi những gì có trong bảng này.")
        #expect(Catalog.text("Missing Text", "vi") == "Mất chữ")
        #expect(Catalog.text("Report a Problem…", "vi") == "Báo lỗi…")
    }
}

@Suite("Issue form (D8)")
struct IssueFormTests {
    /// .github/ISSUE_TEMPLATE/typing-problem.yml, from this file's place in the repo.
    private static let form = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent(".github/ISSUE_TEMPLATE").appendingPathComponent(ProblemReport.template)

    @Test("every field the URL fills is an id of the issue form")
    func ids() throws {
        let text = try String(contentsOf: Self.form, encoding: .utf8)
        let ids = Set(text.split(separator: "\n").compactMap { line -> String? in
            let line = line.trimmingCharacters(in: .whitespaces)
            guard line.hasPrefix("id:") else { return nil }
            return line.dropFirst(3).trimmingCharacters(in: .whitespaces)
        })
        let report = ProblemReport(app: "A", website: "w", kind: .other, example: "e", macOS: "m",
                                   dauVersion: "d", typingMethod: "t", underline: "u", appVersion: "1")
        for field in report.fields {
            #expect(ids.contains(field.id), "\(field.id)")
        }
        #expect(ids.count == report.fields.count)
    }
}
