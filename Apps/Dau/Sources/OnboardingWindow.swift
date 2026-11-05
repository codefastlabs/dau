import AppKit
import Carbon
import SwiftUI
import DauShared

// The onboarding window (D14, docs/UI.md "Onboarding", mockup artboards
// "OnboardingConflict", "OnboardingEnable", "Onboarding"): a 230 pt sidebar with the app
// icon, the name and the three steps, and the current step on the right. 720 × 500 pt,
// no title text. System controls and colors only (D9).

@MainActor
enum OnboardingScene {
    nonisolated static let id = "onboarding"
    /// The window, title bar included (mockup).
    static let size = CGSize(width: 720, height: 500)
    /// The hidden title bar still counts as top safe area, and SwiftUI adds it to the
    /// window's size: the content is laid out below it (32 pt on macOS 27, 28 before).
    static let titleBarHeight: CGFloat = {
        let content = NSRect(x: 0, y: 0, width: 100, height: 100)
        return NSWindow.frameRect(forContentRect: content, styleMask: [.titled, .closable]).height - content.height
    }()

    /// Distance from the window's top edge, turned into one from the safe area's.
    static func belowTitleBar(_ top: CGFloat) -> CGFloat { max(0, top - titleBarHeight) }
}

struct OnboardingWindow: View {
    @Environment(OnboardingFlow.self) private var flow
    @Environment(\.controlActiveState) private var activeState

    var body: some View {
        // A plain split, not NavigationSplitView: the steps are not a selectable list,
        // and the mockup's sidebar runs the full height under the traffic lights.
        HStack(spacing: 0) {
            // 229 + the 1 pt divider: the content starts at 230, as in the mockup.
            OnboardingSidebar()
                .frame(width: 229)
                .frame(maxHeight: .infinity)
                .background { SidebarMaterial().ignoresSafeArea() }
                .layoutProbe("onbSidebar")
            Divider().ignoresSafeArea()
            OnboardingStepView()
        }
        .frame(width: OnboardingScene.size.width,
               height: OnboardingScene.size.height - OnboardingScene.titleBarHeight)
        .background(HiddenWindowTitle())
        .onAppear { flow.start() }
        // Step 1 is rechecked whenever the user comes back to the window.
        .onChange(of: activeState) { _, state in
            if state == .key { flow.refresh() }
        }
        .onReceive(DistributedNotificationCenter.default().publisher(
            for: Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String))) { _ in
            flow.refresh()
        }
        .onReceive(DistributedNotificationCenter.default().publisher(
            for: Notification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String))) { _ in
            flow.refresh()
        }
    }
}

// MARK: - Sidebar

struct OnboardingSidebar: View {
    @Environment(OnboardingFlow.self) private var flow

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)
                Text(verbatim: "Dấu")
                    .font(.system(size: 17, weight: .bold))
            }
            .layoutProbe("onbAppName")

            VStack(alignment: .leading, spacing: 18) {
                ForEach(OnboardingFlow.Step.allCases, id: \.self) { step in
                    StepRow(step: step, state: flow.state(of: step))
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text("Các bước thiết lập"))
            .layoutProbe("onbSteps")

            Spacer(minLength: 0)

            Hint(Text("Dấu không cần quyền Trợ năng. macOS chỉ hỏi một lần khi bật."))
        }
        // Mockup: 16 pt inset, the 12 pt traffic lights, then 22 pt to the app name.
        .padding(.top, OnboardingScene.belowTitleBar(50))
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// The system's sidebar material (behind-window vibrancy), as in a sidebar.
struct SidebarMaterial: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        view.blendingMode = .behindWindow
        view.state = .followsWindowActiveState
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}

/// One step in the sidebar: a 24 pt circle (check when done, number otherwise), the
/// step's name (semibold when current) and a hint.
struct StepRow: View {
    let step: OnboardingFlow.Step
    let state: OnboardingFlow.StepState

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            StepBadge(number: step.rawValue, state: state)
            VStack(alignment: .leading, spacing: 1) {
                Text(step.sidebarTitle)
                    .font(.system(size: 13, weight: state == .current ? .semibold : .regular))
                    .foregroundStyle(.primary)
                Hint(step.sidebarHint)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Bước \(step.rawValue): \(Text(step.sidebarTitle))"))
        .accessibilityValue(state.spoken)
        .accessibilityAddTraits(state == .current ? [.isStaticText, .isSelected] : .isStaticText)
    }
}

