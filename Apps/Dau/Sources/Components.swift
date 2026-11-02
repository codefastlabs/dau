import AppKit
import SwiftUI
import DauShared

// Pieces shared by the Settings pages, the add-rule sheet and the onboarding window.
// The Settings pages and the add-rule sheet are grouped `Form`s with the system's
// metrics (D9, System Settings as the reference); the custom pieces are content from
// the mockup that has no system equivalent, kept as the mockup draws them: the preview
// (`PreviewCard`, `PreviewBox`), example chips (`Chip`, `ExampleChips`), "Mới"
// (`NewBadge`), the shortcut keycaps (`Keycap`, TypingSettingsView.swift; System
// Settings writes shortcuts as text) and the "Dấu chưa được bật" banner. The card
// primitive (`SettingsCard`), `SettingsColors` and `settingsButton` remain for the
// onboarding window only. Colors are system colors only.

/// Page and card backgrounds of the onboarding window (the Settings pages and the
/// add-rule sheet use the grouped Form's own colors), chosen among system colors (no
/// blending, no opacity) so the card is lighter than the page in both appearances, as
/// in the mockup. Resolved on macOS 27 (`--capture-window`):
/// - light: page `underPageBackgroundColor` (light gray), card `controlBackgroundColor`
///   (white), as the mockup's light gray page and white cards;
/// - dark: page `controlBackgroundColor` (near black), card `underPageBackgroundColor`
///   (dark gray), as the mockup's dark page and lighter cards.
/// Both are dynamic system colors, so they follow Increase Contrast too.
enum SettingsColors {
    static let page = Color(nsColor: NSColor(name: "DauSettingsPage") { appearance in
        appearance.isDark ? .controlBackgroundColor : .underPageBackgroundColor
    })

    static let card = Color(nsColor: NSColor(name: "DauSettingsCard") { appearance in
        appearance.isDark ? .underPageBackgroundColor : .controlBackgroundColor
    })

    static let separator = Color(nsColor: .separatorColor)
}

extension NSAppearance {
    var isDark: Bool { bestMatch(from: [.aqua, .darkAqua]) == .darkAqua }
}

/// The "+" of the Apps page: a toolbar button beside the page's search field.
struct HeaderAdd {
    var label: String
    var action: () -> Void
}

/// A Settings page: a grouped `Form` whose sections are the page's content, after the
/// "Dấu chưa được bật" banner when it shows. The Form brings System Settings' metrics:
/// 20 pt margins, cards, section headers, row heights, separators, and it scrolls
/// under the toolbar with the system's scroll edge.
///
/// The title is a leading toolbar item (`PageTitle`, see `SettingsWindow`). `search`
/// and `add`: the Apps page's header controls, as toolbar items: the system search
/// field (`searchable`) and a "+" button.
struct SettingsPage<Content: View>: View {
    let title: String
    var search: Binding<String>?
    var searchPrompt: Text?
    var add: HeaderAdd?
    @ViewBuilder var content: Content

    init(_ title: String, search: Binding<String>? = nil, searchPrompt: Text? = nil,
         add: HeaderAdd? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.search = search
        self.searchPrompt = searchPrompt
        self.add = add
        self.content = content()
    }

    var body: some View {
        Form {
            TamperedBanner()
            NotEnabledBanner()
            content
        }
        .formStyle(.grouped)
        // Content scrolled under the toolbar must not show through the title (UI-CHECKS
        // item 9): the system's hard scroll edge on macOS 26+.
        .modifier(HardTopScrollEdge())
        .layoutProbe("content")
        .toolbar {
            if #available(macOS 26, *) {
                ToolbarItem(placement: .navigation) { PageTitle(title: title) }
                    .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .navigation) { PageTitle(title: title) }
            }
        }
        .modifier(PageSearch(text: search, prompt: searchPrompt, add: add))
    }
}

/// macOS 26+: the system's hard scroll-edge effect under the toolbar (solid material
/// and edge) instead of the soft fade, so content scrolled under the header never
/// shows through the title. A system style, not a custom metric.
struct HardTopScrollEdge: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.scrollEdgeEffectStyle(.hard, for: .top)
        } else {
            content
        }
    }
}

