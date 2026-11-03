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
// every check passes. A check the checker cannot run because it could not find or wait for an
// element is a HARNESS problem, reported and counted apart from a UI FAIL (measured value
// against Reference); the exit status is non-zero for either. Every row's display column is
// "<scale>x pass <n>": a failure that only shows on pass 1 is a cold-app failure.
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
    harnessAbort("Accessibility permission", expected: "granted to this terminal",
                 got: "missing (System Settings › Privacy & Security › Accessibility)")
}

nonisolated(unsafe) let app = AXUIElementCreateApplication(pid)
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

/// A problem before any row exists (no permission, no window): the same HARNESS wording and exit status.
func harnessAbort(_ metric: String, expected: String, got: String) -> Never {
    print("HARNESS - - \(metric): \(expected) / \(got)")
    print("1 harness problem(s): the checker could not reach an element; not a UI result.")
    exit(1)
}

// Declared here, not with the checks: the window lookup below needs them.
let sections = Reference.sections
let sidebarWidth = Reference.sidebarWidth, toolbarHeight = Reference.toolbarHeight, formMargin = Reference.formMargin
let size = Reference.windowSize

/// Lookups by identity, not by order: an element is picked by a label it is known to carry,
/// or (for elements with no stable label) by where it lies, never by its place in the
/// children list. Each lookup says which.
func rowCount(_ e: AXUIElement) -> Int { (attr(e, kAXRowsAttribute) as? [AXUIElement])?.count ?? 0 }

/// Outlines in the window's sidebar column (minX within the sidebar width from the window's
/// left), sheets left out: the add-rule sheet has outlines of its own and can be centered
/// over the column. The sidebar outline has no label of its own, hence geometry.
func sidebarOutlines(_ window: AXUIElement) -> [AXUIElement] {
    let left = frame(window).minX
    return children(window).filter { role($0) != "AXSheet" }
        .flatMap { all($0, where: { role($0) == "AXOutline" }) }
        .filter { let x = frame($0).minX - left; return x >= -Reference.tolerance && x < sidebarWidth }
}
/// The sidebar outline: in the sidebar column, with one row per section.
func sidebarOutline(_ window: AXUIElement) -> AXUIElement? { sidebarOutlines(window).first { rowCount($0) == sections.count } }

/// The sidebar's search field: the search field in the sidebar column (no stable label known).
func sidebarSearchField(_ window: AXUIElement) -> AXUIElement? {
    let left = frame(window).minX
    return all(window, where: { subrole($0) == "AXSearchField" })
        .first { let x = frame($0).minX - left; return x >= -Reference.tolerance && x < sidebarWidth }
}

/// The window's toolbar: toolbars have no label, so the widest one in the window's upper half
/// (the window can hold a second, narrower one); the highest wins a tie.
func toolbar(of window: AXUIElement) -> AXUIElement? {
    let w = frame(window)
    return all(window, where: { role($0) == "AXToolbar" })
        .filter { frame($0).midY - w.minY < w.height / 2 }
        .max { a, b in
            let fa = frame(a), fb = frame(b)
            return fa.width != fb.width ? fa.width < fb.width : fa.minY > fb.minY
        }
}

/// The element carrying `wanted`; if none does, the topmost candidate, so that a wrong label
/// still shows as a UI FAIL at the label check, not as a missing element.
func intended(_ candidates: [AXUIElement], text wanted: String, _ text: (AXUIElement) -> String) -> AXUIElement? {
    candidates.first { text($0) == wanted } ?? candidates.min { frame($0).minY < frame($1).minY }
}