struct StepBadge: View {
    let number: Int
    let state: OnboardingFlow.StepState

    var body: some View {
        ZStack {
            switch state {
            case .done:
                Circle().fill(Color.green)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            case .current:
                Circle().fill(Color.accentColor)
                Text(verbatim: "\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            case .pending:
                Circle().fill(.fill)
                Text(verbatim: "\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 24, height: 24)
        .accessibilityHidden(true)
    }
}

extension OnboardingFlow.Step {
    var sidebarTitle: LocalizedStringResource {
        switch self {
        case .oldInputMethods: "Kiểm tra bộ gõ cũ"
        case .enable: "Bật Dấu"
        case .typing: "Chọn kiểu gõ"
        }
    }

    var sidebarHint: Text {
        switch self {
        case .oldInputMethods: Text("Để dấu không bị gõ hai lần")
        case .enable: Text("Thêm vào nguồn đầu vào")
        case .typing: Text("Gõ thử ngay")
        }
    }
}

extension OnboardingFlow.StepState {
    var spoken: Text {
        switch self {
        case .done: Text("Đã xong")
        case .current: Text("Đang làm")
        case .pending: Text("Chưa làm")
        }
    }
}

// MARK: - Steps

struct OnboardingStepView: View {
    @Environment(OnboardingFlow.self) private var flow

    var body: some View {
        Group {
            switch flow.step {
            case .oldInputMethods: ConflictStep()
            case .enable: EnableStep()
            case .typing: TypingStep()
            }
        }
        // No side margin here: `StepLayout` puts it inside the scroll area, so the scroll
        // bar sits at the window's edge as in System Settings (D9; artboard
        // OnboardingEnableNotes, canvas version 104).
        .padding(.top, OnboardingScene.belowTitleBar(40))
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background { SettingsColors.page.ignoresSafeArea() }
        .layoutProbe("onbDetail")
    }
}

/// Title (22 bold), subtitle (13 secondary), content, then the buttons at the bottom
/// right, as in the artboards. The title, subtitle and content scroll when they are taller
/// than the window (a long note, a large text size) while the buttons stay in place under a
/// separator, so nothing can run out of the window or under the buttons.
struct StepLayout<Content: View, Buttons: View>: View {
    /// Names the layout probes (captures): a step leaving the window can still report.
    let step: OnboardingFlow.Step
    /// Step 2 swaps whole screens: each names its probes apart (`onbTitle-2.waiting`),
    /// so a screen that disappears does not clear the frames of the one that replaced it.
    var screen: String = ""
    let title: Text
    let subtitle: Text
    @ViewBuilder var content: Content
    @ViewBuilder var buttons: Buttons

    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        title
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.primary)
                            .accessibilityAddTraits(.isHeader)
                            .layoutProbe("onbTitle-\(step.rawValue)\(screen)")
                        // Mockup line height 1.5: 19.5 pt per line.
                        subtitle
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineSpacing(3.5)
                            .padding(.vertical, 1.75)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    content
                }
                // The side margin is inside the scroll area: the area reaches the window's
                // edge and so does its scroll bar (System Settings, D9).
                .padding(.horizontal, Self.sideMargin)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
            }
            .scrollBounceBehavior(.basedOnSize)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { viewportHeight = $0 }
            // The separator shows only when something is scrolled out of sight; it runs the
            // full width, edge to edge, as in the artboard.
            if contentHeight > viewportHeight + 0.5 {
                Divider()
                    .layoutProbe("onbDivider-\(step.rawValue)\(screen)")
                    .padding(.top, 8)
            }
            HStack(spacing: 10) {
                Spacer(minLength: 0)
                buttons
            }
            .settingsButton()
            .layoutProbe("onbButtons-\(step.rawValue)\(screen)")
            .padding(.horizontal, Self.sideMargin)
            .padding(.top, 18)
        }
    }

    /// The detail pane's side margin (artboards: 36).
    static var sideMargin: CGFloat { 36 }
}

