import Foundation
import Testing
import DauShared
@testable import SnapshotSettings

/// Pins every "keys → result" the Settings window shows (computed by the engine at run
/// time) and the shortcut parsing, so the window says what its labels claim (N5).
/// Expected values follow Vietnamese spelling and Decisions.md.
@Suite("Settings samples")
struct SettingsSamplesTests {
    static let allSettings: [DauSettings] = DauSettings.TypingMethod.allCases.flatMap { method in
        DauSettings.TonePlacement.allCases.flatMap { placement in
            [true, false].map { DauSettings(typingMethod: method, tonePlacement: placement, freeMarking: $0) }
        }
    }

    @Test("preview types the mockup sentence in every configuration", arguments: allSettings)
    func preview(_ settings: DauSettings) {
        let expected = settings.tonePlacement == .modern ? "hoà bình, tiếng Việt" : "hòa bình, tiếng Việt"
        #expect(SettingsSamples.preview(settings).result == expected)
    }

    @Test("preview keys follow the mockup for the default settings")
    func previewKeys() {
        #expect(SettingsSamples.preview(.defaults).keys == "hoaf binhf, tieengs Vieetj")
        #expect(SettingsSamples.preview(DauSettings(typingMethod: .vni)).keys == "hoa2 binh2, tie61ng Vie65t")
    }

    @Test("preview output is precomposed (D3)", arguments: allSettings)
    func previewIsNFC(_ settings: DauSettings) {
        #expect(!SettingsSamples.preview(settings).result.unicodeScalars.contains { (0x300...0x36F).contains($0.value) })
    }

    @Test("restore: foreign words come back, Vietnamese stays (D4)", arguments: DauSettings.TypingMethod.allCases)
    func restore(_ method: DauSettings.TypingMethod) {
        #expect(SettingsSamples.restore(method).map(\.result) == ["windows", "Sunrise", "việt"])
    }

    @Test("Vietnamese wins, doubling keeps the original (D4, D26, D36)", arguments: DauSettings.TypingMethod.allCases)
    func winsAndKeep(_ method: DauSettings.TypingMethod) {
        let wins = SettingsSamples.vietnameseWins(method), keep = SettingsSamples.keepOriginal(method)
        if method == .vni {
            #expect((wins.keys, wins.result) == ("lan2", "làn"))
            #expect((keep.keys, keep.result) == ("lan22", "lan2"))
        } else {
            #expect((wins.keys, wins.result) == ("car", "cả"))
            #expect((keep.keys, keep.result) == ("carr", "car"))
        }
    }

    @Test("hoc + nặng → học (D20)", arguments: DauSettings.TypingMethod.allCases)
    func addMarks(_ method: DauSettings.TypingMethod) {
        let example = SettingsSamples.addMarks(method)
        #expect(example.displayed == "hoc" && example.result == "học")
    }
}

@Suite("Input source shortcut")
struct InputSourceShortcutTests {
    func entry(_ enabled: Bool, _ character: Int, _ keyCode: Int, _ flags: Int) -> [String: Any] {
        ["enabled": enabled, "value": ["parameters": [character, keyCode, flags], "type": "standard"]]
    }

    @Test("⌃Space and ⌃⌥Space (macOS defaults for entries 60 and 61)")
    func defaults() {
        #expect(InputSourceShortcut.keycaps(from: entry(true, 32, 49, 262_144)) == ["⌃", "Space"])
        #expect(InputSourceShortcut.keycaps(from: entry(true, 32, 49, 786_432)) == ["⌃", "⌥", "Space"])
    }

    @Test("letters, modifiers order, disabled and malformed entries")
    func others() {
        #expect(InputSourceShortcut.keycaps(from: entry(true, 107, 40, 1_179_648)) == ["⇧", "⌘", "K"])
        #expect(InputSourceShortcut.keycaps(from: entry(false, 32, 49, 262_144)) == nil)
        #expect(InputSourceShortcut.keycaps(from: ["enabled": true]) == nil)
        #expect(InputSourceShortcut.keycaps(from: entry(true, 65_535, 999, 262_144)) == nil)
    }
}

@Suite("Sidebar search")
struct SidebarSearchTests {
    /// The words as the Vietnamese window shows them, from the app's catalog.
    func vi(_ resource: LocalizedStringResource) -> String { SnapshotLocalization.text(resource.key, "vi") }

    @Test("case-insensitive, in the words the window shows (English: the catalog's keys)")
    func search() {
        #expect(SettingsSection.typing.matches("typing"))
        #expect(SettingsSection.smart.matches("RESTORE"))
        #expect(SettingsSection.apps.matches("app rules"))
        #expect(!SettingsSection.apps.matches("english"))
        #expect(!SettingsSection.updates.matches("telex"))
        #expect(SettingsSection.allCases.allSatisfy { $0.matches("") })
    }

    @Test("Vietnamese: case- and diacritic-insensitive, đ read as d")
    func searchVietnamese() {
        #expect(SettingsSection.typing.matches("go phim", localize: vi))
        #expect(SettingsSection.smart.matches("khôi phục", localize: vi))
        #expect(SettingsSection.apps.matches("GẠCH CHÂN", localize: vi))
        #expect(SettingsSection.apps.matches("DE XUAT", localize: vi))
        #expect(!SettingsSection.apps.matches("tiếng anh", localize: vi))
        #expect(!SettingsSection.updates.matches("telex", localize: vi))
        // The English words are not shown in Vietnamese, so they do not match there.
        #expect(!SettingsSection.apps.matches("underline", localize: vi))
    }

    @Test("the visible row titles of Apps and Updates & Support are found, in both languages")
    func rowTitles() {
        for query in ["Suggested", "Turn On Underline", "Add App", "underline", "no underline"] {
            #expect(SettingsSection.apps.matches(query), "\(query)")
        }
        for query in ["Uninstall", "Remove Dấu from this Mac"] {
            #expect(SettingsSection.updates.matches(query), "\(query)")
        }
        for query in ["Đề xuất", "Bật gạch chân", "Thêm ứng dụng", "gạch chân", "de xuat", "co gach chan"] {
            #expect(SettingsSection.apps.matches(query, localize: vi), "\(query)")
        }
        for query in ["Gỡ cài đặt", "Gỡ Dấu khỏi máy"] {
            #expect(SettingsSection.updates.matches(query, localize: vi), "\(query)")
        }
    }

    @Test("a query no section matches leaves the sidebar empty (system empty state shown)")
    func noMatch() {
        #expect(SettingsSection.allCases.filter { $0.matches("xyzzy") }.isEmpty)
    }

    @Test("the search jumps to its first match when the page shown no longer matches")
    @MainActor func searchJump() {
        let state = SettingsWindowState(.typing)
        state.query = "underline"
        #expect(state.visibleSections == [.apps])
        state.showFirstMatch()
        #expect(state.section == .apps)
    }

    @Test("no jump while the page shown still matches, nor when nothing matches")
    @MainActor func searchNoJump() {
        let state = SettingsWindowState(.updates)
        state.showFirstMatch()
        #expect(state.section == .updates)
        state.query = "xyzzy"
        state.showFirstMatch()
        #expect(state.section == .updates)
    }
}
