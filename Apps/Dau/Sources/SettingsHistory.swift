import SwiftUI

// Back/Forward of the Settings window, as System Settings has them (D9, "Vỏ cửa sổ Cài
// đặt"; docs/research/SWIFTUI-WINDOW-API.md, section 3). SwiftUI has no history for a
// `NavigationSplitView` (`NavigationStack` only goes back), so the window keeps its own:
// `SectionHistory`, shown as a Back/Forward cluster in the toolbar's navigation placement
// (`SettingsHistoryButtons`) and as View menu commands (`SettingsHistoryCommands`), since
// the HIG asks for every toolbar item to be a menu command too
// (https://developer.apple.com/design/human-interface-guidelines/toolbars).

/// The sections the Settings window has shown, browser style: choosing a section (in the
/// sidebar, or the jump of the sidebar search to its first match) pushes the shown one on
/// the back stack and clears the forward one; Back and Forward move between the two.
/// Choosing the section already shown changes nothing.
struct SectionHistory: Equatable {
    private(set) var current: SettingsSection
    /// Older sections, the most recent last.
    private(set) var back: [SettingsSection] = []
    /// Sections left by Back, the next one last.
    private(set) var forward: [SettingsSection] = []

    init(_ start: SettingsSection) {
        current = start
    }

    var canGoBack: Bool { !back.isEmpty }
    var canGoForward: Bool { !forward.isEmpty }

    /// Shows `section` as a new step: the sidebar, or the search's jump to its first match.
    mutating func select(_ section: SettingsSection) {
        guard section != current else { return }
        back.append(current)
        forward.removeAll()
        current = section
    }

    /// The sidebar search's jump: when the page shown no longer matches, show the first
    /// section that does, so the result is visible right away. It changes the page shown,
    /// so it is a step like a click: Back returns to the page shown before the search.
    /// Nothing matches: the page stays (the sidebar shows the system's empty state).
    mutating func showFirstMatch(of visible: [SettingsSection]) {
        guard let first = visible.first, !visible.contains(current) else { return }
        select(first)
    }

    mutating func goBack() {
        guard let previous = back.popLast() else { return }
        forward.append(current)
        current = previous
    }

    mutating func goForward() {
        guard let next = forward.popLast() else { return }
        back.append(current)
        current = next
    }
}

/// The Back/Forward cluster: one toolbar item at `ToolbarItemPlacement.navigation`, which
/// macOS puts "in the leading edge of the toolbar ahead of the inline title"
/// (https://developer.apple.com/documentation/swiftui/toolbaritemplacement/navigation),
/// as a `ControlGroup` in the `.navigation` style
/// (https://developer.apple.com/documentation/swiftui/controlgroup,
/// https://developer.apple.com/documentation/swiftui/controlgroupstyle/navigation). A
/// probe of this exact cluster matched System Settings' pair (two buttons, 73 × 36 at
/// x 240; docs/research/SYSTEM-SETTINGS-REFERENCE.md). Being an item, it also keeps the
/// toolbar at its full height with the system's large inline title: with no item at all
/// AppKit shrinks it to a title bar (measured on macOS 27.2).
struct SettingsHistoryButtons: View {
    @Binding var history: SectionHistory

    var body: some View {
        ControlGroup {
            // Standard symbols, no text in the toolbar (HIG, Toolbars); the label is what
            // VoiceOver and the tooltip say.
            Button {
                history.goBack()
            } label: {
                Label("Lùi", systemImage: "chevron.backward")
            }
            .help(Text("Lùi"))
            .disabled(!history.canGoBack)
            Button {
                history.goForward()
            } label: {
                Label("Tiến", systemImage: "chevron.forward")
            }
            .help(Text("Tiến"))
            .disabled(!history.canGoForward)
        } label: {
            // Names the group for VoiceOver, and in the toolbar's overflow menu.
            Text("Điều hướng")
        }
        .controlGroupStyle(.navigation)
    }
}

/// What the View menu's Back and Forward act on: the history of the Settings window
/// that has focus, published with `focusedSceneValue`
/// (https://developer.apple.com/documentation/swiftui/view/focusedscenevalue(_:_:)) and
/// read by `SettingsHistoryCommands` through `@FocusedValue`
/// (https://developer.apple.com/documentation/swiftui/focusedvalue). No Settings window
/// in focus: no value, both commands disabled.
struct SettingsNavigation {
    var canGoBack: Bool
    var canGoForward: Bool
    var goBack: @MainActor () -> Void
    var goForward: @MainActor () -> Void
}

private struct SettingsNavigationKey: FocusedValueKey {
    typealias Value = SettingsNavigation
}

extension FocusedValues {
    var settingsNavigation: SettingsNavigation? {
        get { self[SettingsNavigationKey.self] }
        set { self[SettingsNavigationKey.self] = newValue }
    }
}

/// View › Back (⌘[) and Forward (⌘]), as in System Settings, before the system's sidebar
/// group (Show/Hide Sidebar, Enter/Exit Full Screen; `CommandGroupPlacement.sidebar`,
/// https://developer.apple.com/documentation/swiftui/commandgroupplacement/sidebar). The
/// group is added to, never replaced: replacing it would drop full screen too.
struct SettingsHistoryCommands: Commands {
    @FocusedValue(\.settingsNavigation) private var navigation

    var body: some Commands {
        CommandGroup(before: .sidebar) {
            Button("Lùi") { navigation?.goBack() }
                .keyboardShortcut("[", modifiers: .command)
                .disabled(navigation?.canGoBack != true)
            Button("Tiến") { navigation?.goForward() }
                .keyboardShortcut("]", modifiers: .command)
                .disabled(navigation?.canGoForward != true)
        }
    }
}
