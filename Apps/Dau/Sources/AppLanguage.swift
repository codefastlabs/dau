import AppKit
import SwiftUI

/// The language of Dấu's own interface (D41). macOS picks it at launch from the user's
/// preferred languages, or from the language the user set for Dấu alone in System
/// Settings › General › Language & Region › Applications. Dấu only shows which one it
/// is and opens that pane; it never writes the language (N1, N4).
enum AppLanguage {
    /// Reads one key of Dấu's own preferences domain; nil when the key is not there.
    typealias DomainReader = (_ key: String) -> Any?

    /// The key macOS writes into the app's own domain when the user sets a language for
    /// Dấu only (measured 08/11/2026: `AppleLanguages` = (vi-VN, en, en-VN) in
    /// com.codefastlabs.dau).
    static let domainKey = "AppleLanguages"

    /// The localization Dấu is showing: the one macOS chose for this launch.
    static func current(in bundle: Bundle = .main) -> String {
        bundle.preferredLocalizations.first ?? "en"
    }

    /// A language named in that language, as macOS lists languages: "Tiếng Việt",
    /// "English", "Français". The code itself when Foundation has no name for it.
    static func name(of code: String) -> String {
        let locale = Locale(identifier: code)
        guard let name = locale.localizedString(forLanguageCode: code), let first = name.first else { return code }
        return String(first).uppercased(with: locale) + name.dropFirst()
    }

    /// Whether the language is set for Dấu only: the app's own domain has the key.
    static func isSetForDau(read: DomainReader = { appDomainValue($0) }) -> Bool {
        read(domainKey) != nil
    }

    /// A key of `domain` alone, for the current user on any host. Not `UserDefaults.standard`:
    /// that falls through to the global domain (where every Mac has `AppleLanguages`) and to
    /// launch arguments (`-AppleLanguages`), so it would always find the key.
    static func appDomainValue(_ key: String, domain: String? = Bundle.main.bundleIdentifier) -> Any? {
        guard let domain else { return nil }
        // Pick up a change made in System Settings while Dấu runs.
        CFPreferencesAppSynchronize(domain as CFString)
        return CFPreferencesCopyValue(key as CFString, domain as CFString,
                                      kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
    }

    /// The row's subtitle. `applications`: macOS's own name of the Applications section of
    /// Language & Region, in the system's language (D38).
    static func subtitle(setForDau: Bool, applications: String) -> LocalizedStringResource {
        setForDau
            ? "Set for Dấu only. Click Change… to pick another language, or remove Dấu from the \(applications) list."
            : "Follows macOS. To set a language for Dấu only, click Change…, then under \(applications) click + and choose Dấu."
    }
}

/// "Ngôn ngữ" on Updates & Support (D41; artboards "Cài đặt – hàng Ngôn ngữ"): the
/// language Dấu shows, how it was chosen, and "Change…", which opens Language & Region.
/// Read only, laid out as the "Remember the input source for each window" row of Apps.
struct LanguageRow: View {
    @State private var setForDau = AppLanguage.isSetForDau()

    var body: some View {
        let ui = SystemUINames.system()
        LabeledContent {
            HStack(spacing: 8) {
                Text(verbatim: AppLanguage.name(of: AppLanguage.current()))
                    .foregroundStyle(.secondary)
                    .fixedSize()
                Button("Change…") { SystemSettings.openLanguageAndRegion() }
                    .help(Text("Open \(ui.languageAndRegion)"))
                    .accessibilityHint(Text("Open \(ui.languageAndRegion)"))
            }
        } label: {
            Text("Language")
            Text(AppLanguage.subtitle(setForDau: setForDau, applications: ui.languageRegionApplications))
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            setForDau = AppLanguage.isSetForDau()
        }
    }
}
