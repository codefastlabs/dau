#if DEBUG
import AppKit
import ApplicationServices
import SwiftUI

/// Where the capture modes put a window: the middle of the primary display (the one with
/// the menu bar), in view. They used to move it to (-9000, -9000); macOS pulled it back
/// into a corner of the main screen, where it peeked out during the run, and AppKit saved
/// that corner as the window's frame for the next normal launch (03/11/2026). Not
/// `NSScreen.main`: that is the screen of the user's key window, which can be a 1x display
/// and gave 1x captures that the pass values (made on the Retina display) do not fit.
@MainActor func centeredFrame(size: NSSize) -> NSRect {
    let visible = NSScreen.screens.first?.visibleFrame ?? NSRect(x: 0, y: 0, width: size.width, height: size.height)
    return NSRect(x: (visible.midX - size.width / 2).rounded(), y: (visible.midY - size.height / 2).rounded(),
                  width: size.width, height: size.height)
}

/// Puts a capture window in the middle of the primary display over a plain backdrop. The
/// sidebar and toolbar materials blend what lies behind the window; the backdrop, one
/// system color right below it, keeps that the same whatever the user has on screen.
/// A precaution: its effect alone was not measured (the dark-mode failures of the first
/// on-screen runs came from 1x captures, see `centeredFrame`).
@MainActor func placeForCapture(_ window: NSWindow, size: NSSize) {
    let frame = centeredFrame(size: size)
    window.setFrame(frame, display: false)
    let backdrop = CaptureBackdrop.window
    backdrop.setFrame(frame.insetBy(dx: -40, dy: -40), display: true)
    backdrop.order(.below, relativeTo: window.windowNumber)
}

@MainActor enum CaptureBackdrop {
    static let window: NSWindow = {
        let w = NSWindow(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)
        w.backgroundColor = .windowBackgroundColor
        w.isOpaque = true
        w.hasShadow = false
        w.ignoresMouseEvents = true
        w.isReleasedWhenClosed = false
        return w
    }()
}

/// Debug only: in-app captures that need fake services, run by
/// scripts/selftest/settings-window on a copy re-signed ad hoc without entitlements:
/// `--capture-onboarding` (the onboarding window on fixed services),
/// `--capture-uninstall` (the uninstall alerts and the "Bỏ Dấu khỏi nguồn đầu vào"
/// sheet, laid out without running anything), `--capture-report` (the "Báo ứng dụng gõ
/// lỗi" sheet on fixed sample content; nothing is opened or sent), `--capture-updates`
/// (Cập nhật & hỗ trợ as a release build shows it, on a fake updater; Sparkle is not
/// tested here, M7 step 2 does that with real builds). The Settings window
/// itself is measured from outside, in the real app (`--settings-window`, AXCheck.swift).
@MainActor
enum DebugCapture {
    /// Frames the onboarding window's layout probes report, while capturing; a view that
    /// disappears takes its frame out (`LayoutProbeModifier`), so a shot only lists the
    /// views it shows.
    static var frames: [String: CGRect] = [:]

    /// The probe closure installed in the onboarding scene while capturing.
    static var probe: (@MainActor @Sendable (String, CGRect) -> Void)? {
        guard onboardingDirectory != nil || reportDirectory != nil || updatesDirectory != nil else { return nil }
        return { @MainActor name, frame in DebugCapture.frames[name] = frame.isNull ? nil : frame }
    }

    // MARK: Onboarding

    /// `--onboarding <1|2|3>`: open the onboarding window at that step (real services).
    static let onboardingStep: OnboardingFlow.Step? = {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--onboarding"), i + 1 < args.count,
              let n = Int(args[i + 1]) else { return nil }
        return OnboardingFlow.Step(rawValue: n)
    }()

    /// `--capture-onboarding <dir>`: the onboarding window on fixed services (OpenKey
    /// running, Dấu installed but not enabled). Writes `onboarding-<step>-<mode>.png` for
    /// "Chuyển Dấu vào Applications" (`0-move`: not the owner copy, nothing installed),
    /// steps 1, 2 before "Bật Dấu" (`2`), 2 with an unreadable shortcut and another
    /// Vietnamese source on (`2-notes`), 2 waiting for Allow (`2-waiting`), 2 when macOS
    /// left Dấu off (`2-failed`), 2 on an install error (`2-error`), 2 once enabled
    /// (`2-done`), 2 enabled with no shortcut set (`2-done-noshortcut`) and 3, light and
    /// dark, plus `frames.json`.
    static let onboardingDirectory: URL? = {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--capture-onboarding"), i + 1 < args.count else { return nil }
        return URL(fileURLWithPath: args[i + 1], isDirectory: true)
    }()