/// A card as on the Settings pages, with 16 pt padding and 12 pt between items.
struct OnboardingCard<Content: View>: View {
    var spacing: CGFloat = 12
    @ViewBuilder var content: Content

    var body: some View {
        SettingsCard(padding: 16) {
            VStack(alignment: .leading, spacing: spacing) { content }
        }
    }
}

// MARK: Step 1

struct ConflictStep: View {
    @Environment(OnboardingFlow.self) private var flow

    var body: some View {
        let names = flow.conflicts.map(\.name).formatted(.list(type: .and))
        StepLayout(step: .oldInputMethods, title: Text("Tắt bộ gõ đang chạy"),
                   subtitle: Text("\(names) đang chạy. Khi hai bộ gõ cùng chạy, dấu bị thêm hai lần và chữ gõ ra bị sai.")) {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(flow.conflicts) { app in
                    ConflictCard(app: app)
                        .layoutProbe(app == flow.conflicts.first ? "onbCard-1" : "onbCard-1-more")
                }
                Hint(Text("Dấu tự kiểm tra lại khi bạn quay về cửa sổ này."))
            }
        } buttons: {
            Button("Bỏ qua") { flow.skip() }
                .accessibilityHint(Text("Tiếp tục khi bộ gõ cũ vẫn đang chạy"))
            Button("Kiểm tra lại") { flow.recheck() }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
    }
}

struct ConflictCard: View {
    let app: DetectedInputMethod

    var body: some View {
        OnboardingCard {
            HStack(spacing: 12) {
                OtherAppIcon(bundleID: app.bundleID, name: app.name)
                Text(verbatim: app.name)
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                if app.isRunning {
                    RunningChip()
                }
            }
            .accessibilityElement(children: .combine)
            // Mockup line height 1.7: about 22 pt per line.
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(app.quitSteps.enumerated()), id: \.offset) { index, line in
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(verbatim: "\(index + 1).")
                            .monospacedDigit()
                        Text(verbatim: line)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(.system(size: 13))
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(.vertical, 3)
            .padding(.leading, 4)
        }
    }
}

/// "Đang chạy": a capsule on the system orange tint.
struct RunningChip: View {
    var body: some View {
        Text("Đang chạy")
            .font(.system(size: 12))
            .foregroundStyle(.primary)
            .padding(.horizontal, 9)
            .frame(height: 22)
            .background(Color.orange.quaternary, in: Capsule())
    }
}

/// Another app's icon (32 pt) from Launch Services, or its initial on a system fill.
struct OtherAppIcon: View {
    let bundleID: String
    let name: String

    var body: some View {
        Group {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
            } else {
                Text(verbatim: String(name.prefix(1)))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.fill, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .frame(width: 32, height: 32)
        .accessibilityHidden(true)
    }
}

// MARK: Step 2

/// Step 2 has five screens (docs/UI.md "Onboarding"), one `StepLayout` each: before
/// "Bật Dấu" (`OnboardingEnable`, `OnboardingEnableNotes`), waiting for the user to click
/// Allow (`OnboardingEnableWaiting`), done (`OnboardingEnableDone`,
/// `OnboardingEnableDoneNoShortcut`), "Chưa bật được" (`OnboardingEnableFailed`) and an
/// install error (`OnboardingEnableError`). The first card of each is the `onbCard-2`
/// probe.
struct EnableStep: View {
    @Environment(OnboardingFlow.self) private var flow
    /// macOS's own names (D38), in the system's language.
    private var ui: SystemUINames { SystemUINames.system() }

    var body: some View {
        switch flow.enableScreen {
        case .ready: ready
        case .waiting: waiting
        case .done: done
        case .notEnabled: notEnabled
        case .error: installError
        }
    }

    private var addedSubtitle: Text {
        Text("Dấu sẽ được thêm vào nguồn đầu vào của macOS, cạnh bàn phím bạn đang dùng.")
    }

