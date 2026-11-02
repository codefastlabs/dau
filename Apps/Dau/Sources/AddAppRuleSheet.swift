import AppKit
import SwiftUI
import UniformTypeIdentifiers
import DauShared

/// "Thêm quy tắc cho ứng dụng" sheet (mockup "SettingsAppsAdd" for the content: title,
/// search, the apps without a stored rule (apps of the compatibility list carry the
/// "Đề xuất" chip), "Khi đang gõ" (the rule's only setting, D5), Huỷ / Thêm).
///
/// Built from system parts as System Settings builds its sheets (D9; measured on macOS
/// 27.2, Displays › Advanced… and Keyboard › Input Sources › Edit…): a grouped `Form`
/// (cards 20 pt from the sheet's edges) and the sheet's own button bar under a divider,
/// from the toolbar's cancellation and confirmation placements (64 × 24 buttons, 20 pt
/// from the right and bottom edges). The search field is the system one of
/// `searchable`, which a sheet puts at its top trailing edge. "Chọn ứng dụng khác…"
/// (an automatic toolbar item, at the leading end of the button bar) opens the system
/// open panel for apps stored elsewhere.
struct AddAppRuleSheet: View {
    @Environment(SettingsModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var candidates: [AppCandidate] = []
    @State private var selection: AppCandidate.ID?
    @State private var underline = false

    /// System Settings' grouped-Form sheet (Displays › Advanced…) is 470 wide.
    static let width: CGFloat = 470
    /// Height of the app list: the mockup's list card.
    static let listHeight: CGFloat = 188

    private var visibleCandidates: [AppCandidate] {
        AppCandidate.matching(candidates, query: query)
    }

    /// The selection while it is on screen: "Thêm" and Return add only a visible app.
    private var visibleSelection: AppCandidate.ID? {
        AppCandidate.selection(selection, among: visibleCandidates)
    }

    var body: some View {
        Form {
            Section {
                List(visibleCandidates, selection: $selection) { candidate in
                    HStack {
                        // System Settings' app list rows (Privacy & Security ›
                        // Accessibility): a 24 pt icon (`AppIcon.singleLine`).
                        Image(nsImage: candidate.icon)
                            .resizable()
                            .frame(width: AppIcon.singleLine, height: AppIcon.singleLine)
                            .accessibilityHidden(true)
                        Text(verbatim: candidate.name)
                            .lineLimit(1)
                        if candidate.suggested {
                            Chip(Text("Đề xuất"), height: 20, fontSize: 11)
                        }
                    }
                    .tag(candidate.id)
                }
                // The list scrolls inside its card, so "Khi đang gõ" stays in view.
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(height: Self.listHeight)
                .accessibilityLabel(Text("Ứng dụng"))
            } header: {
                Text("Thêm quy tắc cho ứng dụng")
            }

            Section {
                Picker("Khi đang gõ", selection: $underline) {
                    Text("Không gạch chân").tag(false)
                    Text("Có gạch chân").tag(true)
                }
                .pickerStyle(.segmented)
            }
        }
        .formStyle(.grouped)
        .frame(width: Self.width)
        .searchable(text: $query, prompt: Text("Tìm trong Ứng dụng"))
        // A query that hides the selected app clears the selection.
        .onChange(of: query) { selection = visibleSelection }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Chọn ứng dụng khác…", action: chooseApp)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Huỷ", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Thêm", action: add)
                    .keyboardShortcut(.defaultAction)
                    .disabled(visibleSelection == nil)
            }
        }
        .task { await loadApps() }
    }

    /// Apps in the Applications folders plus running apps, without the ones that
    /// already have a stored rule and without Dấu itself.
    private func loadApps() async {
        let ruled = Set(model.settings.appRules.map(\.bundleID))
        let list = model.compatibility
        let own = Bundle.main.bundleIdentifier
        var running: [AppListing] = []
        for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
            if let id = app.bundleIdentifier, let url = app.bundleURL {
                running.append(AppListing(bundleID: id, name: AppDirectory.name(at: url), path: url.path))
            }
        }
        let installed = await Task.detached(priority: .userInitiated) { AppListing.installed() }.value
        var seen = Set<String>()
        candidates = (installed + running)
            .filter { $0.bundleID != own && !ruled.contains($0.bundleID) && seen.insert($0.bundleID).inserted }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            .map { AppCandidate(bundleID: $0.bundleID, name: $0.name,
                                icon: NSWorkspace.shared.icon(forFile: $0.path),
                                suggested: list.suggestion(for: $0.bundleID) != nil) }
    }

    /// Picks any app with the system open panel; only the bundle ID is kept.
    private func chooseApp() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
        panel.prompt = String(localized: "Chọn")
        panel.message = String(localized: "Chọn ứng dụng cần quy tắc riêng")
        guard panel.runModal() == .OK, let url = panel.url,
              let id = Bundle(url: url)?.bundleIdentifier else { return }
        if !candidates.contains(where: { $0.bundleID == id }) {
            candidates.insert(
                AppCandidate(bundleID: id, name: AppDirectory.name(at: url),
                             icon: NSWorkspace.shared.icon(forFile: url.path),
                             suggested: model.compatibility.suggestion(for: id) != nil),
                at: 0)
        }
        query = ""
        selection = id
    }

    /// Stores the rule. An app of the compatibility list keeps its "Đề xuất" chip in
    /// "Quy tắc riêng" (source `.suggested`), as when it is accepted from "Đề xuất".
    private func add() {
        guard let id = visibleSelection, let candidate = candidates.first(where: { $0.id == id }) else { return }
        model.settings.upsert(AppRule(
            bundleID: candidate.bundleID, displayName: candidate.name,
            underline: underline, source: candidate.suggested ? .suggested : .user))
        dismiss()
    }
}

struct AppCandidate: Identifiable {
    let bundleID: String
    let name: String
    let icon: NSImage
    /// In the compatibility list: shown with the "Đề xuất" chip.
    var suggested = false
    var id: String { bundleID }

    /// The candidates whose name or bundle ID contains `query`, ignoring case and
    /// diacritics (`searchContains`); all of them for an empty query.
    static func matching(_ candidates: [AppCandidate], query: String) -> [AppCandidate] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return candidates }
        return candidates.filter { $0.name.searchContains(query) || $0.bundleID.searchContains(query) }
    }

    /// `selection` if it is among `visible`, else nil: a selected app hidden by the
    /// search is no longer selected, so "Thêm" turns off.
    static func selection(_ selection: ID?, among visible: [AppCandidate]) -> ID? {
        guard let selection, visible.contains(where: { $0.id == selection }) else { return nil }
        return selection
    }
}

/// An app found on disk (Sendable, built off the main thread).
struct AppListing: Sendable {
    let bundleID: String
    let name: String
    let path: String

    static let folders = ["/Applications", "/Applications/Utilities",
                          "/System/Applications", "/System/Applications/Utilities"]

    /// Apps in the standard Applications folders. Folders that cannot be read are
    /// skipped; running apps and the open panel cover the rest.
    static func installed() -> [AppListing] {
        let fm = FileManager.default
        var result: [AppListing] = []
        for folder in folders {
            guard let names = try? fm.contentsOfDirectory(atPath: folder) else { continue }
            for name in names where name.hasSuffix(".app") {
                let url = URL(fileURLWithPath: folder).appendingPathComponent(name)
                guard let id = Bundle(url: url)?.bundleIdentifier else { continue }
                result.append(AppListing(bundleID: id, name: AppDirectory.name(at: url), path: url.path))
            }
        }
        return result
    }
}
