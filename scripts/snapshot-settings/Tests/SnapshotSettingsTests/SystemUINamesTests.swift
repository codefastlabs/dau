import Foundation
import Testing
@testable import SnapshotSettings

/// macOS's interface names as the user's macOS shows them (D38, `SystemUINames`), on fake
/// tables with the shapes of the real ones.
@Suite("System UI names")
struct SystemUINamesTests {
    // Localizable.loctable of KeyboardSettings: key → English in "en", other languages by key.
    let keyboard: SystemUINames.Table = [
        "en": ["Input Sources": "Input Sources", "Edit…": "Edit…", "Allow": "Allow"],
        "vi": ["Input Sources": "Nguồn đầu vào", "Edit…": "Sửa…", "Allow": "Cho phép"],
    ]
    // Localizable.loctable of System Settings.
    let settings: SystemUINames.Table = [
        "en": ["Keyboard": "Keyboard", "General": "General"],
        "vi": ["Keyboard": "Bàn phím", "General": "Cài đặt chung"],
    ]
    // InfoPlist.loctable of System Settings: no English column, a fixed key.
    let info: SystemUINames.Table = ["vi": ["CFBundleDisplayName": "Cài đặt hệ thống"]]
    // SystemFolderLocalizations: per language, keyed by the English name.
    let folders: SystemUINames.Table = ["vi": ["Applications": "Ứng dụng"], "en": ["Applications": "Applications"]]

    // Finder's Localizable.strings per language: "Trash" keyed by its English name.
    let finder: SystemUINames.Table = ["vi": ["Trash": "Thùng rác"], "en": ["Trash": "Trash"]]

    func names(_ languages: [String]) -> SystemUINames {
        SystemUINames(languages: languages,
                      tables: [.keyboardSettings: keyboard, .systemSettings: settings,
                               .systemSettingsInfo: info, .folderNames: folders, .finderNames: finder]) { code, language in
            language == "vi" ? "Tiếng Việt" : (language == "en" ? "Vietnamese" : nil)
        }
    }

    @Test("system language English → the English names, whatever the app speaks")
    func english() {
        let n = names(["en-VN", "vi-VN"])
        #expect(n.inputSourcesPath == "System Settings › Keyboard › Input Sources")
        #expect(n.edit == "Edit…")
        #expect(n.allow == "Allow")
        #expect(n.applications == "Applications")
        #expect(n.vietnamese == "Vietnamese")
    }

    @Test("system language Vietnamese → the system's own Vietnamese words, found by the English value")
    func vietnamese() {
        let n = names(["vi-VN", "en-VN"])
        #expect(n.inputSourcesPath == "Cài đặt hệ thống › Bàn phím › Nguồn đầu vào")
        #expect(n.edit == "Sửa…")
        #expect(n.allow == "Cho phép")
        #expect(n.applications == "Ứng dụng")
        #expect(n.vietnamese == "Tiếng Việt")
    }

    @Test("the Trash: the system's own name in the user's language, English when no table has it (D38)")
    func trash() {
        #expect(names(["vi-VN"]).trash == "Thùng rác")
        #expect(names(["en-VN", "vi-VN"]).trash == "Trash")
        #expect(names(["xx"]).trash == "Trash")
        let none = SystemUINames(languages: ["vi"], tables: [:]) { _, _ in nil }
        #expect(none.trash == "Trash")
    }

    @Test("unknown language, a name a table lacks, or no table → English")
    func fallback() {
        let unknown = names(["xx"])
        #expect(unknown.inputSourcesPath == "System Settings › Keyboard › Input Sources")
        // "Done" is in no fake table: English even in Vietnamese.
        #expect(names(["vi"]).done == "Done")
        let none = SystemUINames(languages: ["vi"], tables: [:]) { _, _ in nil }
        #expect(none.inputSourcesPath == "System Settings › Keyboard › Input Sources")
        #expect(none.vietnamese == "Vietnamese")
        #expect(names([]).keyboardPath == "System Settings › Keyboard")
    }

    @Test("a language falls back to the next preferred one for a name it lacks")
    func nextLanguage() {
        // pt has Input Sources only; the next language (vi) supplies Edit….
        var table = keyboard
        table["pt"] = ["Input Sources": "Fontes de Entrada"]
        let n = SystemUINames(languages: ["pt-BR", "vi"], tables: [.keyboardSettings: table]) { _, _ in nil }
        #expect(n.inputSources == "Fontes de Entrada")
        #expect(n.edit == "Sửa…")
    }

    @Test("the real tables read on this Mac; every name resolves (English at worst)")
    func real() {
        let tables = SystemUINames.loadTables()
        guard tables[.keyboardSettings]?.isEmpty == false else { return }
        let en = SystemUINames.system(languages: ["en"])
        #expect(en.inputSourcesPath == "System Settings › Keyboard › Input Sources")
        #expect(en.name(.applications) == "Applications")
        let vi = SystemUINames.system(languages: ["vi"])
        #expect(vi.inputSources == "Nguồn đầu vào")
        #expect(vi.systemSettings == "Cài đặt hệ thống")
        if tables[.finderNames]?["vi"] != nil { #expect(vi.trash == "Thùng rác") }
        #expect(en.trash == "Trash")
    }

    // The input method's InfoPlist.strings per language (compiled from its catalog).
    let inputMethod: SystemUINames.Table = [
        "en": ["CFBundleName": "Dấu", "com.codefastlabs.dau.inputmethod.Dau.vi": "Dấu – Vietnamese"],
        "vi": ["CFBundleName": "Dấu", "com.codefastlabs.dau.inputmethod.Dau.vi": "Dấu – Tiếng Việt"],
    ]

    func inputSourceName(_ languages: [String]) -> String {
        SystemUINames(languages: languages, tables: [.dauInputMethod: inputMethod]) { _, _ in nil }.dauInputSource
    }

    @Test("Dấu's input source name follows the system's languages, as macOS picks it (D41)")
    func dauInputSource() {
        #expect(inputSourceName(["en-VN", "vi-VN"]) == "Dấu – Vietnamese")
        #expect(inputSourceName(["vi-VN", "en-VN"]) == "Dấu – Tiếng Việt")
        // No Dấu localization for Japanese: macOS uses the next language Dấu has…
        #expect(inputSourceName(["ja-JP", "vi-VN"]) == "Dấu – Tiếng Việt")
        // …or the development language, English.
        #expect(inputSourceName(["ja-JP"]) == "Dấu – Vietnamese")
        // Input method not found: the English name.
        let none = SystemUINames(languages: ["vi"], tables: [:]) { _, _ in nil }
        #expect(none.dauInputSource == "Dấu – Vietnamese")
    }

    @Test("the English fallback is the input method catalog's English mode name")
    func dauInputSourceEnglishMatchesCatalog() throws {
        let catalog = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Apps/DauInputMethod/Resources/InfoPlist.xcstrings")
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: catalog)) as? [String: Any]
        let strings = json?["strings"] as? [String: Any]
        let mode = strings?["com.codefastlabs.dau.inputmethod.Dau.vi"] as? [String: Any]
        let en = ((mode?["localizations"] as? [String: Any])?["en"] as? [String: Any])?["stringUnit"] as? [String: Any]
        #expect(en?["value"] as? String == SystemUIName.dauInputSource.english)
    }
}
