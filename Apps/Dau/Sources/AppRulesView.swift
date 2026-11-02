import AppKit
import SwiftUI
import DauShared

/// "Ứng dụng" (mockup "SettingsApps"): the macOS option that remembers the input source
/// per window, shown read-only with "Đổi…" (D5, N4); "Quy tắc riêng", the stored rules
/// (D5, D13); and "Đề xuất", the installed apps of the compatibility list without a
/// rule, each with "Bật gạch chân" (D13: nothing is turned on until the user clicks it).
/// Search field and + sit in the toolbar, as in the mockup header.
struct AppRulesView: View {
    @Environment(SettingsModel.self) private var model
    @State private var query = ""
    @State private var isAdding = false
    @State private var perWindow = DocumentInputSource.isOn()
    @State private var installedSuggestions = AppDirectory.installedSuggestions(in: .empty)
    @FocusState private var focusedRule: String?

    /// Installed suggested apps without a stored rule (not stored, D13).
    private var suggestions: [AppRule] {
        model.settings.suggestions(from: model.compatibility,
                                   isInstalled: installedSuggestions.contains)
    }

    private func matching(_ rules: [AppRule]) -> [AppRule] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return rules }
        return rules.filter {
            AppDirectory.name(for: $0).searchContains(query) || $0.bundleID.searchContains(query)
        }
    }

    var body: some View {
        let rules = model.settings.appRules
        let visibleRules = matching(rules)
        let visibleSuggestions = matching(suggestions)
        SettingsPage(SettingsSection.apps.title, search: $query, searchPrompt: Text("Tìm ứng dụng"),
                     add: HeaderAdd(label: String(localized: "Thêm ứng dụng"), action: { isAdding = true })) {
            Section(header: Text("Việt/Anh theo cửa sổ")) {
                LabeledContent {
                    HStack(spacing: 8) {
                        // Not readable: no value rather than a guess (N5).
                        if let perWindow {
                            (perWindow ? Text("Đang bật") : Text("Đang tắt"))
                                .foregroundStyle(.secondary)
                                .fixedSize()
                        }
                        Button("Đổi…") { SystemSettings.openKeyboard() }
                            .accessibilityLabel(Text("Đổi tuỳ chọn nhớ nguồn nhập liệu theo từng cửa sổ"))
                            .accessibilityHint(Text("Mở Cài đặt Bàn phím của macOS"))
                    }
                } label: {
                    Text("Nhớ nguồn nhập liệu theo từng cửa sổ")
                    Text("Tuỳ chọn “Tự động chuyển sang nguồn đầu vào của tài liệu” của macOS")
                }
                .layoutProbe("firstRow")
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                perWindow = DocumentInputSource.isOn()
                installedSuggestions = AppDirectory.installedSuggestions(in: model.compatibility)
            }

            Section(header: Text("Quy tắc riêng")) {
                if rules.isEmpty {
                    Text("Chưa có quy tắc riêng. Bấm + để thêm.")
                } else if visibleRules.isEmpty {
                    Text("Không có ứng dụng nào khớp.")
                } else {
                    ForEach(visibleRules) { rule in
                        AppRuleRow(rule: rule)
                            .focusable()
                            .focused($focusedRule, equals: rule.bundleID)
                            .onTapGesture { focusedRule = rule.bundleID }
                            .onDeleteCommand { remove(rule) }
                            .contextMenu {
                                Button("Xoá quy tắc", role: .destructive) { remove(rule) }
                            }
                            .accessibilityActions {
                                Button("Xoá quy tắc") { remove(rule) }
                            }
                    }
                }
            }

            // Only while an installed suggested app has no rule (D13); hidden too when
            // the search matches none of them.
            if !visibleSuggestions.isEmpty {
                Section {
                    ForEach(visibleSuggestions) { suggestion in
                        SuggestionRow(suggestion: suggestion) {
                            model.settings.acceptSuggestion(suggestion)
                        }
                    }
                } header: {
                    // The section's description goes under its title, above the card,
                    // as in System Settings. N5: only what M3 measured (D13): in-place
                    // typing went wrong only when keys came less than 10 ms apart;
                    // underlining fixed Chrome and VS Code but not Terminal, so the text
                    // says when to choose it, not that it always helps. Wording approved
                    // by the user (30/10/2026).
                    SectionHeader(
                        title: Text("Đề xuất"),
                        description: Text("“Đề xuất” đến từ danh sách tương thích: app có thể sai chữ khi gõ rất nhanh. Chỉ chọn “Có gạch chân” khi một app bị lỗi chữ lúc gõ."))
                }
            }
        }
        .onAppear {
            installedSuggestions = AppDirectory.installedSuggestions(in: model.compatibility)
        }
        .sheet(isPresented: $isAdding) {
            AddAppRuleSheet()
        }
    }

    private func remove(_ rule: AppRule) {
        model.settings.removeRule(for: rule.bundleID)
        if focusedRule == rule.bundleID { focusedRule = nil }
    }
}