/// The page title in the toolbar, as System Settings draws it: 15 pt bold, primary,
/// starting 20 pt from the sidebar (the detail column's margin, where the system's
/// own navigation title sits; measured 252.5 with the 232 pt sidebar).
///
/// Why not the system's navigation title: System Settings has no sidebar toggle, so
/// the window removes it (`.toolbar(removing: .sidebarToggle)`, `SettingsWindow`).
/// Without the toggle the toolbar holds no item on most pages and the system title
/// shrinks: AppKit collapses the toolbar to a 32 pt title bar with the small window
/// title (measured on macOS 27.2, 1x display). This item keeps the toolbar at System
/// Settings' 52 pt with its 15 pt bold title on every page; `HiddenWindowTitle` and
/// `RemoveToolbarTitle` keep the system title from being drawn a second time.
struct PageTitle: View {
    let title: String

    var body: some View {
        Text(verbatim: title)
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.primary)
            .fixedSize()
            .accessibilityAddTraits(.isHeader)
            .layoutProbe("title")
            // The toolbar item starts 4 pt right of the sidebar.
            .padding(.leading, 16)
            // A fixed item width: with the text's own width the toolbar placed the
            // title half a point apart on some pages (measured 251.5 vs 252).
            .frame(width: 200, alignment: .leading)
    }
}

/// The page's toolbar search field and "+" (Apps), on the trailing side of the
/// toolbar. The system puts the search field of `searchable` last, after the "+"
/// (macOS 27.2: a `DefaultToolbarItem(kind: .search)` placed before the "+" does not
/// move it); the mockup header has them the other way round, the system order wins
/// (D9).
private struct PageSearch: ViewModifier {
    let text: Binding<String>?
    let prompt: Text?
    let add: HeaderAdd?

    func body(content: Content) -> some View {
        if let text {
            if #available(macOS 26, *) {
                content
                    .toolbar {
                        // Pushes the "+" and the search field to the trailing edge.
                        ToolbarSpacer(.flexible)
                        if let add {
                            ToolbarItem(placement: .primaryAction) { HeaderAddButton(add: add) }
                        }
                    }
                    .searchable(text: text, placement: .toolbar, prompt: prompt)
            } else {
                content
                    .toolbar {
                        if let add {
                            ToolbarItem(placement: .primaryAction) { HeaderAddButton(add: add) }
                        }
                    }
                    .searchable(text: text, placement: .toolbar, prompt: prompt)
            }
        } else {
            content
        }
    }
}

/// The toolbar "+": a system toolbar button with the "plus" symbol.
struct HeaderAddButton: View {
    let add: HeaderAdd

    var body: some View {
        Button(action: add.action) {
            Label { Text(verbatim: add.label) } icon: { Image(systemName: "plus") }
        }
        .help(Text(verbatim: add.label))
        .layoutProbe("headerAdd")
    }
}

/// Secondary text in a Form row or section header: System Settings' subtitle, 11 pt
/// regular, secondary color.
struct Subtitle: View {
    let text: Text
    init(_ text: Text) { self.text = text }

    var body: some View {
        text
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A section header with a description under the title, above the card, as System
/// Settings does (Notifications pane).
struct SectionHeader: View {
    let title: Text
    let description: Text

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            title
            Subtitle(description)
                .fontWeight(.regular)
        }
    }
}

/// A rounded card holding rows (onboarding): radius 14, 1 pt separator border.
struct SettingsCard<Content: View>: View {
    var padding: CGFloat = 0
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SettingsColors.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(SettingsColors.separator, lineWidth: 1)
        }
    }
}

/// 12 pt secondary text.
struct Hint: View {
    let text: Text
    init(_ text: Text) { self.text = text }

    var body: some View {
        text
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    /// Onboarding buttons as in the mockup: capsule, about 30 pt tall.
    func settingsButton() -> some View {
        self.controlSize(.large).buttonBorderShape(.capsule)
    }

}

/// Capsule label: configuration chips, "Đề xuất", example keys. A label, not a control.
struct Chip: View {
    let text: Text
    var height: CGFloat = 22
    var fontSize: CGFloat = 12
    var monospaced = false
    /// Emphasized: the result of an example.
    var emphasized = false

    init(_ text: Text, height: CGFloat = 22, fontSize: CGFloat = 12,
         monospaced: Bool = false, emphasized: Bool = false) {
        self.text = text
        self.height = height
        self.fontSize = fontSize
        self.monospaced = monospaced
        self.emphasized = emphasized
    }

