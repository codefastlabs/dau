import AppKit
import SwiftUI
import Testing
import DauShared
@testable import SnapshotSettings

/// The Settings window's split view (D9, "Sidebar cố định như System Settings"): built
/// off screen, never shown. What the window does with it (drag, double-click, cursor,
/// View menu) is measured on the real window (scripts/selftest/settings-window).
@MainActor
@Suite("Settings window shell")
struct SettingsShellTests {
    func controller() -> SettingsSplitViewController {
        let suite = "dau.snapshot-settings.tests.shell"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.removePersistentDomain(forName: suite)
        let model = SettingsModel(store: SettingsStore(defaults: defaults, suiteName: suite))
        let environment = SettingsEnvironment(model: model, inputSource: InputSourceStatus(fixed: true), actions: nil,
                                              layoutProbe: nil, smartAdvancedExpanded: false, openWindow: nil)
        let state = SettingsWindowState(.typing)
        return SettingsSplitViewController(sidebar: SettingsSidebarRoot(state: state, environment: environment),
                                           detail: SettingsDetailRoot(state: state, environment: environment))
    }

    @Test("a system sidebar, 232 pt, that neither collapses nor resizes")
    func fixedSidebar() {
        let items = controller().splitViewItems
        #expect(items.count == 2)
        guard let sidebar = items.first else { return }
        #expect(sidebar.behavior == .sidebar)
        #expect(!sidebar.canCollapse)
        #expect(!sidebar.canCollapseFromWindowResize)
        #expect(sidebar.minimumThickness == SettingsScene.sidebarWidth)
        #expect(sidebar.maximumThickness == SettingsScene.sidebarWidth)
    }

    @Test("the sidebar's divider has no mouse area (normal arrow, no drag)")
    func divider() {
        let controller = controller()
        let drawn = NSRect(x: SettingsScene.sidebarWidth - 1, y: 0, width: 1, height: 500)
        let rect = controller.splitView(controller.splitView, effectiveRect: drawn.insetBy(dx: -3, dy: 0),
                                        forDrawnRect: drawn, ofDividerAt: 0)
        #expect(rect == .zero)
    }

    @Test("AppKit's Show/Hide Sidebar action stays off")
    func toggleSidebarDisabled() {
        let item = NSMenuItem(title: "Hide Sidebar", action: #selector(NSSplitViewController.toggleSidebar(_:)),
                              keyEquivalent: "s")
        #expect(!controller().validateUserInterfaceItem(item))
    }

    @Test("the page host brings the toolbar and the title; the sidebar host nothing")
    func bridging() {
        let items = controller().splitViewItems
        let sidebar = items.first?.viewController as? NSHostingController<SettingsSidebarRoot>
        let detail = items.last?.viewController as? NSHostingController<SettingsDetailRoot>
        #expect(sidebar?.sceneBridgingOptions == [])
        #expect(detail?.sceneBridgingOptions == [.toolbars, .title])
    }
}
