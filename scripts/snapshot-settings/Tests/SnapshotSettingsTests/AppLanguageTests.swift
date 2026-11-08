import Foundation
import Testing
@testable import SnapshotSettings

/// The Language row of Updates & Support (D41, `AppLanguage`): Dấu reads, never writes,
/// the language macOS chose for it. The domain reader is injected, so no test reads the
/// user's real preferences.
@Suite("Language row")
struct AppLanguageTests {
    @Test("set for Dấu only exactly when the app's own domain has AppleLanguages")
    func domainKey() {
        var asked: [String] = []
        #expect(AppLanguage.isSetForDau { key in asked.append(key); return ["vi-VN", "en", "en-VN"] })
        #expect(asked == ["AppleLanguages"])
        #expect(!AppLanguage.isSetForDau { _ in nil })
        // Another key of the domain does not count.
        #expect(!AppLanguage.isSetForDau { key in key == "AppleLocale" ? "vi_VN" : nil })
    }

    @Test("the domain read is that domain alone: no fall-through to the global domain or launch arguments")
    func noFallThrough() {
        // A domain nobody writes. UserDefaults.standard has AppleLanguages (global domain,
        // and -AppleLanguages for the snapshot tool); the domain read must not see it.
        #expect(AppLanguage.appDomainValue("AppleLanguages", domain: "com.codefastlabs.dau.tests.no-such-domain") == nil)
        #expect(AppLanguage.appDomainValue("AppleLanguages", domain: nil) == nil)
    }

    @Test("the language is named in that language, capitalized as macOS lists it")
    func names() {
        #expect(AppLanguage.name(of: "vi") == "Tiếng Việt")
        #expect(AppLanguage.name(of: "en") == "English")
        #expect(AppLanguage.name(of: "fr") == "Français")
    }

    /// The subtitle in `language`, with the system's name of the Applications section.
    func subtitle(_ setForDau: Bool, _ language: String, _ applications: String) -> String {
        let key = AppLanguage.subtitle(setForDau: setForDau, applications: applications).key
        return String(format: SnapshotLocalization.text(key, language), applications)
    }

