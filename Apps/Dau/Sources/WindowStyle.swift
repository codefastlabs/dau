import AppKit
import SwiftUI

/// Hides the window's own title text: each page shows its title in its header, at
/// the same place in every section. The title stays set, so the Window menu, Mission
/// Control and VoiceOver still read it.
///
/// Why: the window removes the sidebar toggle, as System Settings has none, and
/// without it the system title shrinks to the small window title in a 32 pt title bar
/// (measured on macOS 27.2, 1x display). The page title is drawn by `PageTitle`
/// instead, so the system's own title text must not show as well.
struct HiddenWindowTitle: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { TitleHidingView() }
    func updateNSView(_ view: NSView, context: Context) {
        (view as? TitleHidingView)?.apply()
    }

    final class TitleHidingView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            apply()
        }

        func apply() {
            window?.titleVisibility = .hidden
        }
    }
}

