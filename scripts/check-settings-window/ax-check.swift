// Real-window check of the Settings window (docs/UI-CHECKS.md, "Cửa sổ thật").
//
// Usage: ax-check <pid> <output-dir> [--banner | --sheet-only]
//
// Reads the frames of the running app's Settings window through the Accessibility API
// (the launching terminal needs the Accessibility permission) and compares them with
// System Settings (Reference.swift, from docs/research/SYSTEM-SETTINGS-REFERENCE.md),
// within a tolerance. Unlike `Dau --capture-window`, nothing here runs inside the app: the window
// is the one the user gets. On every display (one pass per backing scale) the window
// is moved there at System Settings' size, each section is selected through the sidebar's
// accessibility (no clicks), measured and captured with `screencapture -l`
// (<section>-<scale>x.png). Then the window's size limits are tried and the window is
// put back at System Settings' size. `--banner`: the app runs with `--not-enabled`; also checks
// that the banner is the first card. Without `--banner`, each pass also opens the
// add-rule sheet ("+" on Ứng dụng, pressed through accessibility), measures it against
// System Settings' sheets, captures it empty and with a row selected, and closes it
// with Huỷ (nothing is added), and types a query no section matches into the sidebar
// search (system empty state, toolbar kept), then clears it. `--sheet-only`: only the sheet, on the first display
// (run.sh uses it for the appearance the system is not in). Exit status 0 only if
// every check passes.
//
// Every expected value (pt, origin at the window's top-left) is in Reference.swift,
// compiled together with this file by run.sh.
import AppKit

let args = CommandLine.arguments
guard args.count >= 3, let pid = pid_t(args[1]) else {
    print("usage: ax-check <pid> <output-dir> [--banner]"); exit(2)
}
let outDir = URL(fileURLWithPath: args[2], isDirectory: true)
let bannerRun = args.contains("--banner")
let sheetOnly = args.contains("--sheet-only")
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
func near(_ a: CGFloat, _ b: CGFloat, _ tolerance: CGFloat = Reference.tolerance) -> Bool { abs(a - b) <= tolerance }
func check(_ d: String, _ p: String, _ metric: String, _ got: CGFloat, _ expected: CGFloat, tolerance: CGFloat = Reference.tolerance) {
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
            if (0..<3).map({ abs(p[$0] - background[$0]) }).max()! > Reference.sidebarInkThreshold { return CGFloat(x) / scale }
        }
    }
    return nil
}

