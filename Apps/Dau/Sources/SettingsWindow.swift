import SwiftUI

/// The Settings window, built like System Settings (D9: native components with their
/// default metrics; numbers in docs/research/SYSTEM-SETTINGS-REFERENCE.md): a
/// `NavigationSplitView` whose sidebar is a plain `List` with the system's sidebar
/// search field, 232 pt wide, and whose detail is a grouped `Form` per section. The
/// mockup only sets the content (sections, rows, copy, order, icons).
struct SettingsWindow: View {
    @State private var selection: SettingsSection?
    @State private var query = ""
    @Environment(\.inputMethodActions) private var actions

    init(initialSection: SettingsSection = .typing) {
        _selection = State(initialValue: initialSection)
    }

    private var visibleSections: [SettingsSection] {
        SettingsSection.allCases.filter { $0.matches(query) }
    }

    var body: some View {
        NavigationSplitView {
            List(visibleSections, selection: $selection) { section in
                Label {
                    Text(section.title)
                } icon: {
                    SectionIcon(section: section)
                }
                .tag(section)
            }
            .overlay {
                // No section matches: the system's search empty state in the sidebar.
                // The detail keeps the open page, so its toolbar title stays (a
                // detail without a page title would shrink the toolbar, see
                // `PageTitle`).
                if visibleSections.isEmpty {
                    ContentUnavailableView.search(text: query.trimmingCharacters(in: .whitespaces))
                }
            }
            .searchable(text: $query, placement: .sidebar, prompt: Text("Tìm kiếm"))
            .onChange(of: query) {
                // Jump to the first match so the result is visible right away.
                if let first = visibleSections.first, selection.map(visibleSections.contains) != true {
                    selection = first
                }
            }
            .safeAreaInset(edge: .bottom, alignment: .leading) {
                // Mockup content: the app name and version under the sections.
                Text(verbatim: AppVersion.nameAndVersion)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
            }
            // System Settings has no sidebar toggle (Back/Forward sit there instead),
            // so the window has none either. Removing it makes the system title
            // shrink: the toolbar collapses to a 32 pt title bar with the small window
            // title (measured on macOS 27.2, 1x display). Hence `PageTitle`,
            // `HiddenWindowTitle` and `RemoveToolbarTitle` below.
            .toolbar(removing: .sidebarToggle)
            // Must stay the last modifier of the column to take effect.
            .navigationSplitViewColumnWidth(SettingsScene.sidebarWidth)
        } detail: {
            SettingsDetail(section: selection ?? .typing)
        }
        // Without the sidebar toggle the toolbar holds no item on most pages, and
        // AppKit then shrinks it to a 32 pt title bar with the small window title
        // (measured on macOS 27.2, 1x display). Each page puts its title as a
        // leading toolbar item instead (`PageTitle`), so the toolbar keeps System
        // Settings' 52 pt and 15 pt bold title on every page; the window's own title
        // text is hidden.
        .background(HiddenWindowTitle())
        // "Gỡ cài đặt…": the sheet that waits for the user to remove Dấu from the input
        // sources (`InputMethodActions.performUninstall`); closing it cancels the removal.
        .sheet(isPresented: Binding(get: { actions?.isShowingUninstallSheet == true },
                                    set: { if !$0 { actions?.cancelUninstall() } })) {
            if let actions {
                UninstallRemoveSheet(actions: actions)
            }
        }
        // System Settings opens at 740 × 560. A grouped Form caps its cards at 704 pt
        // and centers them once the detail column is wider than 744 pt (measured), so
        // the window never gets wider than the sidebar plus 744: the cards always
        // span the column with the Form's own 20 pt margins.
        .frame(minWidth: SettingsScene.minSize.width, maxWidth: SettingsScene.maxWidth,
               minHeight: SettingsScene.minSize.height, maxHeight: .infinity)
    }
}

/// One section page; its title also names the window (Window menu, VoiceOver).
struct SettingsDetail: View {
    let section: SettingsSection

    var body: some View {
        Group {
            switch section {
            case .typing: TypingSettingsView()
            case .smart: SmartSettingsView()
            case .apps: AppRulesView()
            case .updates: UpdatesSupportView()
            }
        }
        .navigationTitle(section.title)
        .modifier(RemoveToolbarTitle())
    }
}

/// The page title is a toolbar item already (`PageTitle`); remove the system title so
/// it is not drawn twice. The navigation title still names the window (Window menu,
/// Mission Control, VoiceOver). Why not the system title: without the sidebar toggle
/// (removed as System Settings has none) it shrinks to the small window title in a
/// 32 pt title bar (measured on macOS 27.2, 1x display).
struct RemoveToolbarTitle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 15, *) {
            content.toolbar(removing: .title)
        } else {
            content
        }
    }
}

enum SettingsScene {
    static let id = "settings"
    /// System Settings' window (docs/research/SYSTEM-SETTINGS-REFERENCE.md).
    static let defaultSize = CGSize(width: 740, height: 560)
    /// System Settings' sidebar column.
    static let sidebarWidth: CGFloat = 232
    /// A grouped Form keeps its cards at most 704 pt wide and centers them once the
    /// detail column is wider than 744 pt (measured on macOS 27.2): the window stops
    /// there, so the cards always span the column.
    static let maxWidth: CGFloat = sidebarWidth + 744
    /// The content's minimum: System Settings' width (narrower would wrap or squeeze
    /// the rows with a label and a segmented control) and 400 pt under the 52 pt
    /// toolbar, so the window is at least 740 × 452.
    static let minSize = CGSize(width: 740, height: 400)
}