    // Before the click.
    private var ready: some View {
        StepLayout(step: .enable, screen: ".ready", title: Text("Bật Dấu"), subtitle: addedSubtitle) {
            OnboardingCard {
                Text("Sau khi bật, bạn sẽ thấy")
                    .font(.system(size: 13, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: 12) {
                    InputModeBadge()
                        .fill(.primary, style: FillStyle(eoFill: true))
                        .frame(width: 22, height: 16)
                        .accessibilityHidden(true)
                    Text("Biểu tượng V trên thanh menu khi đang gõ tiếng Việt")
                        .font(.system(size: 13))
                }
                ShortcutLine(reading: flow.shortcut, englishLayout: flow.englishLayout)
            }
            .layoutProbe("onbCard-2.ready")
            // Title and sentence across the card; the note and the picture of macOS's
            // dialog side by side under them, so the card is as tall as the picture.
            OnboardingCard(spacing: 6) {
                Text("Khi bạn bấm “Bật Dấu”")
                    .font(.system(size: 13, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                Text("\(ui.systemSettings) sẽ đóng rồi mở lại và hỏi bạn có cho Dấu bật không. Bấm **\(ui.allow)**.")
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .center, spacing: 16) {
                    Hint(Text("macOS hỏi vì bộ gõ nhận mọi phím bạn gõ. Bộ gõ Dấu không có quyền dùng mạng."))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AllowDialogIllustration()
                }
            }
            if !flow.otherSources.isEmpty {
                OtherSourcesNote(names: flow.otherSources)
            }
        } buttons: {
            if flow.canGoBack {
                Button("Quay lại") { flow.back() }
            }
            Button("Bật Dấu") { Task { await flow.enable() } }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
    }

    // While `enable()` waits for the click.
    private var waiting: some View {
        StepLayout(step: .enable, screen: ".waiting", title: Text("Bật Dấu"), subtitle: addedSubtitle) {
            OnboardingCard {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                                .accessibilityHidden(true)
                            Text("Đang chờ bạn bấm \(ui.allow)")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        Text("Hộp thoại nằm trong cửa sổ \(ui.systemSettings). Bấm **\(ui.allow)**, Dấu tự sang bước tiếp theo.")
                            .font(.system(size: 13))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // A status for VoiceOver: one element that says what it waits for.
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.updatesFrequently)
                    AllowDialogIllustration()
                }
            }
            .layoutProbe("onbCard-2.waiting")
            Hint(Text("Không thấy hộp thoại, hoặc đã chọn \(ui.dontAllow)? Bấm Thử lại."))
        } buttons: {
            if flow.canGoBack {
                Button("Quay lại") { flow.back() }
            }
            Button("Thử lại") { Task { await flow.enable() } }
        }
        .onAppear {
            AccessibilityNotification.Announcement(String(localized: "Đang chờ bạn bấm \(ui.allow)")).post()
        }
    }

    /// D37: one app that still cannot select Dấu is fixed by a fresh login. The menu name
    /// is macOS's own (D38). The Apple menu symbol is drawn with the SF Symbol `applelogo`
    /// (macOS 11+), because the private-use glyph U+F8FF is missing from most fonts.
    static func logOutHint(logOut: String) -> Text {
        Text("Nếu một ứng dụng chưa chọn được Dấu, hãy đăng xuất (\(Image(systemName: "applelogo")) › \(logOut)) rồi đăng nhập lại một lần.")
    }

    /// Plain-text form of the same catalog entry (symbol left out), for tests.
    static func logOutHintPlain(logOut: String) -> String {
        String(format: String(localized: "Nếu một ứng dụng chưa chọn được Dấu, hãy đăng xuất (%@ › %@) rồi đăng nhập lại một lần."), "", logOut)
    }

    // `.enabled`.
    private var done: some View {
        StepLayout(step: .enable, screen: ".done", title: Text("Đã bật Dấu"),
                   subtitle: Text("“Dấu – Tiếng Việt” đã có trong nguồn đầu vào của macOS.")) {
            OnboardingCard {
                HStack(alignment: .top, spacing: 12) {
                    ListBadge(kind: .done, size: 28)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Chọn Dấu để gõ tiếng Việt")
                            .font(.system(size: 13, weight: .semibold))
                            .accessibilityAddTraits(.isHeader)
                        ChooseDauLine(reading: flow.shortcut, englishLayout: flow.englishLayout)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .layoutProbe("onbCard-2.done")
            Hint(Self.logOutHint(logOut: ui.logOut))
        } buttons: {
            Button("Tiếp tục") { flow.next() }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
    }

    // `.notEnabled` or `.notListed`.
    private var notEnabled: some View {
        StepLayout(step: .enable, screen: ".failed", title: Text("Chưa bật được Dấu"),
                   subtitle: Text("macOS chưa thêm Dấu vào nguồn đầu vào. Có thể hộp thoại không hiện, hoặc yêu cầu đã bị từ chối.")) {
            OnboardingCard(spacing: 10) {
                NumberedLine(number: 1, text: Text("Bấm **Thử lại**, rồi bấm **\(ui.allow)** khi \(ui.systemSettings) hỏi."))
                NumberedLine(number: 2, text: Text("Hoặc tự thêm: \(ui.inputSourcesPath) › **\(ui.edit)** › **+** › \(ui.vietnamese) › **Dấu**, rồi bấm **\(ui.add)**."))
                NumberedLine(number: 3, text: Text("Không thấy Dấu trong danh sách đó: đăng xuất rồi đăng nhập lại một lần (menu Apple › **\(ui.logOut)**), rồi mở lại Dấu."))
            }
            .layoutProbe("onbCard-2.failed")
        } buttons: {
            Button("Mở \(ui.systemSettings)") { flow.openSystemSettings() }
            Button("Thử lại") { Task { await flow.enable() } }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
    }

    // An error while copying, checking the signature or registering.
    private var installError: some View {
        StepLayout(step: .enable, screen: ".error", title: Text("Chưa cài được Dấu"),
                   subtitle: Text("Dấu không chép được bộ gõ vào máy, nên chưa bật được.")) {
            OnboardingCard(spacing: 10) {
                NumberedLine(number: 1, text: Text("Bấm **Thử lại**."))
                NumberedLine(number: 2, text: Text("Nếu vẫn lỗi, tải lại Dấu, kéo vào thư mục **\(ui.applications)**, rồi mở lại."))
            }
            .layoutProbe("onbCard-2.error")
            if let detail = flow.errorDetail {
                // The error's own text, selectable so it can be copied into a report.
                VStack(alignment: .leading, spacing: 2) {
                    Hint(Text("Chi tiết"))
                    Text(verbatim: detail)
                        .font(.system(size: 12))
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
        } buttons: {
            if flow.canGoBack {
                Button("Quay lại") { flow.back() }
            }
            Button("Thử lại") { Task { await flow.enable() } }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
    }
}

/// A round badge, 22 pt, as in the artboards' lists: a number on a gray fill (a step in
/// a list), on the accent color (the step to do now), or a check on green (done).
struct ListBadge: View {
    enum Kind { case number(Int), current(Int), done }
    let kind: Kind
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            switch kind {
            case .number(let n):
                Circle().fill(.fill)
                Text(verbatim: "\(n)").font(.system(size: 12, weight: .bold)).foregroundStyle(.primary)
            case .current(let n):
                Circle().fill(Color.accentColor)
                Text(verbatim: "\(n)").font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
            case .done:
                Circle().fill(Color.green)
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// One numbered line of a card (badge and text).
struct NumberedLine: View {
    let number: Int
    let text: Text
    var isCurrent = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ListBadge(kind: isCurrent ? .current(number) : .number(number))
            text
                .font(.system(size: 13))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Bước \(number)"))
        .accessibilityValue(text)
    }
}

/// A small picture of macOS's "Allow … to enable …?" dialog, so the user knows what to
/// look for. Not a control: hidden from VoiceOver. System colors only (D9); the text is
/// the dialog's own wording. Drawn like the real dialog at about 0.75 scale (measured on
/// macOS 27.2, docs/research/M5-INSTALL.md section 8.1b; artboards OnboardingEnable*,
/// canvas version 105): no icon, everything left-aligned, the whole body shown, two
/// equal capsule buttons with "Allow" (the default) blue on the right.
struct AllowDialogIllustration: View {
    /// The dialog's own words, in the system's language (D38).
    private let ui = SystemUINames.system()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: ui.allowDialogTitle(app: "Dấu"))
                .font(.system(size: 10.5, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
            Text(verbatim: ui.allowDialogBody)
                .font(.system(size: 9.5))
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 5) {
                Text(verbatim: ui.dontAllow)
                    .font(.system(size: 9.5, weight: .medium))
                    .frame(maxWidth: .infinity, minHeight: 22)
                    .background(.fill.tertiary, in: Capsule())
                Text(verbatim: ui.allow)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 22)
                    .background(Color.accentColor, in: Capsule())
            }
            .padding(.top, 4)
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 15)
        .padding(.top, 14)
        .padding(.bottom, 13)
        .frame(width: 196, alignment: .leading)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.separator))
        .shadow(color: .black.opacity(0.18), radius: 12, y: 8)
        .accessibilityHidden(true)
    }
}

/// "Chọn Dấu trong menu nhập liệu, hoặc bấm <phím tắt thật> để chuyển giữa Dấu và U.S.":
/// the real shortcut (N5), as the "Sau khi bật" card reads it. No shortcut set: says so
/// and offers "Đặt phím tắt trong System Settings" (`OnboardingEnableDoneNoShortcut`).
/// A shortcut that cannot be read: only "Chọn Dấu trong menu nhập liệu." and the same
/// button, no claim about the shortcut.
struct ChooseDauLine: View {
    let reading: InputSourceShortcut.Reading
    let englishLayout: String?
    private let ui = SystemUINames.system()

    var body: some View {
        switch reading {
        case .shortcut(let shortcut):
            if let englishLayout {
                Text("Chọn Dấu trên menu nguồn đầu vào, hoặc nhấn \(shortcut.inlineText) để chuyển giữa Dấu và “\(englishLayout)”.")
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Chọn Dấu trên menu nguồn đầu vào, hoặc nhấn \(shortcut.inlineText) để chuyển giữa Dấu và bàn phím tiếng Anh.")
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .none:
            Text("Chọn Dấu trên menu nguồn đầu vào. macOS chưa có phím tắt để chuyển nhanh giữa Dấu và bàn phím tiếng Anh.")
                .font(.system(size: 13))
                .fixedSize(horizontal: false, vertical: true)
            SystemSettingsLinkButton(title: String(localized: "Đặt phím tắt trong \(ui.systemSettings)"))
        case .unknown:
            Text("Chọn Dấu trên menu nguồn đầu vào.")
                .font(.system(size: 13))
                .fixedSize(horizontal: false, vertical: true)
            SystemSettingsLinkButton(title: String(localized: "Đặt phím tắt trong \(ui.systemSettings)"))
        }
    }
}

/// The input source shortcut row of step 2: the real shortcut as keycaps (D2), never a
/// guessed one. None set: says so, with a way to System Settings. Not readable: one line
/// saying so, with the same button and no empty keycap (`OnboardingEnableNotes`).
struct ShortcutLine: View {
    let reading: InputSourceShortcut.Reading
    let englishLayout: String?
    private let ui = SystemUINames.system()

    var body: some View {
        switch reading {
        case .shortcut(let shortcut):
            HStack(spacing: 12) {
                ShortcutKeycaps(shortcut: shortcut)
                switchText
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .none:
            HStack(spacing: 12) {
                Text("Chưa có phím tắt để chuyển nhanh sang bàn phím tiếng Anh.")
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SystemSettingsLinkButton(title: String(localized: "Mở \(ui.systemSettings)"))
            }
        case .unknown:
            HStack(spacing: 12) {
                Text("Không đọc được phím tắt chuyển nguồn đầu vào.")
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SystemSettingsLinkButton(title: String(localized: "Mở \(ui.systemSettings)"))
            }
        }
    }

    private var switchText: Text {
        if let englishLayout {
            Text("Phím tắt của macOS để chuyển sang “\(englishLayout)” khi gõ tiếng Anh")
        } else {
            Text("Phím tắt của macOS để chuyển sang bàn phím tiếng Anh")
        }
    }
}

/// A small capsule button that opens the Keyboard pane of System Settings (N4: only opens
/// it), 24 pt tall as in the artboards.
struct SystemSettingsLinkButton: View {
    /// Already in the user's language (`String(localized:)`).
    let title: String

    var body: some View {
        Button(title) { SystemSettings.openKeyboard() }
            .controlSize(.small)
            .buttonBorderShape(.capsule)
            .fixedSize()
    }
}

/// Soft note under the cards: other Vietnamese input sources are on (D14). Not a block.
/// The names are macOS's own, in English.
struct OtherSourcesNote: View {
    let names: [String]
    private let ui = SystemUINames.system()

    var body: some View {
        let list = names.map { "“\($0)”" }.formatted(.list(type: .and))
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Hint(Text("Đang bật nguồn đầu vào tiếng Việt khác: \(list). Bạn có thể bỏ bớt trong \(ui.inputSourcesPath) cho gọn danh sách."))
        }
        .accessibilityElement(children: .combine)
    }
}

/// The input mode icon, drawn from the same geometry as `scripts/assets/make-mode-icons.swift`
/// (22 × 16 pt: a rounded badge with the V cut out). Fill it with even-odd so the V is
/// a hole, like the template image the menu bar shows.
struct InputModeBadge: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 22, sy = rect.height / 16
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            // The script draws with the origin at the bottom left.
            CGPoint(x: rect.minX + x * sx, y: rect.minY + (16 - y) * sy)
        }
        var path = Path(roundedRect: CGRect(x: rect.minX + 0.5 * sx, y: rect.minY + 0.5 * sy,
                                            width: 21 * sx, height: 15 * sy),
                        cornerRadius: 4 * min(sx, sy), style: .circular)
        path.addLines([p(6.5, 12.25), p(8.3, 12.25), p(11.0, 5.875), p(13.7, 12.25),
                       p(15.5, 12.25), p(11.9, 3.75), p(10.1, 3.75)])
        path.closeSubpath()
        return path
    }
}

// MARK: Step 3

struct TypingStep: View {
    @Environment(OnboardingFlow.self) private var flow
    @Environment(SettingsModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var model = model
        @Bindable var flow = flow
        StepLayout(step: .typing, title: Text("Chọn kiểu gõ và gõ thử"),
                   subtitle: Text("Bạn có thể đổi bất cứ lúc nào trong Cài đặt Dấu.")) {
            SegmentedPicker(String(localized: "Kiểu gõ"), selection: $model.settings.typingMethod,
                            options: DauSettings.TypingMethod.allCases.map { ($0, $0.title) })
                .layoutProbe("onbSegmented-3")
            OnboardingCard(spacing: 10) {
                Text("Gõ thử")
                    .font(.system(size: 13, weight: .semibold))
                TextField(text: $flow.tryText, prompt: Text("Gõ ở đây")) {
                    Text("Gõ thử")
                }
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
                .font(.system(size: 16))
                .accessibilityLabel(Text("Gõ thử"))
                .layoutProbe("onbTryField-3")
                Hint(Text("Gợi ý: \(SettingsSamples.tryIt(model.settings.typingMethod).keys)"))
                if flow.status != .selected {
                    Hint(notActiveText)
                }
            }
            .layoutProbe("onbCard-3")
        } buttons: {
            Button("Quay lại") { flow.back() }
            Button("Bắt đầu gõ") { dismiss() }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
    }

    /// The field types with the current input source, which is not Dấu yet.
    private var notActiveText: Text {
        if let shortcut = flow.shortcut.shortcut {
            Text("Dấu chưa phải nguồn đầu vào đang dùng: chọn “Dấu – Tiếng Việt” trên menu nguồn đầu vào hoặc nhấn \(shortcut.inlineText) rồi gõ thử.")
        } else {
            Text("Dấu chưa phải nguồn đầu vào đang dùng: chọn “Dấu – Tiếng Việt” trên menu nguồn đầu vào rồi gõ thử.")
        }
    }
}
