import SwiftUI
import Testing
import DauShared
@testable import Dau

// SwiftUI may read a binding on NSHostingView's asynchronous rendering thread. A
// `Binding(get:set:)` made of closures in a main-actor view body traps there under Swift 6
// (the executor check). The
// Settings window's bindings are key-path bindings through `@Bindable`; these tests read
// each one off the main thread, as that rendering does (a window that is never shown only
// renders on the main thread). `ReleaseChannelRowTests.bindingOffMain` covers the channel.

/// `binding`'s value read on a new thread.
func readOffMain<Value: Sendable>(_ binding: Binding<Value>) async -> Value {
    let box = UncheckedBox(binding)
    return await withCheckedContinuation { continuation in
        Thread.detachNewThread { continuation.resume(returning: box.value.wrappedValue) }
    }
}

@MainActor
@Suite("Settings window bindings off the main thread")
struct SettingsBindingTests {
    @Test("the sidebar selection: read off the main thread; nil never clears the page")
    func sidebarSelection() async {
        let state = SettingsWindowState(.apps)
        let binding = SettingsSidebar.selection(state)
        #expect(await readOffMain(binding) == .apps)
        binding.wrappedValue = .updates
        #expect(state.section == .updates)
        binding.wrappedValue = nil
        #expect(state.section == .updates)
    }

    @Test("the uninstall sheet's isPresented: read off the main thread, follows the sheet state")
    func uninstallSheet() async {
        let actions = InputMethodActions(installer: FakeInputMethodInstaller(.installed(version: nil)),
                                         openKeyboardSettings: {}, openInputSources: {},
                                         shortcut: { .unknown }, englishLayout: { nil })
        let binding = SettingsWindow.uninstallSheetPresented(actions)
        #expect(await readOffMain(binding) == false)
        actions.showUninstallSheetForCapture(true, dauIsSelected: false)
        #expect(await readOffMain(binding) == true)
        #expect(await readOffMain(SettingsWindow.uninstallSheetPresented(nil)) == false)
    }
}
