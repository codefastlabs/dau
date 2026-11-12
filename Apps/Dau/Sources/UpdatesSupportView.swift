import AppKit
import SwiftUI

/// "Cập nhật & hỗ trợ" (mockup "SettingsAbout"): the version card and "Gỡ cài đặt…"
/// (D16, `InputMethodActions.confirmUninstall`). No network access.
struct UpdatesSupportView: View {
    @Environment(\.inputMethodActions) private var actions
    /// The installed input method's build (development builds only): read off the main
    /// thread when the page appears and after each check of the installed copy
    /// (`InputMethodActions.installedChecks`: the launch reconcile, "Cài lại", app
    /// activation), not on every body evaluation. Nothing is shown before the first read
    /// ends (N5: "not installed" only once that was read).
    @State private var installed: InstalledRead = .unread
    enum InstalledRead: Equatable { case unread, notInstalled, build(String) }

    var body: some View {
        SettingsPage {
            Section {
                HStack(spacing: 12) {
                    // System Settings' pane header card (Notifications, Siri: icon,
                    // title, description) shows its icon 26 pt; Dấu's app icon fills
                    // about 80% of its frame, so 32 draws it at that size.
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: AppIcon.twoLine, height: AppIcon.twoLine)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: AppVersion.nameAndVersion)
                            .font(.headline)
                        // D25: a development build says so (Debug is in the version line).
                        if AppVersion.isDevelopmentBuild {
                            Subtitle(Text("Development build"))
                            switch installed {
                            case .unread: EmptyView()
                            case .notInstalled: Subtitle(Text("Input method not installed"))
                            case .build(let build): Subtitle(Text("Installed input method: \(build)"))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                }
                .layoutProbe("firstRow")
            }

            Section {
                LabeledContent("Remove Dấu from this Mac") {
                    // The system's destructive button, enabled and disabled look
                    // included (D9). macOS 27.2 draws it as a plain push button, text
                    // not red (measured 02/11/2026); docs/UI.md follows the system.
                    Button("Uninstall…", role: .destructive) {
                        actions?.confirmUninstall(in: NSApp.keyWindow)
                    }
                    .disabled(actions == nil || actions?.isUninstalling == true)
                }
            } header: {
                Text("Support")
            } footer: {
                // Wording fixed by docs/UI.md (D8, N2). The page's closing note, after
                // the last card (a footer, not a section description).
                Subtitle(Text("Dấu never sends what you type off your Mac. The input method has no network access; only the updater connects, to download new versions. Open source under the GPLv3 license."))
            }
        }
        .task(id: actions?.installedChecks) {
            guard AppVersion.isDevelopmentBuild else { return }
            let url = InputMethodBundleFiles.standard().installedURL
            let build = await Task.detached { AppVersion.installedInputMethodBuild(at: url) }.value
            // A newer check replaced this task: its read wins, never this older one.
            guard !Task.isCancelled else { return }
            installed = build.map(InstalledRead.build) ?? .notInstalled
        }
    }
}
