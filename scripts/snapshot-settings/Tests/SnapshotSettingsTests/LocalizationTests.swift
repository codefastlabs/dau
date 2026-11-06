import Foundation
import Testing
@testable import SnapshotSettings

/// The app's String Catalog as SwiftPM compiles it (D41): English keys, English and
/// Vietnamese text. Completeness and placeholders of every entry: scripts/check-l10n.
@Suite("String Catalog")
struct LocalizationTests {
    @Test("both languages are compiled; English is the key, Vietnamese the translation")
    func languages() {
        #expect(SnapshotLocalization.bundle("en") != nil)
        #expect(SnapshotLocalization.bundle("vi") != nil)
        #expect(SnapshotLocalization.text("Dấu Settings", "en") == "Dấu Settings")
        #expect(SnapshotLocalization.text("Dấu Settings", "vi") == "Cài đặt Dấu")
        #expect(SnapshotLocalization.text("Simple Telex", "vi") == "Telex đơn giản")
    }

    @Test("section titles and search words have a Vietnamese text of their own")
    func sectionWords() {
        for section in SettingsSection.allCases {
            for resource in [section.titleResource] + section.keywordResources
            where !["Telex", "VNI", "Beta"].contains(resource.key) {
                #expect(SnapshotLocalization.text(resource.key, "vi") != resource.key, "\(resource.key)")
            }
        }
    }

    @Test("several names in one sentence land in the Vietnamese order")
    func placeholders() {
        let key = "You’ll remove Dấu from %@ in %@; then Dấu is moved to the %@."
        #expect(String(format: SnapshotLocalization.text(key, "vi"), "Nguồn đầu vào", "Cài đặt hệ thống", "Thùng rác")
                == "Bạn sẽ bỏ Dấu khỏi Nguồn đầu vào trong Cài đặt hệ thống; sau đó Dấu được chuyển vào Thùng rác.")
    }
}