/// The Settings window: the standard window holding an outline in its sidebar column (its
/// title is the page's, so it is no identity; the sidebar is).
func settingsWindow() -> AXUIElement? {
    let windows = (attr(app, kAXWindowsAttribute) as? [AXUIElement]) ?? []
    return windows.first { role($0) == "AXWindow" && subrole($0) == "AXStandardWindow"
        && !sidebarOutlines($0).isEmpty }
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
guard let window else {
    // Say what the app does show, so a missing window can be told apart from a slow one
    // (03/11/2026: once, the sheet-only run found no Settings window in 15 s).
    let shown = ((attr(app, kAXWindowsAttribute) as? [AXUIElement]) ?? [])
        .map { "\(subrole($0)) \"\(string($0, kAXTitleAttribute) ?? "")\" \(fmt(frame($0)))" }
    harnessAbort("Settings window", expected: "window for pid \(pid) within 15 s",
                 got: "none; windows: \(shown.isEmpty ? "none" : shown.joined(separator: "; "))")
}

// MARK: Checks

nonisolated(unsafe) var failures: [String] = []
nonisolated(unsafe) var harnessProblems: [String] = []
nonisolated(unsafe) var rows: [String] = []
/// File names of the captures stay "<scale>x" (the display label carries the pass too).
nonisolated(unsafe) var fileTag = ""
/// `harness`: the checker could not reach the element (not a UI result; `ok` is ignored).
/// `skip`: the check does not apply (counted as passed, marked "skip").
func record(_ display: String, _ page: String, _ metric: String, expected: String, got: String, ok: Bool,
            harness: Bool = false, skip: Bool = false) {
    rows.append("\(display) | \(page) | \(metric) | \(expected) | \(got) | \(harness ? "HARNESS" : skip ? "skip" : ok ? "ok" : "FAIL")")
    if harness { harnessProblems.append("\(display) \(page) \(metric): \(expected) / \(got)") }
    else if !ok && !skip { failures.append("\(display) \(page) \(metric): expected \(expected), got \(got)") }
}
func harnessProblem(_ d: String, _ p: String, _ metric: String, expected: String, got: String = "missing") {
    record(d, p, metric, expected: expected, got: got, ok: false, harness: true)
}
func fmt(_ v: CGFloat) -> String { v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v) }
func fmt(_ r: CGRect) -> String { "\(fmt(r.minX)),\(fmt(r.minY)) \(fmt(r.width))×\(fmt(r.height))" }
func near(_ a: CGFloat, _ b: CGFloat, _ tolerance: CGFloat = Reference.tolerance) -> Bool { abs(a - b) <= tolerance }
func check(_ d: String, _ p: String, _ metric: String, _ got: CGFloat, _ expected: CGFloat, tolerance: CGFloat = Reference.tolerance) {
    record(d, p, metric, expected: fmt(expected), got: fmt(got), ok: near(got, expected, tolerance))
}
func check(_ d: String, _ p: String, _ metric: String, _ got: CGRect?, _ expected: CGRect) {
    guard let got else { harnessProblem(d, p, metric, expected: fmt(expected)); return }
    let ok = near(got.minX, expected.minX) && near(got.minY, expected.minY)
        && near(got.width, expected.width) && near(got.height, expected.height)
    record(d, p, metric, expected: fmt(expected), got: fmt(got), ok: ok)
}

/// The sidebar outline, waiting up to 3 s for its rows. Not found: a harness problem when no
/// outline lies in the sidebar column; a UI FAIL when one does but its row count is wrong.
func findSidebarOutline(_ display: String, _ page: String) -> AXUIElement? {
    let start = Date()
    var found = sidebarOutline(window)
    while found == nil && Date().timeIntervalSince(start) < 3 { wait(0.2); found = sidebarOutline(window) }
    if let found { return found }
    let candidates = sidebarOutlines(window).map { rowCount($0) }
    if candidates.isEmpty {
        harnessProblem(display, page, "sidebar", expected: "outline in the sidebar column")
    } else {
        record(display, page, "sidebar rows", expected: "\(sections.count)", got: candidates.map(String.init).joined(separator: ", "), ok: false)
    }
    return nil
}

