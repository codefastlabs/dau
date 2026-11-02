// Real-window check of the Settings window (docs/UI-CHECKS.md, "Cửa sổ thật").
//
// Usage: ax-check <pid> <output-dir> [--banner]
//
// Reads the frames of the running app's Settings window through the Accessibility API
// (the launching terminal needs the Accessibility permission) and compares them with
// System Settings, measured on macOS 27.2 (docs/research/SYSTEM-SETTINGS-REFERENCE.md),
// ±1 pt. Unlike `Dau --capture-window`, nothing here runs inside the app: the window
// is the one the user gets. On every display (one pass per backing scale) the window
// is moved there at 740 × 560, each section is selected through the sidebar's
// accessibility (no clicks), measured and captured with `screencapture -l`
// (<section>-<scale>x.png). Then the window's size limits are tried and the window is
// put back at 740 × 560. `--banner`: the app runs with `--not-enabled`; also checks
// that the banner is the first card. Exit status 0 only if every check passes.
//
// Expected values (pt, origin at the window's top-left):
// - toolbar 52 tall; close button 18,18 16×16; page title starting at the detail
//   column's margin (232 + 20) and centered in the toolbar (y center 26);
// - sidebar search field 10,61 212×28; rows 32 tall from y 98, selection cell x 10
//   width 212; icon tile from x 19, 20 tall; text from x 46 (pixels);
// - first card or section header at y 72 (52 + SwiftUI's 20 pt top margin: kept on
//   purpose, System Settings has 12 → 64); cards x 252, width = column − 40;
//   header x = card + 10, header → card 10, card → next header 30;
// - switches 36×16; buttons, pop-ups and segmented controls 24 tall;
// - window limits: 740 × 452 at least, 976 wide at most (sidebar + 744, beyond which
//   a grouped Form centers its 704 pt cards: UI-CHECKS item 1).
import AppKit

let args = CommandLine.arguments
guard args.count >= 3, let pid = pid_t(args[1]) else {
    print("usage: ax-check <pid> <output-dir> [--banner]"); exit(2)
}
let outDir = URL(fileURLWithPath: args[2], isDirectory: true)
let bannerRun = args.contains("--banner")
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

guard AXIsProcessTrusted() else {
    print("FAIL no Accessibility permission for this terminal (System Settings › Privacy & Security › Accessibility)")
    exit(1)
}

let app = AXUIElementCreateApplication(pid)
AXUIElementSetMessagingTimeout(app, 5)

func attr(_ e: AXUIElement, _ name: String) -> CFTypeRef? {
    var v: CFTypeRef?
    return AXUIElementCopyAttributeValue(e, name as CFString, &v) == .success ? v : nil
}
func string(_ e: AXUIElement, _ name: String) -> String? { attr(e, name) as? String }
func children(_ e: AXUIElement) -> [AXUIElement] { (attr(e, kAXChildrenAttribute) as? [AXUIElement]) ?? [] }
func frame(_ e: AXUIElement) -> CGRect {
    var p = CGPoint.zero, s = CGSize.zero
    if let v = attr(e, kAXPositionAttribute) { AXValueGetValue(v as! AXValue, .cgPoint, &p) }
    if let v = attr(e, kAXSizeAttribute) { AXValueGetValue(v as! AXValue, .cgSize, &s) }
    return CGRect(origin: p, size: s)
}
func label(_ e: AXUIElement) -> String {
    for name in [kAXTitleAttribute, kAXDescriptionAttribute, kAXValueAttribute] {
        if let s = string(e, name), !s.isEmpty { return s }
    }
    // A Form row's control is titled by its row label (what VoiceOver reads).
    if let title = attr(e, kAXTitleUIElementAttribute), CFGetTypeID(title) == AXUIElementGetTypeID() {
        return string(title as! AXUIElement, kAXValueAttribute) ?? ""
    }
    return ""
}
func all(_ e: AXUIElement, depth: Int = 0, where match: (AXUIElement) -> Bool) -> [AXUIElement] {
    guard depth < 40 else { return [] }
    var out = match(e) ? [e] : []
    for c in children(e) { out += all(c, depth: depth + 1, where: match) }
    return out
}
func role(_ e: AXUIElement) -> String { string(e, kAXRoleAttribute) ?? "" }
func subrole(_ e: AXUIElement) -> String { string(e, kAXSubroleAttribute) ?? "" }

