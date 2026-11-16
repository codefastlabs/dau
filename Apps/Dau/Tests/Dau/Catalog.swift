import Foundation

/// The app's String Catalog (Localizable.xcstrings, symlinked from Apps/Dau/Resources and
/// compiled by SwiftPM into this target's resource bundle), for the tests.
///
/// The app's views look their text up in `Bundle.main`, which in the test runner is
/// Xcode's, so the tests read a language straight from `bundle(_:)`.
enum Catalog {
    /// The compiled `<language>.lproj` of the catalog (`en`, `vi`), or nil.
    static func bundle(_ language: String) -> Bundle? {
        Bundle.module.url(forResource: language, withExtension: "lproj").flatMap(Bundle.init(url:))
    }

    /// The catalog's text for `key` in `language`; the key itself when there is none.
    static func text(_ key: String, _ language: String) -> String {
        bundle(language)?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
}