/// One stored rule: icon 24, name, "Đề xuất" chip when it came from the compatibility
/// list, underline popup (D5). Removed with the context menu or the Delete key while
/// focused (the system draws the focus ring).
struct AppRuleRow: View {
    @Environment(SettingsModel.self) private var model
    let rule: AppRule

    var body: some View {
        let name = AppDirectory.name(for: rule)
        LabeledContent {
            Picker(selection: underlineBinding) {
                Text("Không gạch chân").tag(false)
                Text("Có gạch chân").tag(true)
            } label: {
                Text("Gạch chân khi gõ trong \(name)")
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .fixedSize()
        } label: {
            HStack(spacing: 8) {
                AppIcon(bundleID: rule.bundleID, size: AppIcon.singleLine)
                Text(verbatim: name)
                    .lineLimit(1)
                if rule.source == .suggested {
                    Chip(Text("Đề xuất"), height: 20, fontSize: 11)
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(verbatim: name))
    }

    /// The stored rule keeps its place and source whatever the choice (D13).
    private var underlineBinding: Binding<Bool> {
        Binding {
            (model.settings.rule(for: rule.bundleID) ?? rule).underline
        } set: { newValue in
            model.settings.setUnderline(newValue, for: rule.bundleID)
        }
    }
}

/// One suggestion: icon 32, name, a secondary line, and "Bật gạch chân", which stores
/// the rule. The list's per-app notes are for maintainers and are not shown (N5);
/// every row says the same, as the section description does.
struct SuggestionRow: View {
    let suggestion: AppRule
    let accept: () -> Void

    var body: some View {
        let name = AppDirectory.name(for: suggestion)
        LabeledContent {
            Button("Bật gạch chân", action: accept)
                .accessibilityLabel(Text("Bật gạch chân cho \(name)"))
        } label: {
            HStack(spacing: 8) {
                AppIcon(bundleID: suggestion.bundleID, size: AppIcon.twoLine)
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: name)
                        .lineLimit(1)
                    Subtitle(Text("Có thể sai chữ khi gõ rất nhanh"))
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(verbatim: name))
    }
}

/// An app's icon, hidden from VoiceOver (the row reads the name). Sizes as System
/// Settings shows app icons in its rows (measured on macOS 27.2, 1x display; the icon
/// art fills about 80% of its frame, Dấu's own icon included):
/// - `singleLine` 24: a one-line row of an app list with a control, Privacy & Security
///   › Accessibility (art 20 pt, rows 42 tall);
/// - `twoLine` 32: an app with a secondary line, General › Login Items & Extensions ›
///   Background App Activity and Notifications › Application Notifications (art 26 pt,
///   frame from the card's edge + 10, text 10 after it).
struct AppIcon: View {
    static let singleLine: CGFloat = 24
    static let twoLine: CGFloat = 32

    let bundleID: String
    let size: CGFloat

    var body: some View {
        Image(nsImage: AppDirectory.icon(for: bundleID))
            .resizable()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// Names and icons of installed apps, through Launch Services.
@MainActor
enum AppDirectory {
    static func url(for bundleID: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
    }

    nonisolated static func name(at url: URL) -> String {
        FileManager.default.displayName(atPath: url.path)
            .replacingOccurrences(of: ".app", with: "", options: [.anchored, .backwards])
    }

    /// The app's own name if it is installed, else the name stored in the rule, else
    /// the bundle ID.
    static func name(for rule: AppRule) -> String {
        if let url = url(for: rule.bundleID) { return name(at: url) }
        return rule.displayName ?? rule.bundleID
    }

    /// The suggested bundle IDs of `list` that are installed on this Mac.
    static func installedSuggestions(in list: CompatibilityList) -> Set<String> {
        Set(list.suggestedBundleIDs.filter { url(for: $0) != nil })
    }

    static func icon(for bundleID: String) -> NSImage {
        if let url = url(for: bundleID) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        return NSWorkspace.shared.icon(for: .application)
    }
}