/// The Settings window: the standard window holding the sidebar outline.
func settingsWindow() -> AXUIElement? {
    let windows = (attr(app, kAXWindowsAttribute) as? [AXUIElement]) ?? []
    return windows.first { role($0) == "AXWindow" && subrole($0) == "AXStandardWindow"
        && !all($0, where: { role($0) == "AXOutline" }).isEmpty }
}

func setFrame(_ window: AXUIElement, origin: CGPoint? = nil, size: CGSize? = nil) {
    if var o = origin { AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, AXValueCreate(.cgPoint, &o)!) }
    if var s = size { AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, AXValueCreate(.cgSize, &s)!) }
    if var o = origin { AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, AXValueCreate(.cgPoint, &o)!) }
    RunLoop.main.run(until: Date().addingTimeInterval(0.6))
}

func wait(_ seconds: Double) { RunLoop.main.run(until: Date().addingTimeInterval(seconds)) }

var window: AXUIElement?
for _ in 0..<75 where window == nil {
    window = settingsWindow()
    if window == nil { wait(0.2) }
}
guard let window else { print("FAIL no Settings window for pid \(pid)"); exit(1) }

// MARK: Checks

var failures: [String] = []
var rows: [String] = []
func record(_ display: String, _ page: String, _ metric: String, expected: String, got: String, ok: Bool) {
    rows.append("\(display) | \(page) | \(metric) | \(expected) | \(got) | \(ok ? "ok" : "FAIL")")
    if !ok { failures.append("\(display) \(page) \(metric): expected \(expected), got \(got)") }
}
func fmt(_ v: CGFloat) -> String { v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v) }
func fmt(_ r: CGRect) -> String { "\(fmt(r.minX)),\(fmt(r.minY)) \(fmt(r.width))×\(fmt(r.height))" }
func near(_ a: CGFloat, _ b: CGFloat, _ tolerance: CGFloat = 1) -> Bool { abs(a - b) <= tolerance }
func check(_ d: String, _ p: String, _ metric: String, _ got: CGFloat, _ expected: CGFloat, tolerance: CGFloat = 1) {
    record(d, p, metric, expected: fmt(expected), got: fmt(got), ok: near(got, expected, tolerance))
}
func check(_ d: String, _ p: String, _ metric: String, _ got: CGRect?, _ expected: CGRect) {
    guard let got else { record(d, p, metric, expected: fmt(expected), got: "missing", ok: false); return }
    let ok = near(got.minX, expected.minX) && near(got.minY, expected.minY)
        && near(got.width, expected.width) && near(got.height, expected.height)
    record(d, p, metric, expected: fmt(expected), got: fmt(got), ok: ok)
}

/// The window's number for `screencapture -l`.
func windowNumber(_ bounds: CGRect) -> Int? {
    let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
    for w in list where (w[kCGWindowOwnerPID as String] as? pid_t) == pid {
        guard let b = w[kCGWindowBounds as String] as? [String: CGFloat],
              let n = w[kCGWindowNumber as String] as? Int else { continue }
        if near(b["X"] ?? 0, bounds.minX) && near(b["Y"] ?? 0, bounds.minY) && near(b["Width"] ?? 0, bounds.width) { return n }
    }
    return nil
}

func screenshot(_ name: String, _ bounds: CGRect) -> NSBitmapImageRep? {
    guard let n = windowNumber(bounds) else { return nil }
    let url = outDir.appendingPathComponent("\(name).png")
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    task.arguments = ["-o", "-x", "-l", String(n), url.path]
    try? task.run()
    task.waitUntilExit()
    return (try? Data(contentsOf: url)).flatMap(NSBitmapImageRep.init(data:))
}

/// First x (pt) in `xs` where the band `ys` has a pixel far from the color at `xs`'s
/// start: where a sidebar label's text begins.
func inkStart(_ rep: NSBitmapImageRep, width: CGFloat, xs: ClosedRange<CGFloat>, ys: ClosedRange<CGFloat>) -> CGFloat? {
    let scale = CGFloat(rep.pixelsWide) / width
    func px(_ x: Int, _ y: Int) -> [Int] { var p = [Int](repeating: 0, count: 4); rep.getPixel(&p, atX: x, y: y); return p }
    let y0 = Int(ys.lowerBound * scale), y1 = Int(ys.upperBound * scale)
    let background = px(Int(xs.lowerBound * scale), (y0 + y1) / 2)
    for x in Int(xs.lowerBound * scale)...Int(xs.upperBound * scale) {
        for y in y0...y1 {
            let p = px(x, y)
            if (0..<3).map({ abs(p[$0] - background[$0]) }).max()! > 60 { return CGFloat(x) / scale }
        }
    }
    return nil
}

