import SwiftUI

/// The Settings window, built like System Settings (D9: native components with their
/// default metrics; numbers in docs/research/SYSTEM-SETTINGS-REFERENCE.md): a
/// `NavigationSplitView` whose sidebar is a plain `List` with the system's sidebar
/// search field, 232 pt wide, and whose detail is a grouped `Form` per section. The
/// toolbar holds the Back/Forward cluster (`SettingsHistoryButtons`) and the system's
/// own page title (`navigationTitle`, set by `SettingsDetail`). The mockup only sets the
/// content (sections, rows, copy, order, icons).
struct SettingsWindow: View {
    @State private var history: SectionHistory
    @State private var query = ""
    /// A page's sheet is shown (`sheetShown(_:)`): the add-rule sheet.
    @State private var pageSheetShown = false
    @Environment(\.inputMethodActions) private var actions

    init(initialSection: SettingsSection = .typing) {
        _history = State(initialValue: SectionHistory(initialSection))
    }

    private var visibleSections: [SettingsSection] {
        SettingsSection.allCases.filter { $0.matches(query) }
    }

    /// Any sheet on the window: a page's, or the uninstall sheet.
    private var sheetShown: Bool { pageSheetShown || actions?.isShowingUninstallSheet == true }

    var body: some View {
        NavigationSplitView {
            // Choosing a row is a step in the history; the list never clears the page
            // shown (a nil selection is ignored).
            List(visibleSections, selection: Binding(get: { history.current },
                                                     set: { if let section = $0 { history.select(section) } })) { section in
                Label {
                    Text(section.title)
                } icon: {
                    SectionIcon(section: section)
                }
                .tag(section)
            }
            .overlay {
                // No section matches: the system's search empty state in the sidebar.
                // The detail keeps the open page and its title.
                if visibleSections.isEmpty {
                    ContentUnavailableView.search(text: query.trimmingCharacters(in: .whitespaces))
                }
            }
            .searchable(text: $query, placement: .sidebar, prompt: Text("Tìm kiếm"))
            .onChange(of: query) {
                // Jump to the first match (a step in the history, `showFirstMatch`).
                history.showFirstMatch(of: visibleSections)
            }
            .safeAreaInset(edge: .bottom, alignment: .leading) {
                // Mockup content: the app name and version under the sections.
                Text(verbatim: AppVersion.nameAndVersion)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
            }
            // System Settings has no sidebar toggle: Back/Forward sit at the toolbar's
            // leading edge instead (`toolbar(removing:)`,
            // https://developer.apple.com/documentation/swiftui/view/toolbar(removing:)).
            // The sidebar can still be collapsed by dragging the divider (SwiftUI has no
            // API to prevent it, D9); View › Show Sidebar (⌃⌘S, `SidebarCommands` in
            // `DauApp`) always brings it back, as the HIG asks
            // (https://developer.apple.com/design/human-interface-guidelines/split-views).
            .toolbar(removing: .sidebarToggle)
            // A fixed, preferred width (https://developer.apple.com/documentation/swiftui/view/navigationsplitviewcolumnwidth(_:)).
            // Must stay the last modifier of the column to take effect.
            .navigationSplitViewColumnWidth(SettingsScene.sidebarWidth)
        } detail: {
            SettingsDetail(section: history.current)
        }
        // On the split view itself, not on the page: a page change swaps the page's view
        // tree, and a toolbar item declared there is rebuilt with it, so AXPress on Back
        // changed the page but returned kAXErrorAttributeUnsupported (-25205) to the
        // caller (measured on macOS 27.2: probe in build/probe-shell, page swapped,
        // item on the page -25205, item on the split view 0; System Settings returns 0).
        .toolbar {
            ToolbarItem(placement: .navigation) {
                SettingsHistoryButtons(history: $history, sheetShown: sheetShown)
            }
        }
        // View › Back / Forward act on this window's history while it has focus.
        .focusedSceneValue(\.settingsNavigation, SettingsNavigation(
            canGoBack: history.canGoBack(sheetShown: sheetShown),
            canGoForward: history.canGoForward(sheetShown: sheetShown),
            goBack: { history.goBack() }, goForward: { history.goForward() }))
        .onPreferenceChange(SheetShownKey.self) { pageSheetShown = $0 }
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

/// One section page. Its title is the system's navigation title: on macOS the inline
/// title of the unified toolbar, right after the Back/Forward cluster, and the window's
/// title in the Window menu, Mission Control and VoiceOver
/// (https://developer.apple.com/documentation/swiftui/view/navigationtitle(_:)); the HIG
/// asks a settings window to title itself after the visible pane
/// (https://developer.apple.com/design/human-interface-guidelines/settings).
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