let sections = Reference.sections
let sidebarWidth = Reference.sidebarWidth, toolbarHeight = Reference.toolbarHeight, formMargin = Reference.formMargin
let size = Reference.windowSize

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
        check(display, page, "close button", close, Reference.closeFrame)
        let heading = all(window, where: { role($0) == "AXToolbar" }).first
            .flatMap { all($0, where: { role($0) == "AXHeading" }).first }.map { rel(frame($0)) }
        if let heading {
            check(display, page, "title x", heading.minX, Reference.titleX)
            check(display, page, "title center y", heading.midY, Reference.titleCenterY)
        } else {
            record(display, page, "title", expected: "toolbar heading", got: "missing", ok: false)
        }

        // Sidebar: search field, rows, icon tile.
        let search = all(window, where: { subrole($0) == "AXSearchField" }).map { rel(frame($0)) }
        check(display, page, "sidebar search", search.first { $0.minX < sidebarWidth }, Reference.sidebarSearchFrame)
        for (i, row) in sidebarRows.enumerated() {
            let cell = children(row).first.map { rel(frame($0)) }
            check(display, page, "sidebar row \(i)", cell, Reference.sidebarRowFrame(i))
            if i == 0, let text = all(row, where: { role($0) == "AXStaticText" }).first.map({ rel(frame($0)) }) {
                check(display, page, "sidebar icon x", text.minX, Reference.sidebarIconX)
                check(display, page, "sidebar icon height", text.height, Reference.sidebarIconSize)
            }
        }

        // Detail: cards and section headers in the Form's scroll area.
        guard let area = all(window, where: { role($0) == "AXScrollArea" && rel(frame($0)).minX >= sidebarWidth - Reference.tolerance }).first else {
            record(display, page, "form", expected: "scroll area", got: "missing", ok: false); continue
        }
        let column = rel(frame(area))
        let items = children(area).map { (role($0), rel(frame($0)), $0) }
            .filter { $0.0 == "AXGroup" || $0.0 == "AXHeading" || $0.0 == "AXStaticText" }
        if let first = items.first {
            check(display, page, "first item y", first.1.minY, Reference.formFirstItemY)
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
            check(display, page, "header \"\(label(item.2))\" x", item.1.minX, column.minX + formMargin + Reference.cardInset)
            if i + 1 < items.count, items[i + 1].0 == "AXGroup" {
                check(display, page, "header \"\(label(item.2))\" → card", items[i + 1].1.minY - item.1.maxY, Reference.headerToCard)
            }
            if i > 0, items[i - 1].0 == "AXGroup" {
                check(display, page, "card → header \"\(label(item.2))\"", item.1.minY - items[i - 1].1.maxY, Reference.cardToHeader)
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
                    check(display, page, "switch \"\(label(e).prefix(24))\"", r, CGRect(origin: r.origin, size: Reference.switchSize))
                case ("AXButton", _) where label(e) == "Nâng cao":
                    // The "Nâng cao" disclosure row: a plain button with a chevron (D9),
                    // as tall as its text, not a bezel button.
                    break
                case ("AXButton", _), ("AXPopUpButton", _), ("AXRadioGroup", _):
                    check(display, page, "\(role(e).dropFirst(2)) \"\(label(e).prefix(24))\" height", r.height, Reference.controlHeight)
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
            let y = Reference.sidebarRowFrame(other).minY
            let band = Reference.sidebarTextProbeY
            if let x = inkStart(rep, width: w.width, xs: Reference.sidebarTextProbeX, ys: (y + band.lowerBound)...(y + band.upperBound)) {
                check(display, page, "sidebar text x", x, Reference.sidebarTextX)
            } else {
                record(display, page, "sidebar text x", expected: fmt(Reference.sidebarTextX), got: "no ink", ok: false)
            }
        } else {
            record(display, page, "screenshot", expected: "captured", got: "failed", ok: false)
        }
        if bannerRun { break }
    }
}

// MARK: Sidebar search without a match

/// A query no section matches: the sidebar shows the system's empty state (text in the
/// sidebar, no rows), the open page and its toolbar stay; clearing the query
/// brings the four rows back.
func measureSidebarSearch(display: String) {
    let page = "sidebar-search"
    guard let field = all(window, where: { subrole($0) == "AXSearchField" }).first(where: {
        frame($0).minX - frame(window).minX < sidebarWidth }),
          let outline = all(window, where: { role($0) == "AXOutline" }).first else {
        record(display, page, "search field", expected: "sidebar search", got: "missing", ok: false); return
    }
    // SwiftUI reads the sidebar field's value only while it has focus (measured: a
    // value set without focus shows in the field but filters nothing).
    AXUIElementSetAttributeValue(field, kAXFocusedAttribute as CFString, kCFBooleanTrue)
    AXUIElementSetAttributeValue(field, kAXValueAttribute as CFString, "zzzz-no-such-setting" as CFString)
    wait(1.0)
    let w = frame(window)
    func rel(_ r: CGRect) -> CGRect { r.offsetBy(dx: -w.minX, dy: -w.minY) }
    let rows = (attr(outline, kAXRowsAttribute) as? [AXUIElement]) ?? []
    check(display, page, "rows without a match", CGFloat(rows.count), 0, tolerance: Reference.exact)
    let texts = all(window, where: { role($0) == "AXStaticText" }).map { (label($0), rel(frame($0))) }
        .filter { $0.1.maxX <= sidebarWidth && $0.1.minY > Reference.sidebarFirstRowY && $0.0.contains("zzzz-no-such-setting") }
    record(display, page, "empty state", expected: "text naming the query in the sidebar", got: texts.first?.0 ?? "none", ok: !texts.isEmpty)
    let toolbar = all(window, where: { role($0) == "AXToolbar" }).first.map { rel(frame($0)) }
    check(display, page, "toolbar height", toolbar?.height ?? 0, toolbarHeight)
    if screenshot("sidebar-search-empty-\(display)", w) == nil {
        record(display, page, "screenshot", expected: "captured", got: "failed", ok: false)
    }
    AXUIElementSetAttributeValue(field, kAXValueAttribute as CFString, "" as CFString)
    wait(1.0)
    let back = (attr(outline, kAXRowsAttribute) as? [AXUIElement]) ?? []
    check(display, page, "rows after clearing", CGFloat(back.count), CGFloat(sections.count), tolerance: Reference.exact)
}

