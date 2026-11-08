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
}
