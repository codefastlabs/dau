import AppKit
import SwiftUI

/// "Cập nhật & hỗ trợ" (artboards "SettingsAbout", "SettingsAboutDev").
///
/// - The version card. On the official build (an updater exists, `UpdatesModel`, D7) it
///   has the last check and "Kiểm tra bản mới…", then the rows "Tự động kiểm tra bản mới"
///   and "Kênh phát hành"; Sparkle's own windows show what a check finds, the download and
///   the install (D7). A development build has none of these; its card shows the
///   installed input method's build (D25, D37).
/// - "Hỗ trợ": "Báo lỗi…" (`ReportSheet`, D8) and "Gỡ cài đặt…" (D16,
///   `InputMethodActions.confirmUninstall`), then the privacy note.
struct UpdatesSupportView: View {
    @Environment(\.inputMethodActions) private var actions
    @Environment(\.updates) private var updates
    /// The installed input method's build (development builds only): read off the main
    /// thread when the page appears and after each check of the installed copy
    /// (`InputMethodActions.installedChecks`: the launch reconcile, "Cài lại", app
    /// activation), not on every body evaluation. Nothing is shown before the first read
    /// ends (N5: "not installed" only once that was read).
    @State private var installed: InstalledRead = .unread
    enum InstalledRead: Equatable { case unread, notInstalled, build(String) }
    /// "Báo lỗi…" shows the sheet; the Debug capture `--capture-report` opens it at once.
    @State private var isReporting = Self.reportAtStart

    private static var reportAtStart: Bool {
        #if DEBUG
        DebugCapture.reportDirectory != nil
        #else
        false
        #endif
    }

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
                        if let updates {
                            Subtitle(Text(verbatim: UpdatesModel.lastCheckLine(updates.lastCheck)))
                        }
                        // D25: no line naming the kind of build; the icon and the commit
                        // in the version line tell it. A development build shows what the
                        // installed input method is.
                        if AppVersion.isDevelopmentBuild {
                            switch installed {
                            case .unread: EmptyView()
                            case .notInstalled: Subtitle(Text("Input method not installed"))
                            case .build(let build): Subtitle(Text("Installed input method: \(build)"))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    if let updates {
                        // Sparkle allows one check at a time; the button is off meanwhile.
                        Button("Check for Updates…") { updates.checkForUpdates() }
                            .disabled(!updates.canCheck)
                    }
                }
                .layoutProbe("firstRow")
                if let updates {
                    @Bindable var updates = updates
                    Toggle(isOn: $updates.automaticChecks) {
                        Text("Automatically check for updates")
                        // D7: when Dấu opens, at most once a day (SUScheduledCheckInterval);
                        // never installs without asking (SUAllowsAutomaticUpdates false).
                        Text("When you open Dấu, at most once a day. Dấu asks you before installing.")
                    }
                    ReleaseChannelRow(updates: updates)
                }
            }

            Section {
                LabeledContent {
                    Button("Report a Problem…") { isReporting = true }
                } label: {
                    Text("Wrong text in an app")
                    Text("Or a word Dấu typed came out wrong. You review the report before it’s sent.")
                }
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
        .sheet(isPresented: $isReporting) {
            ReportSheet()
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

/// "Kênh phát hành" (D7, "Kênh"; artboard SettingsAbout, both values of its `stage`): the
/// system segmented control Beta / Stable at the right of the row, like "Tone mark
/// placement". Until the appcast has a stable release, Stable is shown but off and the
/// description says there is none yet. The row appears once an appcast has loaded: before
/// that Dấu cannot tell which of the two is true (N5). With automatic checks on, Sparkle
/// checks at the first launch (no last check date yet, SPUUpdater.m 2.10.1).
struct ReleaseChannelRow: View {
    let updates: UpdatesModel

    var body: some View {
        let channels = updates.channels
        if let stableExists = channels.stableReleaseExists, let channel = channels.channel {
            LabeledContent {
                // `SegmentedPicker`: SwiftUI's `Picker` cannot turn the Stable segment off.
                SegmentedPicker(String(localized: "Release channel"),
                                selection: Binding(get: { channel }, set: { updates.chooseChannel($0) }),
                                options: [(.beta, String(localized: "Beta")), (.stable, String(localized: "Stable"))],
                                disabled: channels.canChoose(.stable) ? [] : [.stable],
                                fillsWidth: false, controlSize: .regular)
            } label: {
                Text("Release channel")
                if stableExists {
                    Text("Beta: the latest builds, for trying out and giving feedback. Stable: finished releases only. If you switch to Stable, Dấu keeps the version you have until a newer stable release comes out.")
                } else {
                    Text("Beta: the latest builds, for trying out and giving feedback. There is no stable release yet; once there is, you can choose the Stable channel.")
                }
            }
            .layoutProbe("releaseChannel")
        }
    }
}