    @Test("following macOS: how to set a language for Dấu only, both languages (artboard SettingsLanguage)")
    func followsMacOS() {
        #expect(AppLanguage.subtitle(setForDau: false, applications: "x").key
                == "Follows macOS. To set a language for Dấu only, click Change…, then under %@ click + and choose Dấu.")
        #expect(subtitle(false, "vi", "Ứng dụng")
                == "Theo macOS. Muốn đặt riêng cho Dấu: bấm Đổi…, rồi ở mục Ứng dụng bấm + và chọn Dấu.")
        #expect(subtitle(false, "en", "Applications")
                == "Follows macOS. To set a language for Dấu only, click Change…, then under Applications click + and choose Dấu.")
    }

    @Test("set for Dấu: how to change or remove it; the section name is the system's (artboard SettingsLanguageEn)")
    func setForDau() {
        #expect(AppLanguage.subtitle(setForDau: true, applications: "x").key
                == "Set for Dấu only. Click Change… to pick another language, or remove Dấu from the %@ list.")
        // Dấu in English on a Vietnamese Mac: the section keeps macOS's Vietnamese name (D38).
        #expect(subtitle(true, "en", "Ứng dụng")
                == "Set for Dấu only. Click Change… to pick another language, or remove Dấu from the Ứng dụng list.")
        #expect(subtitle(true, "vi", "Ứng dụng")
                == "Đặt riêng cho Dấu. Bấm Đổi… để chọn ngôn ngữ khác, hoặc bỏ Dấu khỏi danh sách Ứng dụng.")
    }

    @Test("the row's words and button in Vietnamese")
    func rowWords() {
        #expect(SnapshotLocalization.text("Language", "vi") == "Ngôn ngữ")
        #expect(SnapshotLocalization.text("Change…", "vi") == "Đổi…")
        #expect(String(format: SnapshotLocalization.text("Open %@", "vi"), "Ngôn ngữ & Vùng") == "Mở Ngôn ngữ & Vùng")
    }

    // MARK: Waiting for a relaunch (D41, artboard SettingsLanguagePending)

    static let localizations = ["en", "vi", "Base"]

    @Test("next launch: the list set for Dấu wins over the macOS list")
    func nextFromAppKey() {
        #expect(AppLanguage.nextLaunch(available: Self.localizations,
                                       appDomain: ["en-VN", "vi"], global: ["vi-VN", "en"]) == "en")
        #expect(AppLanguage.nextLaunch(available: Self.localizations,
                                       appDomain: ["vi-VN", "en", "en-VN"], global: ["en-US"]) == "vi")
        // The first language of the list that Dấu has.
        #expect(AppLanguage.nextLaunch(available: Self.localizations,
                                       appDomain: ["fr-FR", "vi-VN"], global: ["en"]) == "vi")
    }

    @Test("next launch: the macOS list when nothing is set for Dấu")
    func nextFromGlobal() {
        #expect(AppLanguage.nextLaunch(available: Self.localizations, appDomain: nil, global: ["vi-VN", "en-VN"]) == "vi")
        #expect(AppLanguage.nextLaunch(available: Self.localizations, appDomain: nil, global: ["en-VN", "vi-VN"]) == "en")
        #expect(AppLanguage.nextLaunch(available: Self.localizations, appDomain: nil, global: ["de", "vi"]) == "vi")
    }

    @Test("next launch: English when no preferred language is one Dấu has, or there is no list")
    func nextFallback() {
        for order in [["en", "vi"], ["vi", "en"], ["Base", "vi", "en"]] {
            #expect(AppLanguage.nextLaunch(available: order, appDomain: nil, global: ["fr", "de"]) == "en")
            #expect(AppLanguage.nextLaunch(available: order, appDomain: ["zh-Hans"], global: ["vi"]) == "en")
            #expect(AppLanguage.nextLaunch(available: order, appDomain: nil, global: nil) == "en")
            #expect(AppLanguage.nextLaunch(available: order, appDomain: nil, global: "not a list") == "en")
        }
    }

    @Test("status: the app key is read first; the macOS list only when it is absent")
    func statusReaders() {
        var globalReads = 0
        let setForDau = AppLanguage.status(current: "vi", available: Self.localizations,
                                           read: { $0 == "AppleLanguages" ? ["en"] : nil },
                                           global: { globalReads += 1; return ["vi"] })
        #expect(setForDau == AppLanguage.Status(current: "vi", next: "en", setForDau: true))
        #expect(globalReads == 0)
        let follows = AppLanguage.status(current: "en", available: Self.localizations,
                                         read: { _ in nil }, global: { globalReads += 1; return ["vi-VN"] })
        #expect(follows == AppLanguage.Status(current: "en", next: "vi", setForDau: false))
        #expect(globalReads == 1)
    }

    @Test("the user's macOS list is read from the global domain itself")
    func globalDomain() {
        // Every user session has a language list; launch arguments do not reach this read.
        #expect(AppLanguage.globalLanguages() is [String])
    }

    @Test("pending exactly when the next launch differs from the language shown; Reopen only then")
    func pending() {
        let waiting = AppLanguage.Status(current: "vi", next: "en", setForDau: true)
        #expect(waiting.isPending)
        #expect(waiting.showsReopen)
        #expect(waiting.shownLanguage == "en")
        let back = AppLanguage.Status(current: "en", next: "vi", setForDau: false)
        #expect(back.isPending && back.showsReopen && back.shownLanguage == "vi")
        for status in [AppLanguage.Status(current: "vi", next: "vi", setForDau: true),
                       AppLanguage.Status(current: "en", next: "en", setForDau: false)] {
            #expect(!status.isPending)
            #expect(!status.showsReopen)
            #expect(status.shownLanguage == status.current)
        }
    }

    /// The subtitle for `status` in `language`.
    func subtitle(_ status: AppLanguage.Status, _ language: String, _ applications: String = "Applications") -> String {
        let resource = AppLanguage.subtitle(status, applications: applications)
        let format = SnapshotLocalization.text(resource.key, language)
        let arguments = status.isPending
            ? [AppLanguage.name(of: status.next), AppLanguage.name(of: status.current)]
            : [applications]
        return String(format: format, arguments: arguments)
    }

    @Test("pending, set for Dấu: first sentence kept, both languages named in themselves (artboard SettingsLanguagePending)")
    func pendingSetForDau() {
        let status = AppLanguage.Status(current: "vi", next: "en", setForDau: true)
        #expect(AppLanguage.subtitle(status, applications: "x").key
                == "Set for Dấu only. Dấu switches to %@ when it reopens; until then it stays in %@.")
        #expect(subtitle(status, "vi") == "Đặt riêng cho Dấu. Dấu dùng English sau khi mở lại; đến lúc đó vẫn hiện Tiếng Việt.")
        #expect(subtitle(AppLanguage.Status(current: "en", next: "vi", setForDau: true), "en")
                == "Set for Dấu only. Dấu switches to Tiếng Việt when it reopens; until then it stays in English.")
    }

    @Test("pending, following macOS: first sentence kept, both languages named in themselves")
    func pendingFollowsMacOS() {
        let status = AppLanguage.Status(current: "en", next: "vi", setForDau: false)
        #expect(AppLanguage.subtitle(status, applications: "x").key
                == "Follows macOS. Dấu switches to %@ when it reopens; until then it stays in %@.")
        #expect(subtitle(status, "en") == "Follows macOS. Dấu switches to Tiếng Việt when it reopens; until then it stays in English.")
        #expect(subtitle(AppLanguage.Status(current: "vi", next: "en", setForDau: false), "vi")
                == "Theo macOS. Dấu dùng English sau khi mở lại; đến lúc đó vẫn hiện Tiếng Việt.")
    }

    @Test("not pending: exactly the two forms of before")
    func notPending() {
        for setForDau in [true, false] {
            let status = AppLanguage.Status(current: "vi", next: "vi", setForDau: setForDau)
            #expect(AppLanguage.subtitle(status, applications: "x").key
                    == AppLanguage.subtitle(setForDau: setForDau, applications: "x").key)
        }
    }

    @Test("the Reopen button in Vietnamese")
    func reopenWords() {
        #expect(SnapshotLocalization.text("Reopen Dấu", "vi") == "Mở lại Dấu")
    }
}