/// The "+" in the toolbar, by its label.
func toolbarAddButton() -> AXUIElement? {
    all(window, where: { role($0) == "AXToolbar" }).flatMap { children($0) }
        .first { role($0) == "AXButton" && label($0) == "Thêm ứng dụng" }
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
    // The window can be briefly off the on-screen list (for example while another app
    // takes the front): look again a few times.
    var found = windowNumber(bounds)
    for _ in 0..<5 where found == nil {
        wait(0.4)
        found = windowNumber(bounds)
    }
    guard let n = found else { return nil }
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

/// One pass on one display.
func measure(display: String) {
    for (index, page) in sections.enumerated() {
        guard let outline = findSidebarOutline(display, page) else { continue }
        let sidebarRows = (attr(outline, kAXRowsAttribute) as? [AXUIElement]) ?? []
        AXUIElementSetAttributeValue(outline, kAXSelectedRowsAttribute as CFString, [sidebarRows[index]] as CFArray)
        wait(1.0)
        let w = frame(window)
        func rel(_ r: CGRect) -> CGRect { r.offsetBy(dx: -w.minX, dy: -w.minY) }

        check(display, page, "window", CGRect(origin: .zero, size: w.size), CGRect(origin: .zero, size: size))
        let toolbarElement = toolbar(of: window)
        check(display, page, "toolbar", toolbarElement.map { rel(frame($0)) }, CGRect(x: 0, y: 0, width: w.width, height: toolbarHeight))
        // One close button per window (the sheet has none): the subrole is the identity.
        let close = all(window, where: { subrole($0) == "AXCloseButton" }).first.map { rel(frame($0)) }
        check(display, page, "close button", close, Reference.closeFrame)
        // The page title has no known label here (it is the page's): the toolbar heading in
        // the detail column, leftmost.
        let heading = toolbarElement
            .flatMap { all($0, where: { role($0) == "AXHeading" && rel(frame($0)).minX >= sidebarWidth - Reference.tolerance })
                .min { frame($0).minX < frame($1).minX } }.map { rel(frame($0)) }
        if let heading {
            check(display, page, "title x", heading.minX, Reference.titleX)
            check(display, page, "title center y", heading.midY, Reference.titleCenterY)
        } else {
            harnessProblem(display, page, "title", expected: "toolbar heading")
        }

        // Sidebar: search field, rows, icon tile.
        let search = all(window, where: { subrole($0) == "AXSearchField" }).map { rel(frame($0)) }
        check(display, page, "sidebar search", sidebarSearchField(window).map { rel(frame($0)) }, Reference.sidebarSearchFrame)
        for (i, row) in sidebarRows.enumerated() {
            // A sidebar row has a single cell.
            let cell = children(row).first.map { rel(frame($0)) }
            check(display, page, "sidebar row \(i)", cell, Reference.sidebarRowFrame(i))
            // The row's texts have no label to tell them apart: the leftmost is the icon tile.
            if i == 0, let text = all(row, where: { role($0) == "AXStaticText" }).min(by: { frame($0).minX < frame($1).minX }).map({ rel(frame($0)) }) {
                check(display, page, "sidebar icon x", text.minX, Reference.sidebarIconX)
                check(display, page, "sidebar icon height", text.height, Reference.sidebarIconSize)
            }
        }

        // Detail: cards and section headers in the Form's scroll area.
        // Scroll areas have no label: the largest one in the detail column (inner ones are smaller).
        guard let area = all(window, where: { role($0) == "AXScrollArea" && rel(frame($0)).minX >= sidebarWidth - Reference.tolerance })
            .max(by: { frame($0).width * frame($0).height < frame($1).width * frame($1).height }) else {
            harnessProblem(display, page, "form", expected: "scroll area"); continue
        }
        let column = rel(frame(area))
        // Top to bottom, whatever order the children come in.
        let items = children(area).map { (role($0), rel(frame($0)), $0) }
            .filter { $0.0 == "AXGroup" || $0.0 == "AXHeading" || $0.0 == "AXStaticText" }
            .sorted { $0.1.minY < $1.1.minY }
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
            let add = toolbarAddButton().map { rel(frame($0)) }   // by its label
            let field = search.first { $0.minX >= sidebarWidth }   // the toolbar's: right of the sidebar (no stable label known)
            let ok = add != nil && field != nil && (heading.map { add!.minX > $0.maxX } ?? false)
                && add!.maxX <= field!.minX && field!.maxX <= w.width
            record(display, page, "toolbar + and search", expected: "title < + < search ≤ edge",
                   got: "\(add.map(fmt) ?? "no +") / \(field.map(fmt) ?? "no search")", ok: ok,
                   harness: add == nil || field == nil || heading == nil)
        }

        // Pixels: where the text of an unselected sidebar row begins.
        if let rep = screenshot("\(page)-\(fileTag)", w) {
            let other = index == 1 ? 2 : 1
            let y = Reference.sidebarRowFrame(other).minY
            let band = Reference.sidebarTextProbeY
            if let x = inkStart(rep, width: w.width, xs: Reference.sidebarTextProbeX, ys: (y + band.lowerBound)...(y + band.upperBound)) {
                check(display, page, "sidebar text x", x, Reference.sidebarTextX)
            } else {
                record(display, page, "sidebar text x", expected: fmt(Reference.sidebarTextX), got: "no ink", ok: false)
            }
        } else {
            harnessProblem(display, page, "screenshot", expected: "captured", got: "failed")
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
    guard let field = sidebarSearchField(window) else {
        harnessProblem(display, page, "search field", expected: "sidebar search"); return
    }
    guard let outline = findSidebarOutline(display, page) else { return }
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
    if let bar = toolbar(of: window) {
        check(display, page, "toolbar height", frame(bar).height, toolbarHeight)
    } else {
        harnessProblem(display, page, "toolbar height", expected: fmt(toolbarHeight))
    }
    if screenshot("sidebar-search-empty-\(fileTag)", w) == nil {
        harnessProblem(display, page, "screenshot", expected: "captured", got: "failed")
    }
    AXUIElementSetAttributeValue(field, kAXValueAttribute as CFString, "" as CFString)
    wait(1.0)
    let back = (attr(outline, kAXRowsAttribute) as? [AXUIElement]) ?? []
    check(display, page, "rows after clearing", CGFloat(back.count), CGFloat(sections.count), tolerance: Reference.exact)
}

// MARK: Add-rule sheet

/// Distinct bundle IDs of the apps in the folders AddAppRuleSheet lists (AppListing.folders),
/// Dấu's own left out, as the sheet does.
func installedAppCount() -> Int {
    let folders = ["/Applications", "/Applications/Utilities", "/System/Applications", "/System/Applications/Utilities"]
    var ids = Set<String>()
    for folder in folders {
        for name in (try? FileManager.default.contentsOfDirectory(atPath: folder)) ?? [] where name.hasSuffix(".app") {
            if let id = Bundle(url: URL(fileURLWithPath: folder).appendingPathComponent(name))?.bundleIdentifier { ids.insert(id) }
        }
    }
    ids.remove("com.codefastlabs.dau")
    return ids.count
}

/// The sheet attached to the Settings window, if any. A window has at most one sheet, so
/// the role is the identity.
func attachedSheet() -> AXUIElement? { children(window).first { role($0) == "AXSheet" } }

/// Opens the add-rule sheet from the Ứng dụng page through accessibility (no clicks),
/// checks it, captures it empty and with a row selected, and closes it with Huỷ.
func measureSheet(display: String) {
    let page = "add-sheet"
    guard let outline = findSidebarOutline(display, page),
          let sidebarRows = attr(outline, kAXRowsAttribute) as? [AXUIElement] else { return }
    AXUIElementSetAttributeValue(outline, kAXSelectedRowsAttribute as CFString, [sidebarRows[2]] as CFArray)
    wait(1.0)
    guard let add = toolbarAddButton() else {
        harnessProblem(display, page, "toolbar +", expected: "button"); return
    }
    AXUIElementPerformAction(add, kAXPressAction as CFString)
    var found: AXUIElement?
    for _ in 0..<25 where found == nil {
        found = attachedSheet()
        if found == nil { wait(0.2) }
    }
    guard let sheet = found else {
        harnessProblem(display, page, "sheet", expected: "opened by +"); return
    }
    // Screenshots of an active window, as the user sees it.
    AXUIElementSetAttributeValue(app, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
    let w = frame(window)
    let s = frame(sheet)
    func rel(_ r: CGRect) -> CGRect { r.offsetBy(dx: -s.minX, dy: -s.minY) }
    // The app list by its accessibility label: the sheet's grouped Form ("Khi đang gõ") can
    // be an outline too, and taking the first outline measured the Form while the apps
    // were still loading (03/11/2026: "3 rows, no scroll bar", then 106 after the search).
    func list() -> AXUIElement? {
        all(sheet, where: { role($0) == "AXOutline" && string($0, kAXDescriptionAttribute) == "Ứng dụng" }).first
    }
    func listRows() -> [AXUIElement] { list().flatMap { attr($0, kAXRowsAttribute) as? [AXUIElement] } ?? [] }
    // The app list is read off the main thread (slower on the first pass, right after the
    // app starts): wait until the row count is the same on 3 reads in a row, not just > 0.
    let outlines = all(sheet, where: { role($0) == "AXOutline" })
        .map { "\(string($0, kAXDescriptionAttribute) ?? "-"):\((attr($0, kAXRowsAttribute) as? [AXUIElement])?.count ?? -1)" }
    let loadStart = Date()
    var lastCount = -1, sameReads = 0
    while sameReads < 3 && Date().timeIntervalSince(loadStart) < 15 {
        let count = listRows().count
        if count > 0 && count == lastCount { sameReads += 1 } else { sameReads = 0 }
        lastCount = count
        wait(0.2)
    }
    // Without a stable list the list checks below would measure a half-loaded one.
    let listReady = lastCount > 0 && sameReads >= 3
    record(display, page, "app list loaded", expected: "rows, stable",
           got: "\(lastCount) rows after \(String(format: "%.1f", Date().timeIntervalSince(loadStart))) s; outlines at open: \(outlines.joined(separator: ", "))",
           ok: listReady, harness: !listReady)
    // A stable list can still be short (the 03/11/2026 failure read 3 rows): compare it with
    // the apps the sheet lists from disk (AddAppRuleSheet's four Applications folders), counted
    // here the same way. Apps with a stored rule are left out of the sheet and the checker
    // cannot read the rules (App Group container), so up to `ruleAllowance` fewer rows pass.
    // Without this, a short list would only show as "skip" at the scroll bar below.
    if listReady {
        let ruleAllowance = 20
        let onDisk = installedAppCount()
        record(display, page, "app list complete", expected: "≥ \(onDisk - ruleAllowance) (\(onDisk) apps in the Applications folders, ≤ \(ruleAllowance) with a rule)",
               got: "\(lastCount) rows", ok: lastCount >= onDisk - ruleAllowance)
    }

    check(display, page, "sheet width", s.width, Reference.sheetWidth)

    // The header row: the title left and the system search field right, on one line.
    // Preferring the placeholder / title it is known to carry, else the topmost (the Form's
    // section headings lie below): a wrong text is then a FAIL at the text check below.
    let searchField = intended(all(sheet, where: { subrole($0) == "AXSearchField" }), text: "Tìm trong Ứng dụng") {
        string($0, "AXPlaceholderValue") ?? label($0) }
    let heading = intended(all(sheet, where: { role($0) == "AXHeading" }), text: "Thêm quy tắc cho ứng dụng", label)
    var headerBottom = Reference.sheetMargin
    if let field = searchField {
        let r = rel(frame(field))
        headerBottom = r.maxY
        check(display, page, "search height", r.height, Reference.sheetSearchHeight)
        check(display, page, "search top", r.minY, Reference.sheetMargin)
        check(display, page, "search right margin", s.width - r.maxX, Reference.sheetMargin)
        let prompt = string(field, "AXPlaceholderValue") ?? label(field)
        record(display, page, "search prompt", expected: "Tìm trong Ứng dụng", got: prompt, ok: prompt == "Tìm trong Ứng dụng")
        if let heading {
            let h = rel(frame(heading))
            record(display, page, "header", expected: "Thêm quy tắc cho ứng dụng", got: label(heading), ok: label(heading) == "Thêm quy tắc cho ứng dụng")
            check(display, page, "header x", h.minX, Reference.sheetMargin)
            check(display, page, "header centered on search", h.midY, r.midY)
            record(display, page, "header left of search", expected: "title ends before the field", got: "\(fmt(h.maxX)) / \(fmt(r.minX))", ok: h.maxX < r.minX)
        } else {
            harnessProblem(display, page, "header", expected: "heading")
        }
    } else {
        harnessProblem(display, page, "search", expected: "search field")
    }

    // The list card (a scroll area of its own, outside the Form), then the Form with the
    // "Khi đang gõ" card.
    // The list's scroll area: the smallest one that holds the list outline (by its label).
    // The Form's: the tallest one as wide as the sheet that holds no outline (no label).
    let listArea = all(sheet, where: { role($0) == "AXScrollArea" && !all($0, where: { role($0) == "AXOutline" && string($0, kAXDescriptionAttribute) == "Ứng dụng" }).isEmpty })
        .min { frame($0).width * frame($0).height < frame($1).width * frame($1).height }
    guard let area = all(sheet, where: { role($0) == "AXScrollArea" && near(frame($0).width, s.width) && all($0, where: { role($0) == "AXOutline" }).isEmpty })
            .max(by: { frame($0).height < frame($1).height }),
          let listArea, let listElement = list() else {
        harnessProblem(display, page, "form", expected: "list and Form scroll areas"); return
    }
    let form = rel(frame(area))
    let listCard = rel(frame(listElement))
    check(display, page, "list card", listCard,
          CGRect(x: Reference.sheetMargin, y: headerBottom + Reference.headerToCard,
                 width: s.width - 2 * Reference.sheetMargin, height: Reference.sheetListHeight))
    record(display, page, "list label", expected: "Ứng dụng", got: label(listElement), ok: label(listElement) == "Ứng dụng")
    let groups = children(area).filter { role($0) == "AXGroup" }.map { rel(frame($0)) }
    if let card = groups.min(by: { $0.minY < $1.minY }) {   // the topmost: "Khi đang gõ" (groups have no label)
        check(display, page, "Khi đang gõ card", card,
              CGRect(x: Reference.sheetMargin, y: card.minY, width: s.width - 2 * Reference.sheetMargin, height: card.height))
        check(display, page, "list card → Khi đang gõ card", card.minY - listCard.maxY, Reference.cardGap)
    } else {
        harnessProblem(display, page, "Khi đang gõ card", expected: "group")
    }
    let segmented = intended(all(sheet, where: { role($0) == "AXRadioGroup" }), text: "Khi đang gõ", label)
    if let segmented {
        check(display, page, "segmented \"\(label(segmented))\" height", rel(frame(segmented)).height, Reference.controlHeight)
        record(display, page, "segmented label", expected: "Khi đang gõ", got: label(segmented), ok: label(segmented) == "Khi đang gõ")
    } else {
        harnessProblem(display, page, "segmented", expected: "Khi đang gõ")
    }

    // The button bar.
    // By label; if two carry it, the lower one (the button bar is the sheet's bottom row).
    func button(_ title: String) -> AXUIElement? {
        all(sheet, where: { role($0) == "AXButton" && label($0) == title }).max { frame($0).minY < frame($1).minY }
    }
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
        harnessProblem(display, page, "buttons", expected: "Chọn ứng dụng khác… / Huỷ / Thêm",
                       got: "\(other == nil ? "-" : "ok") / \(cancel == nil ? "-" : "ok") / \(confirm == nil ? "-" : "ok")")
    }
    if screenshot("apps-add-sheet-\(fileTag)", w) == nil {
        harnessProblem(display, page, "screenshot", expected: "captured", got: "failed")
    }

    // The list scrolls inside its card (the bug: a List nested in a grouped Form has its
    // scroller switched off). First a real mouse wheel over the list, then the scroll
    // bar to the end: the last app must come into the card and "Khi đang gõ" stay in
    // view; then back to the top.
    // The vertical one (the scroller can have a horizontal bar too): by its orientation.
    func scrollBar() -> AXUIElement? {
        children(listArea).first { role($0) == "AXScrollBar" && string($0, kAXOrientationAttribute) == "AXVerticalOrientation" }
    }
    func barValue() -> CGFloat { (scrollBar().flatMap { attr($0, kAXValueAttribute) as? NSNumber }).map { CGFloat(truncating: $0) } ?? -1 }
    // A list that fits its card has no scroll bar: require one only if the rows (count × the
    // tallest row's frame) are taller than the visible list area.
    func waitForScrollBar() -> AXUIElement? {
        for _ in 0..<10 where scrollBar() == nil { wait(0.2) }
        return scrollBar()
    }
    let listRowsNow = listRows()
    let rowHeight = listRowsNow.map { frame($0).height }.max() ?? 0
    let overflows = CGFloat(listRowsNow.count) * rowHeight > frame(listArea).height
    if listReady && !overflows {
        record(display, page, "list scroll bar", expected: "vertical scroll bar",
               got: "skip: list does not overflow (\(listRowsNow.count) rows)", ok: true, skip: true)
    } else if listReady && waitForScrollBar() == nil {
        harnessProblem(display, page, "list scroll bar", expected: "vertical scroll bar",
                       got: "missing (list overflows: \(listRowsNow.count) rows × \(fmt(rowHeight)) > \(fmt(frame(listArea).height)))")
    } else if listReady {
        let before = barValue()
        let area = frame(listArea)
        let point = CGPoint(x: area.midX, y: area.midY)
        // The first wheel after the sheet opens can land before the window is under the
        // pointer: try up to 5 times.
        for _ in 0..<5 where barValue() <= before + 0.01 {
            AXUIElementSetAttributeValue(app, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
            CGWarpMouseCursorPosition(point)
            CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left)?.post(tap: .cghidEventTap)
            wait(0.5)
            for _ in 0..<10 {
                let wheel = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: -40, wheel2: 0, wheel3: 0)
                wheel?.location = point
                wheel?.post(tap: .cghidEventTap)
                wait(0.05)
            }
            wait(0.5)
        }
        record(display, page, "list scrolls with the wheel", expected: "scroll bar value above \(fmt(before))", got: String(format: "%.2f", barValue()),
               ok: barValue() > before + 0.01)
        if let bar = scrollBar() {
            // Rows are sized as they appear, so the end moves: push to the end until the
            // last app is in view (at most 15 pushes).
            let area = rel(frame(listArea))
            func lastInView() -> Bool {
                guard let last = listRows().last else { return false }
                let r = rel(frame(last))
                return r.minY >= area.minY - Reference.tolerance && r.maxY <= area.maxY + Reference.tolerance
            }
            for _ in 0..<15 {
                AXUIElementSetAttributeValue(bar, kAXValueAttribute as CFString, NSNumber(value: 1.0))
                wait(0.4)
                if lastInView() { break }
            }
            if let last = listRows().last {
                let r = rel(frame(last))
                record(display, page, "last app visible at the end", expected: "inside \(fmt(area))", got: fmt(r),
                       ok: r.minY >= area.minY - Reference.tolerance && r.maxY <= area.maxY + Reference.tolerance)
            }
            let typing = segmented.map { rel(frame($0)) }
            record(display, page, "Khi đang gõ in view while scrolled", expected: "inside the sheet", got: typing.map(fmt) ?? "missing",
                   ok: typing.map { $0.minY > area.maxY && $0.maxY < s.height } ?? false, harness: typing == nil)
            if screenshot("apps-add-sheet-bottom-\(fileTag)", w) == nil {
                harnessProblem(display, page, "screenshot bottom", expected: "captured", got: "failed")
            }
            AXUIElementSetAttributeValue(bar, kAXValueAttribute as CFString, NSNumber(value: 0.0))
            wait(0.5)
        }
    }

    // The search field filters the list (value set through accessibility, then cleared).
    let total = listRows().count
    // The row's name: its topmost text (the texts have no label to tell them apart).
    if listReady, let field = searchField, let firstRow = listRows().first,
       let name = all(firstRow, where: { role($0) == "AXStaticText" }).min(by: { frame($0).minY < frame($1).minY }).map(label) {
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
    if listReady, let list = list(), let row = listRows().first {
        AXUIElementSetAttributeValue(list, kAXSelectedRowsAttribute as CFString, [row] as CFArray)
        wait(0.8)
        record(display, page, "Thêm with selection", expected: "enabled", got: enabled(button("Thêm")) ? "enabled" : "disabled",
               ok: enabled(button("Thêm")))
        if screenshot("apps-add-sheet-selected-\(fileTag)", w) == nil {
            harnessProblem(display, page, "screenshot selected", expected: "captured", got: "failed")
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
    let cancelNow = button("Huỷ")
    if let cancelNow { AXUIElementPerformAction(cancelNow, kAXPressAction as CFString) }
    var closed = false
    for _ in 0..<25 where !closed {
        closed = attachedSheet() == nil
        if !closed { wait(0.2) }
    }
    // Without the button nothing was pressed: the checker, not the sheet, failed to close it.
    record(display, page, "Huỷ closes", expected: "closed", got: closed ? "closed" : "open", ok: closed,
           harness: !closed && cancelNow == nil)
}

// One pass per display scale: the user has a Retina and a 1x display.
let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
var seenScales = Set<CGFloat>()
var pass = 0
for screen in NSScreen.screens where seenScales.insert(screen.backingScaleFactor).inserted {
    // The pass number tells a cold-app failure (pass 1) from one that needs a given display.
    pass += 1
    fileTag = "\(fmt(screen.backingScaleFactor))x"
    let display = "\(fileTag) pass \(pass)"
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
harnessProblems.forEach { print("HARNESS", $0) }
if !harnessProblems.isEmpty {
    print("\(harnessProblems.count) harness problem(s): the checker could not reach an element; not a UI result.")
}
if !failures.isEmpty { print("\(failures.count) real-window check(s) failed.") }
if failures.isEmpty && harnessProblems.isEmpty { print("Real-window checks passed (\(rows.count)).") }
exit(failures.isEmpty && harnessProblems.isEmpty ? 0 : 1)