    var body: some View {
        text
            .font(.system(size: fontSize, weight: emphasized ? .semibold : .regular,
                          design: monospaced ? .monospaced : .default))
            .foregroundStyle(emphasized ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 9)
            .frame(height: height)
            .background(.fill.tertiary, in: Capsule())
    }
}

/// "Mới" badge: accent fill with the system's text-on-accent color.
struct NewBadge: View {
    var body: some View {
        Text("Mới")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color(nsColor: .alternateSelectedControlTextColor))
            .padding(.horizontal, 7)
            .padding(.vertical, 1)
            .background(Color.accentColor, in: Capsule())
    }
}

/// "keys › result" as two chips (mockup "Thông minh"); the result is emphasized.
/// Both come from the engine (`TypingExample`). VoiceOver reads "keys thành result".
struct ExampleChips: View {
    let example: TypingExample

    var body: some View {
        HStack(spacing: 6) {
            Chip(Text(verbatim: keysText), monospaced: true)
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
            Chip(Text(verbatim: example.result), emphasized: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(keysText) thành \(example.result)"))
    }

    private var keysText: String {
        example.displayed.isEmpty ? example.keys : "\(example.displayed) + \(example.keys)"
    }
}

/// Lays chips out left to right and wraps to the next line when the row is full.
struct WrappingHStack: Layout {
    var spacing: CGFloat = 14
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0, maxX: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > width {
                y += lineHeight + lineSpacing
                x = 0
                lineHeight = 0
            }
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: proposal.width ?? maxX, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                y += lineHeight + lineSpacing
                x = bounds.minX
                lineHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

/// "Dấu chưa được bật" banner (docs/UI.md, "Các trạng thái bổ sung", mockup
/// "SettingsNotEnabled"), first on every page while Dấu is not among the enabled
/// input sources: orange tile with a white warning symbol, title, subtitle,
/// prominent button.
///
/// "Bật lại" enables Dấu (N4: the user's click, read back from Text Input Sources) and
/// the banner then turns into a green confirmation with "Hoàn tác". When macOS keeps
/// Dấu off it opens Keyboard settings with the steps; when Dấu is not installed or not
/// listed yet it opens the onboarding window, which installs it or explains the logout.
struct NotEnabledBanner: View {
    @Environment(InputSourceStatus.self) private var status
    @Environment(\.inputMethodActions) private var actions
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        let state = actions?.banner ?? .idle
        if state == .enabled {
            banner(tint: .green, symbol: "checkmark",
                   title: Text("Đã bật Dấu trong Nguồn nhập liệu"),
                   hint: Text("Bấm Hoàn tác nếu bạn đổi ý.")) {
                Button("Hoàn tác") { Task { await actions?.undoBannerEnable() } }
            }
        } else if status.isEnabled == false {
            banner(tint: .orange, symbol: "exclamationmark.triangle.fill",
                   title: Text("Dấu chưa được bật trong Nguồn nhập liệu"), hint: hint(state)) {
                if state == .notEnabled || state == .failed {
                    // The onboarding's button at the Form's control size.
                    Button("Mở Cài đặt Bàn phím…") { SystemSettings.openKeyboard() }
                        .fixedSize()
                } else {
                    Button("Bật lại") { enable() }
                        .buttonStyle(.borderedProminent)
                        .disabled(state == .working)
                }
            }
            .onChange(of: status.isEnabled) { _, isEnabled in actions?.inputSourcesChanged(isEnabled: isEnabled) }
        }
    }

    private func hint(_ state: InputMethodActions.BannerState) -> Text {
        switch state {
        case .notEnabled:
            Text("macOS chưa bật Dấu. Trong Cài đặt Bàn phím › Nguồn đầu vào, bấm Sửa…, bấm +, chọn “Dấu – Tiếng Việt” trong nhóm Tiếng Việt rồi bấm Thêm.")
        case .failed:
            Text("Chưa bật được Dấu. Bạn có thể tự thêm “Dấu – Tiếng Việt” trong Cài đặt Bàn phím › Nguồn đầu vào.")
        default:
            Text("Bạn vẫn chỉnh được cài đặt, nhưng chưa gõ được tiếng Việt.")
        }
    }

    private func enable() {
        guard let actions else {
            // Snapshots and previews: no installer, only guide (N4).
            SystemSettings.openKeyboard()
            return
        }
        Task {
            if await actions.enableFromBanner() {
                openWindow(id: OnboardingScene.id)
            }
        }
    }

    private func banner<Buttons: View>(tint: Color, symbol: String, title: Text, hint: Text,
                                       @ViewBuilder buttons: () -> Buttons) -> some View {
        noticeBanner(tint: tint, symbol: symbol, title: title, hint: hint, buttons: buttons)
    }
}

/// "Bộ gõ trên máy không phải bản Dấu đã cài" (mockup "SettingsTampered"): the input
/// method in ~/Library/Input Methods does not carry this app's signature, so whatever
/// replaced it gets every key typed with the enabled "Dấu – Tiếng Việt". "Cài lại"
/// installs the app's own copy.
struct TamperedBanner: View {
    @Environment(\.inputMethodActions) private var actions

    var body: some View {
        if let actions, actions.installedTampered {
            noticeBanner(tint: .red, symbol: "exclamationmark.triangle.fill",
                         title: Text("Bộ gõ trên máy không phải bản Dấu đã cài"),
                         hint: actions.reinstall == .failed
                            ? Text("Chưa cài lại được. Hãy gỡ cài đặt Dấu rồi cài lại từ bản tải về.")
                            : Text("Tệp bộ gõ đã bị thay hoặc sửa sau khi cài. Cài lại để gõ bằng đúng bản của Dấu.")) {
                Button("Cài lại") { Task { await actions.reinstallInputMethod() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(actions.reinstall == .working)
            }
        }
    }
}

/// A notice as the first section of the page's Form: one row with the tile, the
/// title and its subtitle, and the buttons, on the Form's card like System
/// Settings' own notices (a grouped Form on macOS draws no row background set with
/// `listRowBackground`, measured on macOS 27.2); the tile carries the color.
@MainActor @ViewBuilder
private func noticeBanner<Buttons: View>(tint: Color, symbol: String, title: Text, hint: Text,
                                         @ViewBuilder buttons: () -> Buttons) -> some View {
    Section {
        HStack(alignment: .center, spacing: 10) {
            // Mockup "SettingsNotEnabled": a tile in a system color with a white
            // symbol, at the size of the app icons in Form rows. System colors only
            // (D9).
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(tint, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                title
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Subtitle(hint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            buttons()
        }
        .accessibilityElement(children: .contain)
    }
}

/// Version string for display ("1.0.0"), or nil when the bundle has none: never "?".
enum AppVersion {
    static var marketing: String? {
        guard let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              !v.isEmpty, !v.contains("$(") else { return nil }
        return v
    }

    /// The git commit of this build (Resources/BuildCommit.txt, written by
    /// scripts/stamp-build-commit.sh), "+" when built with uncommitted changes; nil when
    /// the build had no git.
    static let commit: String? = {
        guard let url = Bundle.main.url(forResource: "BuildCommit", withExtension: "txt"),
              let c = try? String(contentsOf: url, encoding: .utf8),
              !c.isEmpty, c.count <= 12 else { return nil }
        return c
    }()

    /// "Dấu 1.0.0 (a1b2c3d)", "Dấu 1.0.0" without a commit, or "Dấu" without a version.
    static var nameAndVersion: String {
        guard let marketing else { return "Dấu" }
        return commit.map { "Dấu \(marketing) (\($0))" } ?? "Dấu \(marketing)"
    }
}

// MARK: - Layout probe (tests only)

/// Reports a view's frame in window coordinates. Nil in the app; the window captures
/// (`DebugCapture`) and `scripts/snapshot-settings` set it to check that the layout
/// does not move between sections.
struct LayoutProbeKey: EnvironmentKey {
    static let defaultValue: (@MainActor @Sendable (String, CGRect) -> Void)? = nil
}

extension EnvironmentValues {
    var layoutProbe: (@MainActor @Sendable (String, CGRect) -> Void)? {
        get { self[LayoutProbeKey.self] }
        set { self[LayoutProbeKey.self] = newValue }
    }
}

/// Always the same view structure, probe or not: a probe that changed the structure
/// (an `if` around the modifier) once made the off-screen captures lay out a sidebar
/// row 8 pt away from the real window. Put probes on a row's content or on a whole
/// control, never outside list-row modifiers (`listRowInsets`, `listRowBackground`).
struct LayoutProbeModifier: ViewModifier {
    @Environment(\.layoutProbe) private var probe
    let name: String

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
            probe?(name, frame)
        }
    }
}

extension View {
    func layoutProbe(_ name: String) -> some View {
        modifier(LayoutProbeModifier(name: name))
    }
}