    /// `--shortcut none|unknown`: pretend the input source shortcut reads so (captures).
    static let shortcutArgument: InputSourceShortcut.Reading? = {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--shortcut"), i + 1 < args.count else { return nil }
        switch args[i + 1] {
        case "none": return InputSourceShortcut.Reading.none
        case "unknown": return InputSourceShortcut.Reading.unknown
        default: return nil
        }
    }()

    /// What the captures' flow reads as the shortcut: a shot may set it; nil reads the
    /// real one.
    static var shortcutNow: InputSourceShortcut.Reading? = shortcutArgument

    static var onboardingFlow: OnboardingFlow?
    static var onboardingDetector: FakeInputMethodDetector?
    static var onboardingInstaller: FakeInputMethodInstaller?
    /// The Settings window's actions (`--capture-uninstall` lays the sheet out through them).
    static var actions: InputMethodActions?

    static func startOnboarding() {
        guard let directory = onboardingDirectory else { return }
        NSApp.setActivationPolicy(.accessory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        Task { @MainActor in
            // The window opens once the Settings window has appeared (LaunchRouting).
            let window = await window("onboarding window") { $0.title == String(localized: "Set Up Dấu") }
            guard let flow = onboardingFlow else { print("no onboarding flow"); exit(1) }
            placeForCapture(window, size: window.frame.size)
            if CommandLine.arguments.contains("--active") {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate()
                window.makeKeyAndOrderFront(nil)
            }
            var report: [String: [String: [Double]]] = [:]
            // Show another step first so step 1's probes report again; drop the
            // Settings window's probes.
            flow.show(.typing)
            require(await poll { frames.keys.contains { $0.hasSuffix("-3") } }, "step 3's probes")
            frames = frames.filter { $0.key.hasPrefix("onb") }
            for (mode, name) in [("light", NSAppearance.Name.aqua), ("dark", .darkAqua)] {
                await applyAppearance(name, to: window)
                let openKey = onboardingDetector?.found ?? []
                onboardingInstaller?.current = .installed(version: nil)
                onboardingInstaller?.enableWaits = false
                onboardingInstaller?.failure = nil
                onboardingInstaller?.genuine = true
                shortcutNow = shortcutArgument
                flow.start()
                flow.tryText = ""
                let installer = onboardingInstaller
                let detector = onboardingDetector
                let shots: [(String, @MainActor () async -> Void)] = [
                    // Before step 1: this copy is not the owner copy and nothing is
                    // installed (D37).
                    ("0-move", {
                        installer?.ownerCopy = false
                        installer?.current = .notInstalled
                        flow.refresh()
                    }),
                    // Back to the fixed services: the owner copy, Dấu installed, not enabled.
                    ("1", {
                        installer?.ownerCopy = true
                        installer?.current = .installed(version: nil)
                        flow.refresh()
                        flow.show(.oldInputMethods)
                    }),
                    // As in the mockup: the user quit OpenKey, step 1 is done.
                    ("2", { detector?.found = []; flow.refresh(); flow.show(.enable) }),
                    // The shortcut cannot be read and another Vietnamese source is on
                    // (D14).
                    ("2-notes", {
                        shortcutNow = InputSourceShortcut.Reading.unknown
                        detector?.otherSources = ["Tiếng Việt – Telex"]
                        flow.refresh()
                    }),
                    // "Bật Dấu" is waiting for the click on macOS's dialog.
                    ("2-waiting", {
                        shortcutNow = shortcutArgument
                        detector?.otherSources = []
                        flow.refresh()
                        installer?.enableWaits = true
                        Task { @MainActor in await flow.enable() }
                        require(await poll { flow.isWorking }, "Bật Dấu waiting")
                    }),
                    // The wait ends with Dấu still off.
                    ("2-failed", {
                        installer?.enableOutcome = .notEnabled
                        installer?.release = .notEnabled
                        while flow.isWorking { try? await Task.sleep(for: .milliseconds(20)) }
                    }),
                    // "Thử lại" hits an install error.
                    ("2-error", {
                        installer?.enableWaits = false
                        installer?.failure = .invalidSignature
                        await flow.enable()
                    }),
                    // Enabled from there (the capture skips "Cài lại"), and this time the user allows it.
                    ("2-done", {
                        installer?.failure = nil
                        installer?.enableOutcome = .enabled
                        await flow.enable()
                    }),
                    ("2-done-noshortcut", { shortcutNow = InputSourceShortcut.Reading.none; flow.refresh() }),
                    ("3", { shortcutNow = shortcutArgument; flow.refresh(); flow.tryText = "Tôi yêu tiếng Việt"; flow.show(.typing) }),
                ]
                for (key, setUp) in shots {
                    // Probes report changes only: a view still shown keeps its frame
                    // from the shot before, a view gone has none (it is FAIL in check (f)),
                    // the step's own views report again when the step changes.
                    await setUp()
                    await captureSettled(window, to: directory.appendingPathComponent("onboarding-\(key)-\(mode).png"),
                                         "onboarding \(key) \(mode)")
                    // Step views name their probes "<name>-<step>": keep the shown step's.
                    var entry: [String: [Double]] = [:]
                    for (name, r) in frames {
                        let parts = name.split(separator: "-", maxSplits: 1).map(String.init)
                        if parts.count == 2 {
                            // "<step>" or "<step>.<screen>" (step 2 swaps screens).
                            let current = "\(flow.step.rawValue)"
                            guard parts[1] == current || parts[1].hasPrefix(current + ".") else { continue }
                            entry[parts[0]] = [Double(r.minX), Double(r.minY), Double(r.width), Double(r.height)]
                        } else {
                            entry[name] = [Double(r.minX), Double(r.minY), Double(r.width), Double(r.height)]
                        }
                    }
                    if let b = window.standardWindowButton(.closeButton), let s = b.superview {
                        let r = s.convert(b.frame, to: nil)
                        entry["close"] = [Double(r.minX), Double(window.frame.height - r.maxY), Double(r.width), Double(r.height)]
                    }
                    entry["window"] = [0, 0, Double(window.frame.width), Double(window.frame.height)]
                    // Check (f): the window shows no title text (`.hiddenTitleBar`, DauApp).
                    entry["titleHidden"] = [window.titleVisibility == .hidden ? 1 : 0]
                    report["onboarding-\(key)-\(mode)"] = entry
                    if mode == "light" {
                        try? await accessibilityTree(window).write(
                            to: directory.appendingPathComponent("onboarding-\(key)-accessibility.txt"),
                            atomically: true, encoding: .utf8)
                    }
                }
                onboardingDetector?.found = openKey
            }
            if let data = try? JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted]) {
                try? data.write(to: directory.appendingPathComponent("frames.json"))
            }
            print("captured to \(directory.path)")
            exit(0)
        }
    }

    // MARK: Uninstall alert

    /// `--capture-uninstall <dir>`: opens the Settings window in the middle of the primary
    /// display, lays out the "Gỡ Dấu khỏi máy?" alert, the result alert and the "Bỏ Dấu
    /// khỏi nguồn đầu vào" sheet there without running anything, and writes
    /// `uninstall-confirm-<mode>.png`, `uninstall-done-<mode>.png`,
    /// `uninstall-remove-<mode>.png` (Dấu not selected) and
    /// `uninstall-remove-hint-<mode>.png` (Dấu selected: with the "–" hint), plus `frames.json`
    /// (sheet sizes).
    static let uninstallDirectory: URL? = {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--capture-uninstall"), i + 1 < args.count else { return nil }
        return URL(fileURLWithPath: args[i + 1], isDirectory: true)
    }()

    static func startUninstall() {
        guard let directory = uninstallDirectory else { return }
        NSApp.setActivationPolicy(.accessory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        Task { @MainActor in
            let window = await window("Settings window") { _ in true }
            placeForCapture(window, size: SettingsScene.defaultSize)
            var report: [String: [String: [Double]]] = [:]
            for (mode, name) in [("light", NSAppearance.Name.aqua), ("dark", .darkAqua)] {
                await applyAppearance(name, to: window)
                let sample = UninstallReport(movedToTrash: true, stillEnabled: false, dataDeleted: true)
                let alerts: [(String, NSAlert)] = [
                    ("confirm", UninstallAlert.confirmation().0),
                    ("done", UninstallAlert.done(sample)),
                ]
                for (key, alert) in alerts {
                    // The window `runModal` would show, without the modal loop.
                    alert.layout()
                    let panel = alert.window
                    panel.appearance = NSAppearance(named: name)
                    panel.orderFront(nil)
                    placeForCapture(panel, size: panel.frame.size)
                    // The alert's glass shows whatever is behind it (the backdrop): put it
                    // on the window background, roughly what it covers over the Settings window.
                    await captureSettled(panel, to: directory.appendingPathComponent("uninstall-\(key)-\(mode).png"),
                                         background: .windowBackgroundColor, "alert \(key) \(mode)")
                    report["uninstall-\(key)-\(mode)"] = ["sheet": [0, 0, Double(panel.frame.width), Double(panel.frame.height)]]
                    panel.orderOut(nil)
                    require(await poll { !panel.isVisible }, "alert \(key) to close")
                }
                // The sheet of the Settings window, on the fake preparation.
                window.makeKeyAndOrderFront(nil)
                let sheets: [(String, Bool)] = [("remove", false), ("remove-hint", true)]
                for (key, dauIsSelected) in sheets {
                    actions?.showUninstallSheetForCapture(true, dauIsSelected: dauIsSelected)
                    require(await poll { window.attachedSheet != nil }, "sheet \(key)")
                    guard let sheet = window.attachedSheet else { print("no sheet for \(key)"); exit(1) }
                    await captureSettled(sheet, to: directory.appendingPathComponent("uninstall-\(key)-\(mode).png"),
                                         background: .windowBackgroundColor, "sheet \(key) \(mode)")
                    report["uninstall-\(key)-\(mode)"] = ["sheet": [0, 0, Double(sheet.frame.width), Double(sheet.frame.height)]]
                    actions?.showUninstallSheetForCapture(false)
                    require(await poll { window.attachedSheet == nil }, "sheet \(key) to close")
                }
            }
            if let data = try? JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted]) {
                try? data.write(to: directory.appendingPathComponent("frames.json"))
            }
            print("captured to \(directory.path)")
            exit(0)
        }
    }

    // MARK: Problem report sheet

    /// `--capture-report <dir>`: the Settings window opens on Cập nhật & hỗ trợ with the
    /// "Báo ứng dụng gõ lỗi" sheet shown (`UpdatesSupportView`), filled with
    /// `reportSample` instead of the running apps (the shot must not show the user's apps
    /// and must compare with the Report artboard). Writes `report-<mode>.png` (light,
    /// dark) and `frames.json`: per shot the sheet's size ("sheet") and the "Gửi kèm" footer
    /// ("reportIncluded", sheet points), so check (h) can tell a cut sheet. "Mở trên
    /// GitHub" is never pressed.
    static let reportDirectory: URL? = {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--capture-report"), i + 1 < args.count else { return nil }
        return URL(fileURLWithPath: args[i + 1], isDirectory: true)
    }()

    /// The artboard's sample: Google Chrome 131.0 on docs.google.com, "tieengs Vieetj".
    static let reportSample = (app: ReportedApp(bundleID: "com.google.Chrome", name: "Google Chrome", version: "131.0"),
                               website: "docs.google.com", example: "tieengs Vieetj")

    static func startReport() {
        guard let directory = reportDirectory else { return }
        NSApp.setActivationPolicy(.accessory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        Task { @MainActor in
            let window = await window("Settings window") { $0.sheetParent == nil }
            placeForCapture(window, size: SettingsScene.defaultSize)
            var report: [String: [String: [Double]]] = [:]
            for (mode, name) in [("light", NSAppearance.Name.aqua), ("dark", .darkAqua)] {
                await applyAppearance(name, to: window)
                window.makeKeyAndOrderFront(nil)
                // The sheet opens with the page (`UpdatesSupportView`); `captureSettled`
                // then waits for its layout (the footer probe included) and its slide-in.
                require(await poll { window.attachedSheet != nil }, "report sheet")
                guard let sheet = window.attachedSheet else { print("no report sheet"); exit(1) }
                await captureSettled(sheet, to: directory.appendingPathComponent("report-\(mode).png"),
                                     background: .windowBackgroundColor, "report sheet \(mode)")
                var shot = ["sheet": [0, 0, Double(sheet.frame.width), Double(sheet.frame.height)]]
                if let footer = frames["reportIncluded"] {
                    shot["reportIncluded"] = [footer.minX, footer.minY, footer.width, footer.height].map(Double.init)
                }
                report["report-\(mode)"] = shot
            }
            if let data = try? JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted]) {
                try? data.write(to: directory.appendingPathComponent("frames.json"))
            }
            print("captured to \(directory.path)")
            exit(0)
        }
    }

    // MARK: Updates page of a release build

    /// `--capture-updates <dir>`: the Settings window opens on Cập nhật & hỗ trợ as a
    /// release build shows it, on a fake updater (`CaptureUpdater`: checked today at 9:41,
    /// automatic checks on) and an in-memory channel store, so Sparkle never runs, nothing
    /// is downloaded and no setting is written. As on a release build, the version line
    /// reads `releaseVersionSample` and the installed input method's line is absent. Like
    /// the other captures the app is not activated (macOS 14+ activation is cooperative,
    /// and it would take focus from the user), so selected segments are grey. Writes
    /// `updates-release-<stage>-<mode>.png` for both values of the SettingsAbout artboard's
    /// `stage` tweak, light and dark: `nostable` (the appcast has betas only: Beta selected,
    /// Stable off, first description) and `stable` (a stable item exists, the user stays on
    /// Beta: both on, second description); and `frames.json`: per shot, window points from
    /// the top-left, the window and the page's layout probes (`updatesProbes`), plus flags:
    /// the segments' enabled state, the selected segment, whether the version line is
    /// `releaseVersionSample`. Not the
    /// Accessibility API: the ad hoc re-signed copy has no Accessibility permission.
    static let updatesDirectory: URL? = {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--capture-updates"), i + 1 < args.count else { return nil }
        return URL(fileURLWithPath: args[i + 1], isDirectory: true)
    }()

    /// The version line of the capture: a release build's "Dấu 0.1.0 (6520)" (D25), on
    /// fixed sample values (version 0.1.0, build 6520, as the artboard). nil outside
    /// `--capture-updates`, so no real path ever shows it.
    nonisolated static let releaseVersionSample: String? = CommandLine.arguments.contains("--capture-updates")
        ? AppVersion.nameAndVersion(marketing: "0.1.0", build: "6520", commit: nil, debug: false, official: true)
        : nil

    /// The capture's appcasts, as `SUAppcast.items.map(\.channel)` (D7: betas carry `beta`,
    /// a stable release none).
    static let updatesStages: [(key: String, itemChannels: [String?])] = [
        ("nostable", ["beta", "beta"]),
        ("stable", ["beta", nil, "beta"]),
    ]

    /// The probes of Cập nhật & hỗ trợ that `--capture-updates` records: the version card's
    /// first row, the "Tự động kiểm tra bản mới" row (its switch at the right), the "Kênh
    /// phát hành" row and its control, and the installed input method's line
    /// (a development build's; the capture must not show it).
    static let updatesProbes = ["firstRow", "autoCheck", "releaseChannel", "channelControl", "installedBuild"]

    /// The release build's update model for `--capture-updates`; nil otherwise.
    static let updatesModel: UpdatesModel? = {
        guard updatesDirectory != nil else { return nil }
        return UpdatesModel(backend: CaptureUpdater(), channels: ReleaseChannels(store: CaptureChannelStore()))
    }()

    static func startUpdates() {
        guard let directory = updatesDirectory, let updates = updatesModel else { return }
        NSApp.setActivationPolicy(.accessory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        Task { @MainActor in
            let window = await window("Settings window") { $0.sheetParent == nil }
            placeForCapture(window, size: SettingsScene.defaultSize)
            var report: [String: [String: [Double]]] = [:]
            for (mode, name) in [("light", NSAppearance.Name.aqua), ("dark", .darkAqua)] {
                await applyAppearance(name, to: window)
                window.makeKeyAndOrderFront(nil)
                for stage in updatesStages {
                    // The first load decides Beta (no stable item); a later one with a
                    // stable item leaves the user on Beta (D7), as the artboard's stage.
                    updates.channels.appcastLoaded(itemChannels: stage.itemChannels)
                    // The row shows the stage: Stable on only once a stable item exists.
                    let stableOn = stage.itemChannels.contains { $0 == nil }
                    require(await poll {
                        segmentedControls(in: window.contentView).first {
                            $0.accessibilityLabel() == String(localized: "Release channel") && $0.segmentCount == 2
                        }.map { $0.isEnabled(forSegment: 1) == stableOn } ?? false
                    }, "the channel row of stage \(stage.key)")
                    let key = "updates-release-\(stage.key)-\(mode)"
                    await captureSettled(window, to: directory.appendingPathComponent("\(key).png"), key)
                    // The page's layout probes (`UpdatesSupportView`), window points from
                    // the top-left; a view gone has no frame (`LayoutProbeModifier`).
                    var shot: [String: [Double]] = [:]
                    for name in updatesProbes {
                        if let r = frames[name] { shot[name] = [r.minX, r.minY, r.width, r.height].map(Double.init) }
                    }
                    shot["window"] = [0, 0, Double(window.frame.width), Double(window.frame.height)]
                    shot["versionSample"] = [AppVersion.nameAndVersion == releaseVersionSample ? 1 : 0]
                    if let control = segmentedControls(in: window.contentView).first(where: {
                        $0.accessibilityLabel() == String(localized: "Release channel") }) {
                        shot["channelEnabled"] = (0..<control.segmentCount).map { control.isEnabled(forSegment: $0) ? 1 : 0 }
                        shot["channelSelected"] = [Double(control.selectedSegment)]
                    }
                    report[key] = shot
                }
            }
            if let data = try? JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted]) {
                try? data.write(to: directory.appendingPathComponent("frames.json"))
            }
            print("captured to \(directory.path)")
            exit(0)
        }
    }

    private static func segmentedControls(in view: NSView?) -> [NSSegmentedControl] {
        guard let view else { return [] }
        return view.subviews.flatMap { ($0 as? NSSegmentedControl).map { [$0] } ?? segmentedControls(in: $0) }
    }

    /// The window's accessibility tree as VoiceOver gets it, one element per line:
    /// role, title/description, value, help, indented by depth. Uses the AX API on this
    /// process (SwiftUI builds its tree only for an AX client), from a background thread
    /// while the main thread keeps answering. Needs the Accessibility permission of the
    /// launching app (Terminal); empty without it.
    static func accessibilityTree(_ window: NSWindow) async -> String {
        let pid = ProcessInfo.processInfo.processIdentifier
        let title = window.title
        return await withCheckedContinuation { continuation in
            Thread.detachNewThread {
                continuation.resume(returning: axDump(pid: pid, windowTitle: title))
            }
        }
    }

    nonisolated private static func axDump(pid: pid_t, windowTitle: String) -> String {
        func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
            var value: CFTypeRef?
            return AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success ? value : nil
        }
        func string(_ element: AXUIElement, _ name: String) -> String? {
            guard let value = attribute(element, name) else { return nil }
            if CFGetTypeID(value) == CFStringGetTypeID() { return value as? String }
            if CFGetTypeID(value) == CFNumberGetTypeID() || CFGetTypeID(value) == CFBooleanGetTypeID() { return "\(value)" }
            return nil
        }
        var lines: [String] = []
        func walk(_ element: AXUIElement, depth: Int) {
            guard depth < 40 else { return }
            var parts = [string(element, kAXRoleAttribute) ?? "?"]
            for (key, name) in [("title", kAXTitleAttribute), ("desc", kAXDescriptionAttribute),
                                ("value", kAXValueAttribute), ("help", kAXHelpAttribute)] {
                if let v = string(element, name), !v.isEmpty { parts.append("\(key)=\"\(v)\"") }
            }
            if string(element, kAXEnabledAttribute) == "0" { parts.append("disabled") }
            lines.append(String(repeating: "  ", count: depth) + parts.joined(separator: " "))
            for child in (attribute(element, kAXChildrenAttribute) as? [AXUIElement]) ?? [] {
                walk(child, depth: depth + 1)
            }
        }
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 5)
        let windows = (attribute(app, kAXWindowsAttribute) as? [AXUIElement]) ?? []
        guard let window = windows.first(where: { string($0, kAXTitleAttribute) == windowTitle }) ?? windows.first else {
            return "no AX window (trusted: \(AXIsProcessTrusted()))\n"
        }
        walk(window, depth: 0)
        return lines.joined(separator: "\n") + "\n"
    }

    /// `--settings-window`: open the Settings window at launch, never the onboarding,
    /// and leave the installed input method alone (real-window checks).
    static let settingsWindowOnly = CommandLine.arguments.contains("--settings-window")

    /// `--tampered`: the Settings window shows the "Cài lại" banner whatever is installed
    /// (`InputMethodActions.forceTampered`), and the installed input method is left alone:
    /// no launch reconcile, no signature check.
    static let tampered = CommandLine.arguments.contains("--tampered")

    /// `--appearance light|dark`: this app only draws in that appearance (the real-window
    /// checks capture the sheet in the appearance the system is not in). The system
    /// appearance is not changed (N4); `-AppleInterfaceStyle` as an argument does not
    /// change the windows' appearance (measured on macOS 27.2).
    static func applyAppearanceOverride() {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--appearance"), i + 1 < args.count else { return }
        switch args[i + 1] {
        case "light": NSApp.appearance = NSAppearance(named: .aqua)
        case "dark": NSApp.appearance = NSAppearance(named: .darkAqua)
        default: break
        }
    }

    // MARK: Waiting for a state, not a clock

    /// One display frame at 60 Hz: the polling step. Each step is a `Task.sleep`, so the
    /// main run loop turns between reads and SwiftUI applies its pending updates.
    static let frameStep = Duration.milliseconds(16)

    /// Polls `condition` once per frame until it holds; false after `timeout`.
    static func poll(timeout: Duration = .seconds(3), _ condition: () -> Bool) async -> Bool {
        let clock = ContinuousClock(), deadline = clock.now + timeout
        while !condition() {
            if clock.now >= deadline { return condition() }
            try? await Task.sleep(for: frameStep)
        }
        return true
    }

    /// Waits until `read` gives the same value on `reads` reads one frame apart (a step
    /// before each read, so the first read already sees what the last change laid out);
    /// false after `timeout`.
    static func settled<T: Equatable>(reads: Int = 3, timeout: Duration = .seconds(3), _ read: () -> T) async -> Bool {
        let clock = ContinuousClock(), deadline = clock.now + timeout
        try? await Task.sleep(for: frameStep)
        var last = read(), same = 1
        while same < reads {
            if clock.now >= deadline { return false }
            try? await Task.sleep(for: frameStep)
            let now = read()
            same = now == last ? same + 1 : 1
            last = now
        }
        return true
    }

    /// Ends the capture run with a reason (run.sh shows the app's last lines) when a state
    /// the next step needs did not come.
    static func require(_ ok: Bool, _ what: String) {
        guard !ok else { return }
        print("capture: timed out waiting for \(what)")
        exit(1)
    }

    /// The first visible window `matching`, once it is there (up to 10 s: the app is still
    /// launching); ends the run otherwise.
    static func window(_ what: String, matching: (NSWindow) -> Bool) async -> NSWindow {
        var found: NSWindow?
        _ = await poll(timeout: .seconds(10)) {
            found = NSApp.windows.first { $0.isVisible && $0.contentView != nil && matching($0) }
            return found != nil
        }
        guard let found else {
            print("no \(what):", NSApp.windows.map { "\($0.title) \($0.frame) visible=\($0.isVisible)" })
            exit(1)
        }
        return found
    }

    /// Sets the app's appearance and waits until `window` draws in it.
    static func applyAppearance(_ name: NSAppearance.Name, to window: NSWindow) async {
        NSApp.appearance = NSAppearance(named: name)
        require(await poll { window.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == name },
                "the \(name.rawValue) appearance")
    }

    /// What a shot of `window` depends on that the app can read: its frame, its attached
    /// sheet's, the layout probes' frames. Equal on consecutive frames = laid out.
    static func layoutState(_ window: NSWindow) -> String {
        let probes = frames.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ";")
        return "\(window.frame) \(window.isVisible) \(window.attachedSheet.map { "\($0.frame)" } ?? "-") \(probes)"
    }

    /// Captures `window` once what it shows has come to rest, then writes the PNG:
    /// 1. its layout state (`layoutState`) is the same on 3 frames;
    /// 2. pending drawing is done and handed to the window server;
    /// 3. two composited images in a row agree (< 0.5% of sampled pixels differ), so a
    ///    sheet sliding in or an alert fading in has ended; a spinner in the shot (the
    ///    uninstall sheet, "2-waiting") moves on fewer pixels than that.
    /// Each step ends the run on timeout (3 s), naming `what`.
    static func captureSettled(_ window: NSWindow, to url: URL, background: NSColor? = nil, _ what: String) async {
        let layoutOwner = window.sheetParent ?? window
        require(await settled { layoutState(layoutOwner) }, "\(what): layout")
        window.contentView?.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        CATransaction.flush()
        var image: CGImage?
        if compositedImage(window) != nil {
            var previous: CGImage?
            let rested = await poll {
                let now = compositedImage(window)
                defer { previous = now }
                guard let now, let previous else { return false }
                if nearlyEqual(now, previous) { image = now; return true }
                return false
            }
            require(rested, "\(what): drawing to come to rest")
        }
        capture(window, image: image, to: url, background: background)
    }

    /// Fewer than 0.5% of the pixels on a 4-pixel grid differ (any channel by more than 2).
    private static func nearlyEqual(_ a: CGImage, _ b: CGImage) -> Bool {
        guard a.width == b.width, a.height == b.height, a.bitsPerPixel == 32, b.bitsPerPixel == 32,
              a.bytesPerRow == b.bytesPerRow,
              let da = a.dataProvider?.data, let db = b.dataProvider?.data,
              let pa = CFDataGetBytePtr(da), let pb = CFDataGetBytePtr(db) else { return false }
        var differ = 0, total = 0
        for y in stride(from: 0, to: a.height, by: 4) {
            let row = y * a.bytesPerRow
            for x in stride(from: 0, to: a.width, by: 4) {
                let i = row + x * 4
                total += 1
                if abs(Int(pa[i]) - Int(pb[i])) > 2 || abs(Int(pa[i + 1]) - Int(pb[i + 1])) > 2
                    || abs(Int(pa[i + 2]) - Int(pb[i + 2])) > 2 || abs(Int(pa[i + 3]) - Int(pb[i + 3])) > 2 {
                    differ += 1
                }
            }
        }
        return total > 0 && differ * 200 < total
    }

    /// The window as the window server composites it (materials, scroll edge effects),
    /// through `CGWindowListCreateImage`, which needs no permission for the app's own
    /// windows. The function is unavailable to Swift in the macOS 15+ SDK, so it is
    /// looked up at run time; nil if it is gone.
    private static func compositedImage(_ window: NSWindow) -> CGImage? {
        typealias Create = @convention(c) (CGRect, UInt32, UInt32, UInt32) -> Unmanaged<CGImage>?
        guard let handle = dlopen(nil, RTLD_NOW), let sym = dlsym(handle, "CGWindowListCreateImage") else { return nil }
        let create = unsafeBitCast(sym, to: Create.self)
        // kCGWindowListOptionIncludingWindow = 8; kCGWindowImageBoundsIgnoreFraming = 1,
        // kCGWindowImageBestResolution = 8.
        return create(.null, 8, UInt32(window.windowNumber), 1 | 8)?.takeRetainedValue()
    }

    /// Writes `image` (or, without one, what `window` composites now, or its own drawing)
    /// to `url` as a PNG.
    private static func capture(_ window: NSWindow, image settledImage: CGImage? = nil, to url: URL, background: NSColor? = nil) {
        var image = settledImage ?? compositedImage(window)
        if image == nil, let frameView = window.contentView?.superview {
            frameView.display()
            if let rep = frameView.bitmapImageRepForCachingDisplay(in: frameView.bounds) {
                frameView.cacheDisplay(in: frameView.bounds, to: rep)
                image = rep.cgImage
            }
        }
        guard var image else { return }
        if let background, let flat = flatten(image, on: background, appearance: window.effectiveAppearance) {
            image = flat
        }
        try? NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])?.write(to: url)
    }

    /// `image` drawn over `color` (resolved in `appearance`).
    private static func flatten(_ image: CGImage, on color: NSColor, appearance: NSAppearance) -> CGImage? {
        guard let context = CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8,
                                      bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        var fill: CGColor?
        appearance.performAsCurrentDrawingAppearance { fill = color.cgColor }
        let rect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        context.setFillColor(fill ?? .white)
        context.fill(rect)
        context.draw(image, in: rect)
        return context.makeImage()
    }
}

/// The updater of `--capture-updates`: Sparkle's state as a release build shows it after a
/// check today at 9:41 (the artboard's time), automatic checks on; a check does nothing.
@MainActor
final class CaptureUpdater: UpdaterBackend {
    var canCheckForUpdates = true
    var lastUpdateCheckDate: Date? = Calendar.current.date(bySettingHour: 9, minute: 41, second: 0, of: Date())
    var automaticallyChecksForUpdates = true
    func checkForUpdates() {}
    func observeChanges(_ changed: @escaping @MainActor @Sendable () -> Void) {}
    func allowedChannelsChanged() {}
}

/// The channel store of `--capture-updates`: in memory, so the capture writes no defaults.
@MainActor
final class CaptureChannelStore: ReleaseChannelStore {
    var channel: ReleaseChannel?
    var stableReleaseExists: Bool?
}
#endif