/// "Reopen Dấu" (`AppRelauncher`): the helper waits for the process to end, then runs the
/// opener on the bundle. Tests use `sleep` as the process and `touch` as the opener, so
/// nothing is launched.
@Suite("Reopen helper")
struct AppRelauncherTests {
    func temporaryFile() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("dau-reopen-\(UUID().uuidString)")
    }

    @Test("opens the bundle only after the process it waits for has ended")
    func waitsThenOpens() throws {
        let waited = Process()
        waited.executableURL = URL(fileURLWithPath: "/bin/sleep")
        waited.arguments = ["0.6"]
        try waited.run()
        let marker = temporaryFile()
        defer { try? FileManager.default.removeItem(at: marker) }
        let helper = AppRelauncher.helper(waitingFor: waited.processIdentifier, thenOpen: marker, opener: "/usr/bin/touch")
        try helper.run()
        Thread.sleep(forTimeInterval: 0.3)
        #expect(waited.isRunning)
        #expect(!FileManager.default.fileExists(atPath: marker.path))
        waited.waitUntilExit()
        helper.waitUntilExit()
        #expect(helper.terminationStatus == 0)
        #expect(FileManager.default.fileExists(atPath: marker.path))
    }

    @Test("a bundle path with spaces and non-ASCII letters reaches the opener intact")
    func quoting() throws {
        let marker = FileManager.default.temporaryDirectory.appendingPathComponent("Dấu \(UUID().uuidString) 'x'.app")
        defer { try? FileManager.default.removeItem(at: marker) }
        // A process that has already ended: the helper opens at once.
        let ended = Process()
        ended.executableURL = URL(fileURLWithPath: "/usr/bin/true")
        try ended.run()
        ended.waitUntilExit()
        let helper = AppRelauncher.helper(waitingFor: ended.processIdentifier, thenOpen: marker, opener: "/usr/bin/touch")
        try helper.run()
        helper.waitUntilExit()
        #expect(FileManager.default.fileExists(atPath: marker.path))
    }

    @Test("the real opener is /usr/bin/open on this app's own process and bundle")
    func realArguments() {
        let helper = AppRelauncher.helper(waitingFor: 4242, thenOpen: URL(fileURLWithPath: "/Applications/Dấu.app"))
        #expect(helper.executableURL?.path == "/bin/sh")
        #expect(Array(helper.arguments?.suffix(3) ?? []) == ["4242", "/Applications/Dấu.app", "/usr/bin/open"])
    }
}