// MARK: Add-rule sheet

/// The sheet attached to the Settings window, if any.
func attachedSheet() -> AXUIElement? { children(window).first { role($0) == "AXSheet" } }

/// Opens the add-rule sheet from the Ứng dụng page through accessibility (no clicks),
/// checks it, captures it empty and with a row selected, and closes it with Huỷ.
func measureSheet(display: String) {
    let page = "add-sheet"
    guard let outline = all(window, where: { role($0) == "AXOutline" }).first,
          let sidebarRows = attr(outline, kAXRowsAttribute) as? [AXUIElement], sidebarRows.count == sections.count else {
        record(display, page, "sidebar", expected: "outline", got: "missing", ok: false); return
    }
    AXUIElementSetAttributeValue(outline, kAXSelectedRowsAttribute as CFString, [sidebarRows[2]] as CFArray)
    wait(1.0)
    let toolbarItems = all(window, where: { role($0) == "AXToolbar" }).first.map { children($0) } ?? []
    guard let add = toolbarItems.first(where: { role($0) == "AXButton" && label($0) == "Thêm ứng dụng" }) else {
        record(display, page, "toolbar +", expected: "button", got: "missing", ok: false); return
    }
    AXUIElementPerformAction(add, kAXPressAction as CFString)
    var found: AXUIElement?
    for _ in 0..<25 where found == nil {
        found = attachedSheet()
        if found == nil { wait(0.2) }
    }
    guard let sheet = found else {
        record(display, page, "sheet", expected: "opened by +", got: "missing", ok: false); return
    }
    // Screenshots of an active window, as the user sees it.
    AXUIElementSetAttributeValue(app, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
    let w = frame(window)
    let s = frame(sheet)
    func rel(_ r: CGRect) -> CGRect { r.offsetBy(dx: -s.minX, dy: -s.minY) }
    func list() -> AXUIElement? { all(sheet, where: { role($0) == "AXOutline" }).first }
    func listRows() -> [AXUIElement] { list().flatMap { attr($0, kAXRowsAttribute) as? [AXUIElement] } ?? [] }
    // The app list is read off the main thread: wait for it.
    for _ in 0..<50 where listRows().isEmpty { wait(0.2) }
    wait(0.5)

    check(display, page, "sheet width", s.width, Reference.sheetWidth)

    // The system search field of the sheet, at its top trailing edge.
    let searchField = all(sheet, where: { subrole($0) == "AXSearchField" }).first
    if let field = searchField {
        let r = rel(frame(field))
        check(display, page, "search height", r.height, Reference.sheetSearchHeight)
        check(display, page, "search top", r.minY, Reference.sheetMargin)
        check(display, page, "search right margin", s.width - r.maxX, Reference.sheetMargin)
        let prompt = string(field, "AXPlaceholderValue") ?? label(field)
        record(display, page, "search prompt", expected: "Tìm trong Ứng dụng", got: prompt, ok: prompt == "Tìm trong Ứng dụng")
    } else {
        record(display, page, "search", expected: "search field", got: "missing", ok: false)
    }

    // The grouped Form: header, the list card, the "Khi đang gõ" card.
    guard let area = all(sheet, where: { role($0) == "AXScrollArea" && near(frame($0).width, s.width) }).first else {
        record(display, page, "form", expected: "scroll area", got: "missing", ok: false); return
    }
    let form = rel(frame(area))
    let items = children(area).map { (role($0), rel(frame($0)), $0) }
        .filter { ["AXGroup", "AXHeading", "AXStaticText", "AXScrollArea"].contains($0.0) }
    if let first = items.first {
        check(display, page, "first item y", first.1.minY - form.minY, Reference.sheetMargin)
    }
    let cards = items.filter { $0.0 == "AXGroup" || $0.0 == "AXScrollArea" }
    for (i, card) in cards.enumerated() {
        check(display, page, "card \(i)", card.1, CGRect(x: Reference.sheetMargin, y: card.1.minY, width: s.width - 2 * Reference.sheetMargin, height: card.1.height))
        if i > 0 { check(display, page, "card \(i - 1) → card \(i)", card.1.minY - cards[i - 1].1.maxY, Reference.cardGap) }
    }
    for (i, item) in items.enumerated() where item.0 == "AXHeading" {
        record(display, page, "header", expected: "Thêm quy tắc cho ứng dụng", got: label(item.2), ok: label(item.2) == "Thêm quy tắc cho ứng dụng")
        check(display, page, "header x", item.1.minX, Reference.sheetMargin + Reference.cardInset)
        if i + 1 < items.count { check(display, page, "header → card", items[i + 1].1.minY - item.1.maxY, Reference.headerToCard) }
    }
    if let list = list(), let card = cards.first {
        let r = rel(frame(list))
        record(display, page, "list fills card", expected: fmt(card.1), got: fmt(r),
               ok: near(r.minX, card.1.minX) && near(r.width, card.1.width) && near(r.minY, card.1.minY) && near(r.height, card.1.height))
        record(display, page, "list label", expected: "Ứng dụng", got: label(list), ok: label(list) == "Ứng dụng")
    } else {
        record(display, page, "list", expected: "app list", got: "missing", ok: false)
    }
    let segmented = all(sheet, where: { role($0) == "AXRadioGroup" }).first
    if let segmented {
        check(display, page, "segmented \"\(label(segmented))\" height", rel(frame(segmented)).height, Reference.controlHeight)
        record(display, page, "segmented label", expected: "Khi đang gõ", got: label(segmented), ok: label(segmented) == "Khi đang gõ")
    } else {
        record(display, page, "segmented", expected: "Khi đang gõ", got: "missing", ok: false)
    }

    // The button bar.
    func button(_ title: String) -> AXUIElement? { all(sheet, where: { role($0) == "AXButton" && label($0) == title }).first }
    func enabled(_ e: AXUIElement?) -> Bool { e.flatMap { attr($0, kAXEnabledAttribute) as? Bool } ?? false }
    let cancel = button("Huỷ"), confirm = button("Thêm"), other = button("Chọn ứng dụng khác…")
    if let cancel, let confirm, let other {
        let c = rel(frame(cancel)), a = rel(frame(confirm)), o = rel(frame(other))
        let minWidth = Reference.sheetButtonMinWidth
        check(display, page, "Thêm height", a.height, Reference.sheetButtonHeight)
        record(display, page, "Thêm width", expected: "≥ \(fmt(minWidth))", got: fmt(a.width), ok: a.width >= minWidth - Reference.tolerance)
        check(display, page, "Thêm right margin", s.width - a.maxX, Reference.sheetMargin)
        check(display, page, "Thêm bottom margin", s.height - a.maxY, Reference.sheetMargin)
        check(display, page, "Form → buttons", a.minY - form.maxY, Reference.sheetFormToButtons)
        check(display, page, "Huỷ height", c.height, Reference.sheetButtonHeight)
        record(display, page, "Huỷ width", expected: "≥ \(fmt(minWidth))", got: fmt(c.width), ok: c.width >= minWidth - Reference.tolerance)
        record(display, page, "Huỷ before Thêm", expected: "same line, left of Thêm", got: "\(fmt(c)) / \(fmt(a))",
               ok: near(c.minY, a.minY) && c.maxX < a.minX)
        check(display, page, "Chọn ứng dụng khác… x", o.minX, Reference.sheetMargin)
        check(display, page, "Chọn ứng dụng khác… y", o.minY, a.minY)
        record(display, page, "Thêm without selection", expected: "disabled", got: enabled(confirm) ? "enabled" : "disabled", ok: !enabled(confirm))
    } else {
        record(display, page, "buttons", expected: "Chọn ứng dụng khác… / Huỷ / Thêm",
               got: "\(other == nil ? "-" : "ok") / \(cancel == nil ? "-" : "ok") / \(confirm == nil ? "-" : "ok")", ok: false)
    }
    if screenshot("apps-add-sheet-\(display)", w) == nil {
        record(display, page, "screenshot", expected: "captured", got: "failed", ok: false)
    }

    // The search field filters the list (value set through accessibility, then cleared).
    let total = listRows().count
    if let field = searchField, let firstRow = listRows().first,
       let name = all(firstRow, where: { role($0) == "AXStaticText" }).first.map(label) {
        AXUIElementSetAttributeValue(field, kAXValueAttribute as CFString, name as CFString)
        wait(0.8)
        let filtered = listRows().count
        record(display, page, "search filters", expected: "1…\(total - 1) rows for \"\(name)\"", got: "\(filtered)",
               ok: filtered >= 1 && filtered < total)
        AXUIElementSetAttributeValue(field, kAXValueAttribute as CFString, "" as CFString)
        wait(0.8)
        check(display, page, "search cleared rows", CGFloat(listRows().count), CGFloat(total), tolerance: Reference.exact)
    }

    // A selection enables Thêm.
    if let list = list(), let row = listRows().first {
        AXUIElementSetAttributeValue(list, kAXSelectedRowsAttribute as CFString, [row] as CFArray)
        wait(0.8)
        record(display, page, "Thêm with selection", expected: "enabled", got: enabled(button("Thêm")) ? "enabled" : "disabled",
               ok: enabled(button("Thêm")))
        if screenshot("apps-add-sheet-selected-\(display)", w) == nil {
            record(display, page, "screenshot selected", expected: "captured", got: "failed", ok: false)
        }
        // A query that hides the selected app clears the selection: Thêm turns off and
        // stays off once the query is cleared (Return cannot add an app off screen).
        if let field = searchField {
            AXUIElementSetAttributeValue(field, kAXValueAttribute as CFString, "zzzz-no-such-app" as CFString)
            wait(0.8)
            record(display, page, "Thêm after search hides selection", expected: "disabled",
                   got: enabled(button("Thêm")) ? "enabled" : "disabled", ok: !enabled(button("Thêm")))
            AXUIElementSetAttributeValue(field, kAXValueAttribute as CFString, "" as CFString)
            wait(0.8)
            record(display, page, "Thêm after search cleared", expected: "disabled",
                   got: enabled(button("Thêm")) ? "enabled" : "disabled", ok: !enabled(button("Thêm")))
        }
    }

    // Huỷ closes the sheet; nothing is added.
    if let cancel = button("Huỷ") { AXUIElementPerformAction(cancel, kAXPressAction as CFString) }
    var closed = false
    for _ in 0..<25 where !closed {
        closed = attachedSheet() == nil
        if !closed { wait(0.2) }
    }
    record(display, page, "Huỷ closes", expected: "closed", got: closed ? "closed" : "open", ok: closed)
}

// One pass per display scale: the user has a Retina and a 1x display.
let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
var seenScales = Set<CGFloat>()
for screen in NSScreen.screens where seenScales.insert(screen.backingScaleFactor).inserted {
    let display = "\(fmt(screen.backingScaleFactor))x"
    let visible = screen.visibleFrame
    let origin = CGPoint(x: visible.minX + 40, y: primaryHeight - visible.maxY + 40)
    setFrame(window, origin: origin, size: size)
    if !sheetOnly { measure(display: display) }
    if !sheetOnly && !bannerRun { measureSidebarSearch(display: display) }
    if !bannerRun { measureSheet(display: display) }
    if sheetOnly { break }
}

// Window limits.
if !bannerRun && !sheetOnly {
    setFrame(window, size: Reference.probeLargeSize)
    check("-", "-", "max window width", frame(window).width, Reference.maxWindowWidth)
    setFrame(window, size: Reference.probeSmallSize)
    check("-", "-", "min window width", frame(window).width, Reference.minWindowWidth)
    // The content's minimum plus the toolbar.
    check("-", "-", "min window height", frame(window).height, Reference.minWindowHeight)
    setFrame(window, size: size)
}

print("display | page | metric | System Settings | Dấu | result")
rows.forEach { print($0) }
failures.forEach { print("FAIL", $0) }
print(failures.isEmpty ? "Real-window checks passed (\(rows.count))." : "\(failures.count) real-window check(s) failed.")
exit(failures.isEmpty ? 0 : 1)