let sections = ["typing", "smart", "apps", "updates"]
let sidebarWidth: CGFloat = 232, toolbarHeight: CGFloat = 52, formMargin: CGFloat = 20
let topMargin: CGFloat = 20   // SwiftUI's grouped Form; System Settings: 12 (kept on purpose)
let size = CGSize(width: 740, height: 560)

/// One pass on one display.
func measure(display: String) {
    for (index, page) in sections.enumerated() {
        guard let outline = all(window, where: { role($0) == "AXOutline" }).first else {
            record(display, page, "sidebar", expected: "outline", got: "missing", ok: false); continue
        }
        let sidebarRows = (attr(outline, kAXRowsAttribute) as? [AXUIElement]) ?? []
        guard sidebarRows.count == sections.count else {
            record(display, page, "sidebar rows", expected: "\(sections.count)", got: "\(sidebarRows.count)", ok: false); continue
        }
        AXUIElementSetAttributeValue(outline, kAXSelectedRowsAttribute as CFString, [sidebarRows[index]] as CFArray)
        wait(1.0)
        let w = frame(window)
        func rel(_ r: CGRect) -> CGRect { r.offsetBy(dx: -w.minX, dy: -w.minY) }

        check(display, page, "window", CGRect(origin: .zero, size: w.size), CGRect(origin: .zero, size: size))
        let toolbar = all(window, where: { role($0) == "AXToolbar" }).first.map { rel(frame($0)) }
        check(display, page, "toolbar", toolbar, CGRect(x: 0, y: 0, width: w.width, height: toolbarHeight))
        let close = all(window, where: { subrole($0) == "AXCloseButton" }).first.map { rel(frame($0)) }
        check(display, page, "close button", close, CGRect(x: 18, y: 18, width: 16, height: 16))
        let heading = all(window, where: { role($0) == "AXToolbar" }).first
            .flatMap { all($0, where: { role($0) == "AXHeading" }).first }.map { rel(frame($0)) }
        if let heading {
            check(display, page, "title x", heading.minX, sidebarWidth + formMargin)
            check(display, page, "title center y", heading.midY, toolbarHeight / 2)
        } else {
            record(display, page, "title", expected: "toolbar heading", got: "missing", ok: false)
        }

        // Sidebar: search field, rows, icon tile.
        let search = all(window, where: { subrole($0) == "AXSearchField" }).map { rel(frame($0)) }
        check(display, page, "sidebar search", search.first { $0.minX < sidebarWidth }, CGRect(x: 10, y: 61, width: 212, height: 28))
        for (i, row) in sidebarRows.enumerated() {
            let cell = children(row).first.map { rel(frame($0)) }
            check(display, page, "sidebar row \(i)", cell, CGRect(x: 10, y: 98 + 32 * CGFloat(i), width: 212, height: 32))
            if i == 0, let text = all(row, where: { role($0) == "AXStaticText" }).first.map({ rel(frame($0)) }) {
                check(display, page, "sidebar icon x", text.minX, 19)
                check(display, page, "sidebar icon height", text.height, 20)
            }
        }

        // Detail: cards and section headers in the Form's scroll area.
        guard let area = all(window, where: { role($0) == "AXScrollArea" && rel(frame($0)).minX >= sidebarWidth - 1 }).first else {
            record(display, page, "form", expected: "scroll area", got: "missing", ok: false); continue
        }
        let column = rel(frame(area))
        let items = children(area).map { (role($0), rel(frame($0)), $0) }
            .filter { $0.0 == "AXGroup" || $0.0 == "AXHeading" || $0.0 == "AXStaticText" }
        if let first = items.first {
            check(display, page, "first item y", first.1.minY, toolbarHeight + topMargin)
        }
        let cards = items.filter { $0.0 == "AXGroup" }
        if let card = cards.first {
            check(display, page, "first card", card.1, CGRect(x: column.minX + formMargin, y: card.1.minY,
                                                              width: column.width - 2 * formMargin, height: card.1.height))
            if bannerRun, page == "typing" {
                let hasBanner = !all(card.2, where: { role($0) == "AXButton" && ["Bật lại", "Mở Cài đặt Bàn phím…"].contains(label($0)) }).isEmpty
                record(display, page, "banner first", expected: "Bật lại in first card", got: hasBanner ? "yes" : "no", ok: hasBanner)
            }
        }
        for (i, item) in items.enumerated() where item.0 == "AXHeading" {
            check(display, page, "header \"\(label(item.2))\" x", item.1.minX, column.minX + formMargin + 10)
            if i + 1 < items.count, items[i + 1].0 == "AXGroup" {
                check(display, page, "header \"\(label(item.2))\" → card", items[i + 1].1.minY - item.1.maxY, 10)
            }
            if i > 0, items[i - 1].0 == "AXGroup" {
                check(display, page, "card → header \"\(label(item.2))\"", item.1.minY - items[i - 1].1.maxY, 30)
            }
        }

        // Controls inside the cards (visible part of the column only).
        let visible = column.insetBy(dx: 0, dy: 0)
        for card in cards where visible.intersects(card.1) {
            for e in all(card.2, where: { _ in true }) {
                let r = rel(frame(e))
                guard visible.contains(r) else { continue }
                switch (role(e), subrole(e)) {
                case ("AXCheckBox", "AXSwitch"):
                    check(display, page, "switch \"\(label(e).prefix(24))\"", r, CGRect(x: r.minX, y: r.minY, width: 36, height: 16))
                case ("AXButton", _) where label(e) == "Nâng cao":
                    // The "Nâng cao" disclosure row: a plain button with a chevron (D9),
                    // as tall as its text, not a bezel button.
                    break
                case ("AXButton", _), ("AXPopUpButton", _), ("AXRadioGroup", _):
                    check(display, page, "\(role(e).dropFirst(2)) \"\(label(e).prefix(24))\" height", r.height, 24)
                default: break
                }
            }
        }

        // Apps: the toolbar's "+" and search field, right of the title.
        if page == "apps" {
            let items = all(window, where: { role($0) == "AXToolbar" }).first.map { children($0) } ?? []
            let add = items.first { role($0) == "AXButton" && label($0) == "Thêm ứng dụng" }.map { rel(frame($0)) }
            let field = search.first { $0.minX >= sidebarWidth }
            let ok = add != nil && field != nil && (heading.map { add!.minX > $0.maxX } ?? false)
                && add!.maxX <= field!.minX && field!.maxX <= w.width
            record(display, page, "toolbar + and search", expected: "title < + < search ≤ edge",
                   got: "\(add.map(fmt) ?? "no +") / \(field.map(fmt) ?? "no search")", ok: ok)
        }

        // Pixels: where the text of an unselected sidebar row begins.
        if let rep = screenshot("\(page)-\(display)", w) {
            let other = index == 1 ? 2 : 1
            let y = 98 + 32 * CGFloat(other)
            if let x = inkStart(rep, width: w.width, xs: 40...70, ys: (y + 9)...(y + 23)) {
                check(display, page, "sidebar text x", x, 46)
            } else {
                record(display, page, "sidebar text x", expected: "46", got: "no ink", ok: false)
            }
        } else {
            record(display, page, "screenshot", expected: "captured", got: "failed", ok: false)
        }
        if bannerRun { break }
    }
}

// One pass per display scale: the user has a Retina and a 1x display.
let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
var seenScales = Set<CGFloat>()
for screen in NSScreen.screens where seenScales.insert(screen.backingScaleFactor).inserted {
    let display = "\(fmt(screen.backingScaleFactor))x"
    let visible = screen.visibleFrame
    let origin = CGPoint(x: visible.minX + 40, y: primaryHeight - visible.maxY + 40)
    setFrame(window, origin: origin, size: size)
    measure(display: display)
}

// Window limits.
if !bannerRun {
    setFrame(window, size: CGSize(width: 1400, height: 700))
    check("-", "-", "max window width", frame(window).width, 976)
    setFrame(window, size: CGSize(width: 600, height: 300))
    check("-", "-", "min window width", frame(window).width, 740)
    // The content's minimum (400) plus the 52 pt toolbar.
    check("-", "-", "min window height", frame(window).height, 452)
    setFrame(window, size: size)
}

print("display | page | metric | System Settings | Dấu | result")
rows.forEach { print($0) }
failures.forEach { print("FAIL", $0) }
print(failures.isEmpty ? "Real-window checks passed (\(rows.count))." : "\(failures.count) real-window check(s) failed.")
exit(failures.isEmpty ? 0 : 1)
