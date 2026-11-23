import AppKit
import SwiftUI
import DauShared

/// "Report a Typing Problem" (artboard Report), from "Report a Problem…" on "Updates & Support".
///
/// Content from the artboard: the title and the line saying the user reviews the report
/// and that GitHub issues are public; the hint for an app that cannot select Dấu (log
/// out once, D37; macOS's own menu name, D38); the fields "App", "Website", "Problem",
/// "What you typed"; "Included" with exactly what goes along; "Cancel" / "Open on GitHub".
/// "Open on GitHub" opens the prefilled issue in the browser, where the user reads it
/// again and sends it: Dấu itself sends nothing (D8, N2; `ProblemReport`).
///
/// Built like the add-rule sheet (D9): a header, the content as cards of a grouped
/// `Form` with the system's rows and controls, and the sheet's own button bar from the
/// toolbar's cancellation and confirmation placements.
struct ReportSheet: View {
    @Environment(SettingsModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var choices: [ReportedApp] = []
    @State private var appID: String?
    @State private var website = ""
    @State private var kind: ProblemReport.Kind = .missingText
    @State private var example = ""

    /// System Settings' grouped-Form sheet width, as the add-rule sheet.
    static let width: CGFloat = AddAppRuleSheet.width
    static let margin: CGFloat = AddAppRuleSheet.margin

    /// macOS's own names (D38), in the system's language.
    private var ui: SystemUINames { SystemUINames.system() }

    private var chosen: ReportedApp? { choices.first { $0.bundleID == appID } }

    private var report: ProblemReport {
        ProblemReport(
            app: chosen?.name ?? "",
            website: website,
            kind: kind,
            example: example,
            macOS: ProblemReport.macOSName(),
            dauVersion: AppVersion.reportVersion,
            typingMethod: model.settings.typingMethod.title,
            underline: ProblemReport.underlineName(model.settings, bundleID: chosen?.bundleID),
            appVersion: chosen?.version)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Report a Typing Problem")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Subtitle(Text("You review the report before it’s sent. Reports on GitHub are public."))
            }
            .padding([.horizontal, .top], Self.margin)
            Form {
                Section {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Can’t select Dấu in an app?")
                                .fontWeight(.semibold)
                            Subtitle(Self.logOutHint(logOut: ui.logOut))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .accessibilityElement(children: .combine)
                }
                Section {
                    Picker("App", selection: $appID) {
                        ForEach(choices) { app in
                            Text(verbatim: app.name).tag(Optional(app.bundleID))
                        }
                    }
                    TextField("Website", text: $website, prompt: Text("Optional"))
                    Picker("Problem", selection: $kind) {
                        ForEach(ProblemReport.Kind.allCases) { kind in
                            Text(verbatim: kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    .modifier(FlexibleSegments())
                    TextField("What you typed", text: $example)
                } footer: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Included")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Subtitle(Text("\(report.includedLine). Only what’s shown here is sent."))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    // Capture check (h): the footer lies inside the sheet (not cut).
                    .layoutProbe("reportIncluded")
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: Self.width)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Open on GitHub", action: open)
                    .keyboardShortcut(.defaultAction)
                    .disabled(chosen == nil)
            }
        }
        .onAppear(perform: loadApps)
    }

    /// The hint's second line. The Apple menu symbol is the SF Symbol `applelogo`, as in
    /// onboarding (`EnableStep.logOutHint`).
    static func logOutHint(logOut: String) -> Text {
        Text("That app may still keep an old list of input sources. Log out (\(Image(systemName: "applelogo")) › \(logOut)) and log back in once, then try again; quitting and reopening the app isn’t enough. If it still happens, send a report below.")
    }

    /// The running apps, the one used right before Dấu chosen (`PreviousAppTracker`).
    private func loadApps() {
        #if DEBUG
        if DebugCapture.reportDirectory != nil {
            // `--capture-report`: the artboard's sample, never the user's running apps.
            let sample = DebugCapture.reportSample
            choices = [sample.app]
            appID = sample.app.bundleID
            website = sample.website
            example = sample.example
            return
        }
        #endif
        let own = Bundle.main.bundleIdentifier
        let running = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { ReportedApp($0) }
        let previous = PreviousAppTracker.shared.previous
        choices = ReportedApp.choices(running: running, previous: previous, own: own)
        appID = previous?.bundleID ?? choices.first?.bundleID
    }

    private func open() {
        NSWorkspace.shared.open(report.issueURL())
        dismiss()
    }
}
