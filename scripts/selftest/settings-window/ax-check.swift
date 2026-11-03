// Real-window checker of the Settings window (docs/UI-CHECKS.md). run.sh launches the
// Debug app itself, as the user opens it (`open -n Dau.app --args … --settings-window`),
// once per state, and compiles this file together with Reference.swift (every expected
// value, with its source). Nothing here runs inside the app.
//
// Usage: ax-check <pid> <output-dir> <light|dark> <mode>…
//   <light|dark>   the appearance the app draws in (run.sh knows it); written to frames.json.
//   --geometry     (overlay scroll bars) The window's size at launch, read before anything
//                  is moved or resized. Then on every display, one pass per backing scale
//                  (rows labelled "2x" / "1x"): each section, selected through the
//                  sidebar's accessibility, against System Settings; the sidebar search
//                  with a query nothing matches; the add-rule sheet ("+" on Ứng dụng):
//                  layout, the app list (settles, overflows, scroll bar, wheel, always-
//                  installed apps, end of list), search and selection wiring, Huỷ. Last,
//                  the window's size limits (by resizing it) and, at the widest, the first
//                  card of every section.
//   --pixels       (legacy scroll bars) Primary display: per section the scroll room rule
//                  (a) and a screenshot; on the section that overflows
//                  (Reference.scrollingSection) a scroll through its scroll bar, the
//                  scroll bar's lane (d) and a second screenshot. check.swift reads the
//                  screenshots for (b)–(d).
//   --banner       (app run with --not-enabled) Primary display: the "Dấu chưa được bật"
//                  banner is the first card of Gõ phím and spans the column.
//   --sheet-shots  Primary display: screenshots of the add-rule sheet, empty and with a
//                  row selected (no geometry: --geometry measures the sheet).
// Screenshots are `screencapture -l` of the Settings window only (an attached sheet is
// in it), named <name>-<scale>x.png; <output-dir>/frames.json holds the frames of every
// screenshot (window points, origin at the window's top-left) for check.swift and
// scripts/snapshot-settings, plus "meta": the primary display's scale and the appearance.
//
// Results, one row each, `display | page | metric | expected | got | result`:
// - HARNESS only when the checker cannot run: no Accessibility permission, no window for
//   the pid, an Accessibility call that errors or times out, or a screenshot the system
//   will not take. Not a UI result.
// - FAIL for everything the window should show but does not, or shows in a wrong state: a
//   missing element (card, header, button, "+", search field, scroll bar), a list that
//   never settles or stays empty, a sheet that does not open, a value off Reference.
// - There is no skip. Every lookup goes through `require`, which records FAIL or HARNESS
//   when it finds nothing; a check that cannot run without it says so in that row. Every
//   return while the add-rule sheet is open goes back through `closeSheet`.
// Exit status 0 only when every row is ok.
import AppKit

// MARK: - Arguments

let usage = "usage: ax-check <pid> <output-dir> <light|dark> --geometry | --pixels | --banner | --sheet-shots …"
let modeFlags: Set = ["--geometry", "--pixels", "--banner", "--sheet-shots"]
let arguments = Array(CommandLine.arguments.dropFirst())
guard arguments.count >= 4, let pid = pid_t(arguments[0]), ["light", "dark"].contains(arguments[2]),
      Set(arguments.dropFirst(3)).isSubset(of: modeFlags) else {
    print(usage)
    exit(2)
}
let outDir = URL(fileURLWithPath: arguments[1], isDirectory: true)
let appearance = arguments[2]
let modes = Set(arguments.dropFirst(3))
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

// MARK: - Results

// Top-level code is single-threaded; Swift 6 would isolate globals to the main actor.
nonisolated(unsafe) var rows: [String] = []
nonisolated(unsafe) var failures: [String] = []
nonisolated(unsafe) var harnessProblems: [String] = []
/// Frames of every screenshot taken, by file name (without ".png"), for frames.json.
nonisolated(unsafe) var shots: [String: [String: [Double]]] = [:]

func record(_ d: String, _ p: String, _ metric: String, expected: String, got: String, ok: Bool) {
    rows.append("\(d) | \(p) | \(metric) | \(expected) | \(got) | \(ok ? "ok" : "FAIL")")
    if !ok { failures.append("\(d) \(p) \(metric): expected \(expected), got \(got)") }
}
/// The checker could not do its part (see the header): not a UI result.
func harness(_ d: String, _ p: String, _ metric: String, expected: String, got: String) {
    rows.append("\(d) | \(p) | \(metric) | \(expected) | \(got) | HARNESS")
    harnessProblems.append("\(d) \(p) \(metric): \(expected) / \(got)")
}
/// A harness problem before any row can be measured: print it and stop.
func harnessAbort(_ metric: String, expected: String, got: String) -> Never {
    print("HARNESS - - \(metric): \(expected) / \(got)")
    print("1 harness problem(s): the checker could not run; not a UI result.")
    exit(1)
}

func fmt(_ v: CGFloat) -> String { v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v) }
func fmt(_ r: CGRect) -> String { "\(fmt(r.minX)),\(fmt(r.minY)) \(fmt(r.width))×\(fmt(r.height))" }
func near(_ a: CGFloat, _ b: CGFloat, _ tolerance: CGFloat = Reference.tolerance) -> Bool { abs(a - b) <= tolerance }
func check(_ d: String, _ p: String, _ metric: String, _ got: CGFloat, _ expected: CGFloat,
           tolerance: CGFloat = Reference.tolerance) {
    record(d, p, metric, expected: fmt(expected), got: fmt(got), ok: near(got, expected, tolerance))
}
func check(_ d: String, _ p: String, _ metric: String, _ got: CGRect, _ expected: CGRect) {
    let ok = near(got.minX, expected.minX) && near(got.minY, expected.minY)
        && near(got.width, expected.width) && near(got.height, expected.height)
    record(d, p, metric, expected: fmt(expected), got: fmt(got), ok: ok)
}

// MARK: - Accessibility

guard AXIsProcessTrusted() else {
    harnessAbort("Accessibility permission", expected: "granted to this terminal",
                 got: "missing (System Settings › Privacy & Security › Accessibility)")
}

nonisolated(unsafe) let app = AXUIElementCreateApplication(pid)
AXUIElementSetMessagingTimeout(app, 5)

/// Accessibility calls that failed (not "no such attribute" or "no value", which are
/// answers): a lookup that finds nothing while one of these happened is HARNESS.
nonisolated(unsafe) var axErrors: [String] = []

func attr(_ e: AXUIElement, _ name: String) -> CFTypeRef? {
    var v: CFTypeRef?
    let err = AXUIElementCopyAttributeValue(e, name as CFString, &v)
    switch err {
    case .success: return v
    // Answers: the element has no such attribute, no value, or is gone.
    case .noValue, .attributeUnsupported, .invalidUIElement, .notImplemented: return nil
    default:
        axErrors.append("read \(name): AXError \(err.rawValue)")
        return nil
    }
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
func enabled(_ e: AXUIElement) -> Bool { (attr(e, kAXEnabledAttribute) as? Bool) ?? false }
func rowCount(_ e: AXUIElement) -> Int { (attr(e, kAXRowsAttribute) as? [AXUIElement])?.count ?? 0 }
func wait(_ seconds: Double) { RunLoop.main.run(until: Date().addingTimeInterval(seconds)) }

func set(_ e: AXUIElement, _ name: String, _ value: CFTypeRef) -> AXError {
    AXUIElementSetAttributeValue(e, name as CFString, value)
}
func press(_ e: AXUIElement) -> AXError { AXUIElementPerformAction(e, kAXPressAction as CFString) }
func axPoint(_ p: CGPoint) -> AXValue { var p = p; return AXValueCreate(.cgPoint, &p)! }
func axSize(_ s: CGSize) -> AXValue { var s = s; return AXValueCreate(.cgSize, &s)! }

/// Drives the window through accessibility (select, set a value, press, move). A refusal
/// means the checker cannot do its part: HARNESS under `what`. Success records no row.
@discardableResult
func drive(_ d: String, _ p: String, _ what: String, _ err: AXError) -> Bool {
    guard err != .success else { return true }
    harness(d, p, what, expected: "accessibility action done", got: "AXError \(err.rawValue)")
    return false
}

/// Every lookup of an element a check needs. Waits up to `seconds` for `find`; nothing
/// found records FAIL (the window does not show it; `diagnose` says what it shows
/// instead) or HARNESS (an Accessibility call failed meanwhile), and returns nil.
func require<T>(_ d: String, _ p: String, _ what: String, within seconds: Double = 0,
                diagnose: () -> String = { "missing" }, find: () -> T?) -> T? {
    let mark = axErrors.count, start = Date()
    var found = find()
    while found == nil && Date().timeIntervalSince(start) < seconds {
        wait(0.2)
        found = find()
    }
    if let found { return found }
    if axErrors.count > mark {
        harness(d, p, what, expected: "present", got: "Accessibility error: "
                + axErrors[mark...].suffix(2).joined(separator: "; "))
    } else {
        record(d, p, what, expected: "present", got: diagnose(), ok: false)
    }
    return nil
}

/// `require` for an element whose presence is itself a check users hit (a sheet that did
/// not open, a missing scroll bar): also an ok row when it is there.
func requireShown<T>(_ d: String, _ p: String, _ what: String, within seconds: Double = 0,
                     diagnose: () -> String = { "missing" }, find: () -> T?) -> T? {
    let found = require(d, p, what, within: seconds, diagnose: diagnose, find: find)
    if found != nil { record(d, p, what, expected: "present", got: "present", ok: true) }
    return found
}

// MARK: - The window

func standardWindows() -> [AXUIElement] {
    ((attr(app, kAXWindowsAttribute) as? [AXUIElement]) ?? [])
        .filter { role($0) == "AXWindow" && subrole($0) == "AXStandardWindow" }
}

/// The Settings window: with --settings-window the app opens no other standard window. Its
/// title is the page's, so it is no identity; a window without its sidebar still counts
/// here, and the sidebar lookups then FAIL.
nonisolated(unsafe) let window: AXUIElement = {
    for _ in 0..<75 {
        if let w = standardWindows().first { return w }
        wait(0.2)
    }
    let shown = ((attr(app, kAXWindowsAttribute) as? [AXUIElement]) ?? [])
        .map { "\(subrole($0)) \"\(string($0, kAXTitleAttribute) ?? "")\" \(fmt(frame($0)))" }
    harnessAbort("Settings window", expected: "a window for pid \(pid) within 15 s",
                 got: "none; windows: \(shown.isEmpty ? "none" : shown.joined(separator: "; "))")
}()

// Read first, before the checker moves or resizes anything: the size the app opens at
// (run.sh deleted the saved frame, so this is the scene's default size).
let launchSize = frame(window).size

let sections = Reference.sections
/// System: the legacy scroll bar's width (check (a)).
let legacyWidth = NSScroller.scrollerWidth(for: .regular, scrollerStyle: .legacy)
let appsIndex = sections.firstIndex(of: "apps")!
let sidebarWidth = Reference.sidebarWidth, formMargin = Reference.formMargin

/// Elements of the window itself, the add-rule sheet left out (it has outlines, search
/// fields and scroll areas of its own and can lie over the sidebar column).
func windowElements(where match: (AXUIElement) -> Bool) -> [AXUIElement] {
    children(window).filter { role($0) != "AXSheet" }.flatMap { all($0, where: match) }
}
/// Window-relative frame (origin at the window's top-left).
func rel(_ e: AXUIElement) -> CGRect {
    let w = frame(window)
    return frame(e).offsetBy(dx: -w.minX, dy: -w.minY)
}

/// Outlines in the sidebar column (no stable label: by where they lie).
func sidebarOutlines() -> [AXUIElement] {
    windowElements { role($0) == "AXOutline" }
        .filter { let x = rel($0).minX; return x >= -Reference.tolerance && x < sidebarWidth }
}
/// The sidebar list: the outline in the sidebar column with one row per section.
func findSidebarOutline(_ d: String, _ p: String) -> AXUIElement? {
    require(d, p, "sidebar list (\(sections.count) rows)", within: 3,
            diagnose: { "outlines in the sidebar column with rows: "
                + (sidebarOutlines().map { String(rowCount($0)) }.joined(separator: ", ").nonEmpty ?? "none") },
            find: { sidebarOutlines().first { rowCount($0) == sections.count } })
}
/// The sidebar's search field: the one in the sidebar column (no stable label known).
func sidebarSearchField() -> AXUIElement? {
    windowElements { subrole($0) == "AXSearchField" }
        .first { let x = rel($0).minX; return x >= -Reference.tolerance && x < sidebarWidth }
}
/// The window's toolbar: toolbars have no label, so the widest one in the window's upper
/// half; the highest wins a tie.
func toolbar() -> AXUIElement? {
    let height = frame(window).height
    return windowElements { role($0) == "AXToolbar" }
        .filter { rel($0).midY < height / 2 }
        .max { a, b in
            let fa = rel(a), fb = rel(b)
            return fa.width != fb.width ? fa.width < fb.width : fa.minY > fb.minY
        }
}
/// The close button: one per window, the subrole is the identity.
func closeButton() -> AXUIElement? { windowElements { subrole($0) == "AXCloseButton" }.first }
/// The page title: the toolbar's heading in the detail column, leftmost (its text is the
/// page's, so no label to look for).
func pageTitle() -> AXUIElement? {
    toolbar().flatMap { bar in
        all(bar) { role($0) == "AXHeading" && rel($0).minX >= sidebarWidth - Reference.tolerance }
            .min { rel($0).minX < rel($1).minX }
    }
}
/// The toolbar "+" of Ứng dụng, by its label.
func toolbarAddButton() -> AXUIElement? {
    windowElements { role($0) == "AXToolbar" }.flatMap { children($0) }
        .first { role($0) == "AXButton" && label($0) == "Thêm ứng dụng" }
}
/// The toolbar's search field (Ứng dụng): right of the sidebar, in the toolbar band (no
/// stable label known).
func toolbarSearchField() -> AXUIElement? {
    windowElements { subrole($0) == "AXSearchField" }
        .first { rel($0).minX >= sidebarWidth && rel($0).minY < Reference.toolbarHeight }
}
/// The page's Form: scroll areas have no label, so the largest one in the detail column.
func pageScrollArea() -> AXUIElement? {
    windowElements { role($0) == "AXScrollArea" && rel($0).minX >= sidebarWidth - Reference.tolerance }
        .max { rel($0).width * rel($0).height < rel($1).width * rel($1).height }
}
/// The page's vertical scroll bar, if it shows one: by orientation, in the detail column.
/// Optional by nature: a legacy bar shows only on a page that overflows.
func pageScrollBar() -> AXUIElement? {
    windowElements { role($0) == "AXScrollBar" && string($0, kAXOrientationAttribute) == "AXVerticalOrientation"
        && rel($0).minX >= sidebarWidth && rel($0).width > 0 }
        .max { rel($0).height < rel($1).height }
}
/// The Form's cards, section headers and texts, top to bottom.
func pageItems(_ area: AXUIElement) -> [(role: String, frame: CGRect, element: AXUIElement)] {
    children(area).map { (role($0), rel($0), $0) }
        .filter { ["AXGroup", "AXHeading", "AXStaticText"].contains($0.0) }
        .sorted { $0.1.minY < $1.1.minY }
}

extension String { var nonEmpty: String? { isEmpty ? nil : self } }

/// Selects section `index` through the sidebar's accessibility (no clicks).
func showSection(_ d: String, _ index: Int) -> Bool {
    let p = sections[index]
    guard let outline = findSidebarOutline(d, p),
          let row = require(d, p, "sidebar row \(index)", find: {
              ((attr(outline, kAXRowsAttribute) as? [AXUIElement]) ?? []).dropFirst(index).first }),
          drive(d, p, "select the section", set(outline, kAXSelectedRowsAttribute, [row] as CFArray))
    else { return false }
    wait(1.0)
    return true
}

func moveWindow(to screen: NSScreen, _ d: String) -> Bool {
    // Accessibility positions are top-left based on the primary display.
    let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
    let visible = screen.visibleFrame
    let origin = CGPoint(x: visible.minX + 40, y: primaryHeight - visible.maxY + 40)
    guard drive(d, "window", "move the window to this display", set(window, kAXPositionAttribute, axPoint(origin)))
    else { return false }
    // Every pass measures the default size, whatever size the app opened at: a launch after
    // the limits pass could open at the minimum size (03/11/2026, the killed app's saved frame
    // outlived run.sh's delete). Only the geometry launch checks the size at launch.
    guard drive(d, "window", "set the default window size", set(window, kAXSizeAttribute, axSize(Reference.windowSize)))
    else { return false }
    wait(0.6)
    return true
}

// MARK: - Screenshots

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

/// Captures the window (and an attached sheet) to <name>.png and keeps `frames` (window
/// points) for frames.json. A failure is HARNESS: the system did not give the image.
func screenshot(_ d: String, _ p: String, _ name: String, frames: [String: CGRect] = [:]) -> NSBitmapImageRep? {
    let w = frame(window)
    // The window can be briefly off the on-screen list (for example while another app
    // takes the front): look again a few times.
    var number = windowNumber(w), tries = 1
    while number == nil && tries < 6 {
        wait(0.4)
        tries += 1
        number = windowNumber(w)
    }
    guard let number else {
        harness(d, p, "screenshot \(name)", expected: "window in the on-screen window list", got: "not listed after \(tries) tries")
        return nil
    }
    let url = outDir.appendingPathComponent("\(name).png")
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    task.arguments = ["-o", "-x", "-l", String(number), url.path]
    try? task.run()
    task.waitUntilExit()
    guard let rep = (try? Data(contentsOf: url)).flatMap(NSBitmapImageRep.init(data:)) else {
        harness(d, p, "screenshot \(name)", expected: "an image", got: "screencapture wrote none (Screen Recording permission?)")
        return nil
    }
    var all = frames
    all["window"] = CGRect(origin: .zero, size: w.size)
    shots[name] = all.mapValues { [$0.minX, $0.minY, $0.width, $0.height].map(Double.init) }
    return rep
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

// MARK: - Sections (--geometry)

/// One section on one display, against System Settings (Reference).
func measureSection(_ d: String, _ tag: String, _ index: Int) {
    let page = sections[index]
    guard showSection(d, index) else { return }
    let w = frame(window)
    var shot: [String: CGRect] = [:]

    if let bar = require(d, page, "toolbar", find: toolbar) {
        shot["toolbar"] = rel(bar)
        check(d, page, "toolbar height", rel(bar).height, Reference.toolbarHeight)
    }
    if let close = require(d, page, "close button", find: closeButton) {
        shot["close"] = rel(close)
        check(d, page, "close button", rel(close), Reference.closeFrame)
    }
    let title = require(d, page, "page title (toolbar heading)", find: pageTitle).map(rel)
    if let title {
        shot["title"] = title
        check(d, page, "title x", title.minX, Reference.titleX)
        check(d, page, "title center y", title.midY, Reference.titleCenterY)
    }

    // Sidebar: search field, rows, icon tile.
    if let field = require(d, page, "sidebar search field", find: sidebarSearchField) {
        check(d, page, "sidebar search", rel(field), Reference.sidebarSearchFrame)
    }
    if let outline = findSidebarOutline(d, page) {
        let sidebarRows = (attr(outline, kAXRowsAttribute) as? [AXUIElement]) ?? []
        for (i, row) in sidebarRows.enumerated() {
            // A sidebar row has a single cell.
            if let cell = require(d, page, "sidebar row \(i) cell", find: { children(row).first }) {
                check(d, page, "sidebar row \(i)", rel(cell), Reference.sidebarRowFrame(i))
            }
        }
        // The row's texts have no label to tell them apart: the leftmost is the icon tile.
        if let first = require(d, page, "sidebar row 0", find: { sidebarRows.first }),
           let icon = require(d, page, "sidebar row 0 icon tile", find: {
               all(first) { role($0) == "AXStaticText" }.min { rel($0).minX < rel($1).minX } }) {
            check(d, page, "sidebar icon x", rel(icon).minX, Reference.sidebarIconX)
            check(d, page, "sidebar icon height", rel(icon).height, Reference.sidebarIconSize)
        }
    }

    // Detail: cards and section headers in the Form.
    if let area = require(d, page, "page Form (scroll area in the detail column)", find: pageScrollArea) {
        let column = rel(area)
        shot["column"] = column
        let items = pageItems(area)
        if let first = require(d, page, "first card or header", find: { items.first }) {
            check(d, page, "first item y", first.frame.minY, Reference.formFirstItemY)
        }
        let cards = items.filter { $0.role == "AXGroup" }
        // Item 1: the card spans the detail column with the Form's margins (overlay scroll
        // bars take no room), measured from the window, not from the app's own column.
        if let card = require(d, page, "first card", find: { cards.first }) {
            shot["firstCard"] = card.frame
            check(d, page, "first card", card.frame, CGRect(x: sidebarWidth + formMargin, y: card.frame.minY,
                                                            width: w.width - sidebarWidth - 2 * formMargin,
                                                            height: card.frame.height))
        }
        for (i, item) in items.enumerated() where item.role == "AXHeading" {
            let name = label(item.element)
            check(d, page, "header \"\(name)\" x", item.frame.minX, sidebarWidth + formMargin + Reference.cardInset)
            if i + 1 < items.count, items[i + 1].role == "AXGroup" {
                check(d, page, "header \"\(name)\" → card", items[i + 1].frame.minY - item.frame.maxY, Reference.headerToCard)
            }
            if i > 0, items[i - 1].role == "AXGroup" {
                check(d, page, "card → header \"\(name)\"", item.frame.minY - items[i - 1].frame.maxY, Reference.cardToHeader)
            }
        }

        // Controls inside the cards, in view (every page shows some).
        var measured = 0
        for card in cards where column.intersects(card.frame) {
            for e in all(card.element, where: { _ in true }) {
                let r = rel(e)
                guard column.contains(r) else { continue }
                switch (role(e), subrole(e)) {
                case ("AXCheckBox", "AXSwitch"):
                    measured += 1
                    if shot["switch"] == nil { shot["switch"] = r }
                    check(d, page, "switch \"\(label(e).prefix(24))\"", r, CGRect(origin: r.origin, size: Reference.switchSize))
                case ("AXButton", _) where label(e) == "Nâng cao":
                    // The "Nâng cao" disclosure row: a plain button with a chevron (D9),
                    // as tall as its text, not a bezel button.
                    break
                case ("AXButton", _), ("AXPopUpButton", _), ("AXRadioGroup", _):
                    measured += 1
                    if role(e) == "AXButton", shot["button"] == nil { shot["button"] = r }
                    check(d, page, "\(role(e).dropFirst(2)) \"\(label(e).prefix(24))\" height", r.height, Reference.controlHeight)
                default: break
                }
            }
        }
        record(d, page, "controls in view", expected: "at least one measured", got: "\(measured)", ok: measured > 0)

        // Item 6: "Kiểu gõ" has no row label and spans its row (macOS 26+, flexible
        // segments), as System Settings' Sound › Output/Input.
        if page == "typing",
           let segmented = require(d, page, "segmented \"Kiểu gõ\"", find: {
               cards.flatMap { all($0.element) { role($0) == "AXRadioGroup" && label($0) == "Kiểu gõ" } }.first }),
           let card = require(d, page, "card of \"Kiểu gõ\"", find: { cards.first { $0.frame.contains(rel(segmented)) } }) {
            let r = rel(segmented)
            shot["segmented"] = r
            record(d, page, "segmented \"Kiểu gõ\" spans its row", expected: "x \(fmt(card.frame.minX + Reference.cardInset)), width \(fmt(card.frame.width - 2 * Reference.cardInset))",
                   got: "x \(fmt(r.minX)), width \(fmt(r.width))",
                   ok: near(r.minX, card.frame.minX + Reference.cardInset) && near(r.width, card.frame.width - 2 * Reference.cardInset))
        }
    }

    // Ứng dụng: the toolbar's "+" (items 7, 8) and search field, right of the title.
    if page == "apps" {
        let add = require(d, page, "toolbar + (\"Thêm ứng dụng\")", find: toolbarAddButton).map(rel)
        let field = require(d, page, "toolbar search field", find: toolbarSearchField).map(rel)
        if let add { shot["headerAdd"] = add }
        if let field { shot["headerSearch"] = field }
        if let add, let title {
            record(d, page, "+ right of the title", expected: "≥ \(fmt(Reference.appsAddGapToTitle)) after the title",
                   got: "\(fmt(add.minX - title.maxX))", ok: add.minX - title.maxX >= Reference.appsAddGapToTitle)
        }
        if let add, let field {
            record(d, page, "+ before the search field", expected: "+ ends before the field", got: "\(fmt(add.maxX)) / \(fmt(field.minX))",
                   ok: add.maxX <= field.minX + Reference.tolerance)
        }
        if let field {
            let inset = w.width - field.maxX
            record(d, page, "search field right inset", expected: "\(fmt(Reference.appsSearchRightInset.lowerBound))…\(fmt(Reference.appsSearchRightInset.upperBound))",
                   got: fmt(inset), ok: Reference.appsSearchRightInset.contains(inset))
            record(d, page, "search field height", expected: "≥ \(fmt(Reference.controlHeight))", got: fmt(field.height),
                   ok: field.height >= Reference.controlHeight - Reference.tolerance)
        }
    }

    if let scroller = pageScrollBar() { shot["scroller"] = rel(scroller) }   // overlay: for check.swift to leave out

    // Pixels: where the text of an unselected sidebar row begins.
    if let rep = screenshot(d, page, "\(page)-\(tag)", frames: shot) {
        let other = index == 1 ? 2 : 1
        let y = Reference.sidebarRowFrame(other).minY
        let band = Reference.sidebarTextProbeY
        let x = inkStart(rep, width: w.width, xs: Reference.sidebarTextProbeX, ys: (y + band.lowerBound)...(y + band.upperBound))
        record(d, page, "sidebar text x", expected: fmt(Reference.sidebarTextX), got: x.map(fmt) ?? "no text in the probe band",
               ok: x.map { near($0, Reference.sidebarTextX) } ?? false)
    }
}

// MARK: - Sidebar search (--geometry)

/// Wiring only (what matches is `swift test` "Sidebar search"): a query no section matches
/// leaves the sidebar without rows and shows the system's empty state naming the query,
/// the toolbar keeps its height; clearing brings the rows back.
func measureSidebarSearch(_ d: String, _ tag: String) {
    let p = "sidebar-search"
    let query = "zzzz-no-such-setting"
    guard let field = require(d, p, "sidebar search field", find: sidebarSearchField),
          let outline = findSidebarOutline(d, p),
          // SwiftUI reads the sidebar field's value only while it has focus (measured: a
          // value set without focus shows in the field but filters nothing).
          drive(d, p, "focus the search field", set(field, kAXFocusedAttribute, kCFBooleanTrue)),
          drive(d, p, "type the query", set(field, kAXValueAttribute, query as CFString))
    else { return }
    wait(1.0)
    check(d, p, "rows without a match", CGFloat(rowCount(outline)), 0, tolerance: Reference.exact)
    let texts = windowElements { role($0) == "AXStaticText" }
        .filter { rel($0).maxX <= sidebarWidth && rel($0).minY > Reference.sidebarFirstRowY && label($0).contains(query) }
    record(d, p, "empty state", expected: "text naming the query in the sidebar", got: texts.first.map(label) ?? "none", ok: !texts.isEmpty)
    if let bar = require(d, p, "toolbar", find: toolbar) {
        check(d, p, "toolbar height", rel(bar).height, Reference.toolbarHeight)
    }
    _ = screenshot(d, p, "sidebar-search-empty-\(tag)")
    guard drive(d, p, "clear the query", set(field, kAXValueAttribute, "" as CFString)) else { return }
    wait(1.0)
    check(d, p, "rows after clearing", CGFloat(rowCount(outline)), CGFloat(sections.count), tolerance: Reference.exact)
}

// MARK: - Add-rule sheet

let sheetPage = "add-sheet"

/// The sheet attached to the Settings window: a window has at most one, so the role is the identity.
func attachedSheet() -> AXUIElement? { children(window).first { role($0) == "AXSheet" } }
/// The app list, by its accessibility label, not by order. Why the list once read 3 rows
/// (03/11/2026) is not known: the guess that another outline (the Form) had been read was
/// not confirmed; at open the sheet held only this outline. "app list settles" prints the
/// outlines it finds.
func appList(_ sheet: AXUIElement) -> AXUIElement? {
    all(sheet) { role($0) == "AXOutline" && string($0, kAXDescriptionAttribute) == "Ứng dụng" }.first
}
func appRows(_ sheet: AXUIElement) -> [AXUIElement] { appList(sheet).flatMap { attr($0, kAXRowsAttribute) as? [AXUIElement] } ?? [] }
/// By label; if two carry it, the lower one (the button bar is the sheet's bottom row).
func sheetButton(_ sheet: AXUIElement, _ title: String) -> AXUIElement? {
    all(sheet) { role($0) == "AXButton" && label($0) == title }.max { frame($0).minY < frame($1).minY }
}
/// The element carrying `wanted`; if none does, the topmost candidate, so that a wrong text
/// shows as a FAIL at the text check, not as a missing element.
func intended(_ candidates: [AXUIElement], text wanted: String, _ text: (AXUIElement) -> String) -> AXUIElement? {
    candidates.first { text($0) == wanted } ?? candidates.min { frame($0).minY < frame($1).minY }
}

/// Presses "+" on Ứng dụng and returns the sheet it opens. Nil (recorded) when there is
/// no "+" or no sheet; a sheet that opens late is closed again.
func openSheet(_ d: String) -> AXUIElement? {
    guard showSection(d, appsIndex),
          let add = require(d, sheetPage, "toolbar + (\"Thêm ứng dụng\")", find: toolbarAddButton),
          drive(d, sheetPage, "press +", press(add))
    else { return nil }
    guard let sheet = requireShown(d, sheetPage, "sheet opened by +", within: 5, find: attachedSheet) else {
        if attachedSheet() != nil { closeSheet(d) }
        return nil
    }
    // Screenshots of an active window, as the user sees it.
    drive(d, sheetPage, "bring Dấu to the front", set(app, kAXFrontmostAttribute, kCFBooleanTrue))
    return sheet
}

/// Closes the sheet with Huỷ (a row: Huỷ closes it), or with Escape when Huỷ cannot be
/// pressed, so the next checks start without it. Called after every sheet visit.
func closeSheet(_ d: String) {
    guard let sheet = attachedSheet() else {
        record(d, sheetPage, "sheet open until Huỷ", expected: "open", got: "closed by itself", ok: false)
        return
    }
    if let cancel = require(d, sheetPage, "Huỷ button to close the sheet", find: { sheetButton(sheet, "Huỷ") }),
       drive(d, sheetPage, "press Huỷ", press(cancel)) {
        var closed = false
        for _ in 0..<25 where !closed {
            wait(0.2)
            closed = attachedSheet() == nil
        }
        record(d, sheetPage, "Huỷ closes the sheet", expected: "closed", got: closed ? "closed" : "still open", ok: closed)
    }
    guard attachedSheet() != nil else { return }
    for down in [true, false] {
        CGEvent(keyboardEventSource: nil, virtualKey: 53, keyDown: down)?.post(tap: .cghidEventTap)
    }
    wait(1.0)
    if attachedSheet() != nil {
        record(d, sheetPage, "sheet closed for the next checks", expected: "closed (Huỷ, then Escape)", got: "still open", ok: false)
    }
}

/// Waits for the app list (it is read off the main thread): the same row count on 3 reads
/// 0.2 s apart, more than none, within 15 s. Returns that count; nil (recorded FAIL) when
/// it never settles, stays empty or there is no list.
func settledAppCount(_ d: String, _ sheet: AXUIElement) -> Int? {
    let outlinesAtOpen = all(sheet) { role($0) == "AXOutline" }
        .map { "\(string($0, kAXDescriptionAttribute) ?? "-"):\(rowCount($0))" }
    let mark = axErrors.count, start = Date()
    var last = -1, same = 0
    while same < 3 && Date().timeIntervalSince(start) < 15 {
        let count = appRows(sheet).count
        same = count > 0 && count == last ? same + 1 : 0
        last = count
        wait(0.2)
    }
    let settled = same >= 3
    let got = (appList(sheet) == nil ? "no outline labelled \"Ứng dụng\"" : "\(last) rows")
        + " after \(String(format: "%.1f", Date().timeIntervalSince(start))) s; outlines at open: "
        + (outlinesAtOpen.joined(separator: ", ").nonEmpty ?? "none")
    if !settled && axErrors.count > mark {
        harness(d, sheetPage, "app list settles", expected: "rows, the same on 3 reads, within 15 s",
                got: got + "; Accessibility error: " + axErrors[mark...].suffix(2).joined(separator: "; "))
    } else {
        record(d, sheetPage, "app list settles", expected: "rows, the same on 3 reads, within 15 s", got: got, ok: settled)
    }
    return settled ? last : nil
}

/// The add-rule sheet on one display: layout against System Settings' sheets, the app
/// list, search and selection wiring, screenshots; then Huỷ.
func measureSheet(_ d: String, _ tag: String) {
    guard let sheet = openSheet(d) else { return }
    inspectSheet(d, tag, sheet)
    closeSheet(d)
}

func inspectSheet(_ d: String, _ tag: String, _ sheet: AXUIElement) {
    let p = sheetPage
    let s = frame(sheet)
    func srel(_ e: AXUIElement) -> CGRect { frame(e).offsetBy(dx: -s.minX, dy: -s.minY) }
    guard let total = settledAppCount(d, sheet),
          let list = require(d, p, "app list", find: { appList(sheet) }) else { return }

    check(d, p, "sheet width", s.width, Reference.sheetWidth)

    // The header row: the title left and the system search field right, on one line.
    // Preferring the placeholder / title it is known to carry, else the topmost (the Form's
    // section headings lie below): a wrong text is then a FAIL at the text check.
    let field = require(d, p, "search field", find: {
        intended(all(sheet) { subrole($0) == "AXSearchField" }, text: "Tìm trong Ứng dụng") { string($0, "AXPlaceholderValue") ?? label($0) } })
    let heading = require(d, p, "header", find: {
        intended(all(sheet) { role($0) == "AXHeading" }, text: "Thêm quy tắc cho ứng dụng", label) })
    if let field {
        let r = srel(field)
        check(d, p, "search height", r.height, Reference.sheetSearchHeight)
        check(d, p, "search top", r.minY, Reference.sheetMargin)
        check(d, p, "search right margin", s.width - r.maxX, Reference.sheetMargin)
        let prompt = string(field, "AXPlaceholderValue") ?? label(field)
        record(d, p, "search prompt", expected: "Tìm trong Ứng dụng", got: prompt, ok: prompt == "Tìm trong Ứng dụng")
    }
    if let heading {
        let h = srel(heading)
        record(d, p, "header", expected: "Thêm quy tắc cho ứng dụng", got: label(heading), ok: label(heading) == "Thêm quy tắc cho ứng dụng")
        check(d, p, "header x", h.minX, Reference.sheetMargin)
        if let field {
            let r = srel(field)
            check(d, p, "header centered on search", h.midY, r.midY)
            record(d, p, "header left of search", expected: "title ends before the field", got: "\(fmt(h.maxX)) / \(fmt(r.minX))", ok: h.maxX < r.minX)
        }
    }

    // The list card (outside the Form), then the Form with the "Khi đang gõ" card.
    let headerBottom = field.map { srel($0).maxY } ?? Reference.sheetMargin + Reference.sheetSearchHeight
    let listCard = srel(list)
    check(d, p, "list card", listCard, CGRect(x: Reference.sheetMargin, y: headerBottom + Reference.headerToCard,
                                              width: s.width - 2 * Reference.sheetMargin, height: Reference.sheetListHeight))
    let segmented = require(d, p, "segmented \"Khi đang gõ\"", find: {
        intended(all(sheet) { role($0) == "AXRadioGroup" }, text: "Khi đang gõ", label) })
    if let segmented {
        check(d, p, "segmented \"\(label(segmented))\" height", srel(segmented).height, Reference.controlHeight)
        record(d, p, "segmented label", expected: "Khi đang gõ", got: label(segmented), ok: label(segmented) == "Khi đang gõ")
    }
    // The Form: the tallest scroll area as wide as the sheet that holds no outline (no label).
    let form = require(d, p, "Form (\"Khi đang gõ\")", find: {
        all(sheet) { role($0) == "AXScrollArea" && near(frame($0).width, s.width) && all($0) { role($0) == "AXOutline" }.isEmpty }
            .max { frame($0).height < frame($1).height } })
    if let form, let card = require(d, p, "\"Khi đang gõ\" card", find: {
        // The topmost group: "Khi đang gõ" (groups have no label).
        children(form).filter { role($0) == "AXGroup" }.min { frame($0).minY < frame($1).minY } }) {
        let r = srel(card)
        check(d, p, "Khi đang gõ card", r, CGRect(x: Reference.sheetMargin, y: r.minY, width: s.width - 2 * Reference.sheetMargin, height: r.height))
        check(d, p, "list card → Khi đang gõ card", r.minY - listCard.maxY, Reference.cardGap)
    }

    // The button bar.
    let cancel = require(d, p, "Huỷ button", find: { sheetButton(sheet, "Huỷ") })
    let confirm = require(d, p, "Thêm button", find: { sheetButton(sheet, "Thêm") })
    let other = require(d, p, "Chọn ứng dụng khác… button", find: { sheetButton(sheet, "Chọn ứng dụng khác…") })
    let minWidth = Reference.sheetButtonMinWidth
    if let confirm {
        let a = srel(confirm)
        check(d, p, "Thêm height", a.height, Reference.sheetButtonHeight)
        record(d, p, "Thêm width", expected: "≥ \(fmt(minWidth))", got: fmt(a.width), ok: a.width >= minWidth - Reference.tolerance)
        check(d, p, "Thêm right margin", s.width - a.maxX, Reference.sheetMargin)
        check(d, p, "Thêm bottom margin", s.height - a.maxY, Reference.sheetMargin)
        if let form { check(d, p, "Form → buttons", a.minY - srel(form).maxY, Reference.sheetFormToButtons) }
        record(d, p, "Thêm without selection", expected: "disabled", got: enabled(confirm) ? "enabled" : "disabled", ok: !enabled(confirm))
    }
    if let cancel {
        let c = srel(cancel)
        check(d, p, "Huỷ height", c.height, Reference.sheetButtonHeight)
        record(d, p, "Huỷ width", expected: "≥ \(fmt(minWidth))", got: fmt(c.width), ok: c.width >= minWidth - Reference.tolerance)
        if let confirm {
            let a = srel(confirm)
            record(d, p, "Huỷ before Thêm", expected: "same line, left of Thêm", got: "\(fmt(c)) / \(fmt(a))", ok: near(c.minY, a.minY) && c.maxX < a.minX)
        }
    }
    if let other {
        let o = srel(other)
        check(d, p, "Chọn ứng dụng khác… x", o.minX, Reference.sheetMargin)
        if let confirm { check(d, p, "Chọn ứng dụng khác… y", o.minY, srel(confirm).minY) }
    }
    _ = screenshot(d, p, "apps-add-sheet-\(tag)", frames: ["sheet": frame(sheet).offsetBy(dx: -frame(window).minX, dy: -frame(window).minY)])

    // The list scrolls inside its card (the bug: a List nested in a grouped Form has its
    // scroller switched off; once, 3 rows and no scroll bar). /System/Applications alone
    // holds dozens of apps, so the list always overflows its card.
    guard let listArea = require(d, p, "app list scroll area", find: {
        // The smallest scroll area that holds the list.
        all(sheet) { role($0) == "AXScrollArea" && !all($0) { CFEqual($0, list) }.isEmpty }
            .min { frame($0).width * frame($0).height < frame($1).width * frame($1).height } })
    else { return }
    let rowsNow = appRows(sheet)
    let rowHeight = rowsNow.map { frame($0).height }.max() ?? 0
    let visibleHeight = frame(listArea).height
    record(d, p, "list overflows its card", expected: "rows taller than the card",
           got: "\(rowsNow.count) rows × \(fmt(rowHeight)) vs \(fmt(visibleHeight))", ok: CGFloat(rowsNow.count) * rowHeight > visibleHeight)
    let bar = requireShown(d, p, "list vertical scroll bar", within: 2,
                      diagnose: { "missing (the end-of-list checks need it and did not run)" }, find: {
        children(listArea).first { role($0) == "AXScrollBar" && string($0, kAXOrientationAttribute) == "AXVerticalOrientation" } })

    // A real mouse wheel over the list: the rows move up.
    if let firstRow = require(d, p, "first app row", find: { appRows(sheet).first }) {
        let before = frame(firstRow).minY
        let area = frame(listArea)
        let point = CGPoint(x: area.midX, y: area.midY)
        // The first wheel after the sheet opens can land before the window is under the
        // pointer (two of the first runs did not scroll; cause not found): up to 5 tries,
        // the count is in the row.
        var tries = 0
        while tries < 5 && frame(firstRow).minY >= before - 0.5 {
            tries += 1
            drive(d, p, "bring Dấu to the front", set(app, kAXFrontmostAttribute, kCFBooleanTrue))
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
        let moved = before - frame(firstRow).minY
        record(d, p, "list scrolls with the wheel", expected: "rows move up", got: "\(fmt(moved)) pt after \(tries) \(tries == 1 ? "try" : "tries")", ok: moved > 0.5)
    }

    // Apps every macOS install has (Reference.alwaysInstalledApps), by visible name. Rows
    // out of view may carry no text, so the list is stepped through with its scroll bar.
    let wanted = Set(Reference.alwaysInstalledApps)
    func visibleNames() -> Set<String> {
        Set(appRows(sheet).flatMap { all($0) { role($0) == "AXStaticText" }.map(label) })
    }
    var names = visibleNames(), positions = 1
    if let bar, !wanted.isSubset(of: names), rowsNow.count > 0, rowHeight > 0 {
        let inView = max(1, visibleHeight / rowHeight)
        let step = max(0.01, (inView - 1) / max(1, CGFloat(rowsNow.count) - inView))
        var value: CGFloat = 0
        while value < 1 + step && !wanted.isSubset(of: names) {
            drive(d, p, "scroll the list", set(bar, kAXValueAttribute, NSNumber(value: Double(min(value, 1)))))
            wait(0.25)
            names.formUnion(visibleNames())
            positions += 1
            value += step
        }
    }
    for name in Reference.alwaysInstalledApps {
        let found = names.contains(name)
        record(d, p, "lists \"\(name)\"", expected: "a row named \(name)",
               got: found ? "present" : "absent after \(positions) scroll positions (a rule stored for it hides it from the sheet)", ok: found)
    }

    // The scroll bar to the end: the last app comes fully into the card, "Khi đang gõ"
    // stays in the sheet; then back to the top.
    if let bar {
        let area = srel(listArea)
        func lastInView() -> Bool {
            guard let last = appRows(sheet).last else { return false }
            let r = srel(last)
            return r.minY >= area.minY - Reference.tolerance && r.maxY <= area.maxY + Reference.tolerance
        }
        // Rows are sized as they appear, so the end moves while they do: push again until
        // the last app is in view, at most 15 times; the count is in the row.
        var pushes = 0
        repeat {
            pushes += 1
            drive(d, p, "scroll the list to the end", set(bar, kAXValueAttribute, NSNumber(value: 1.0)))
            wait(0.4)
        } while !lastInView() && pushes < 15
        if let last = require(d, p, "last app row", find: { appRows(sheet).last }) {
            let r = srel(last)
            record(d, p, "last app visible at the end", expected: "inside \(fmt(area))", got: "\(fmt(r)) after \(pushes) \(pushes == 1 ? "push" : "pushes")",
                   ok: r.minY >= area.minY - Reference.tolerance && r.maxY <= area.maxY + Reference.tolerance)
        }
        if let segmented {
            let r = srel(segmented)
            record(d, p, "Khi đang gõ in view while scrolled", expected: "below the list, inside the sheet", got: fmt(r),
                   ok: r.minY > area.maxY && r.maxY < s.height)
        }
        _ = screenshot(d, p, "apps-add-sheet-bottom-\(tag)")
        drive(d, p, "scroll the list to the top", set(bar, kAXValueAttribute, NSNumber(value: 0.0)))
        wait(0.5)
    }

    // Search wiring (what matches is AddAppRuleSheetTests): a query no app matches leaves
    // no row; clearing it brings back every row the list settled on.
    if let field, drive(d, p, "type a query", set(field, kAXValueAttribute, "zzzz-no-such-app" as CFString)) {
        wait(0.8)
        check(d, p, "search with no match", CGFloat(appRows(sheet).count), 0, tolerance: Reference.exact)
        if drive(d, p, "clear the query", set(field, kAXValueAttribute, "" as CFString)) {
            wait(0.8)
            check(d, p, "search cleared", CGFloat(appRows(sheet).count), CGFloat(total), tolerance: Reference.exact)
        }
    }

    // Selection wiring: a selected row enables Thêm; a query that hides it disables Thêm,
    // and clearing the query leaves it off (the selection was dropped, so Return cannot add
    // an app out of view).
    guard let row = require(d, p, "first app row", find: { appRows(sheet).first }),
          drive(d, p, "select the first app", set(list, kAXSelectedRowsAttribute, [row] as CFArray)) else { return }
    wait(0.8)
    if let confirm {
        record(d, p, "Thêm with selection", expected: "enabled", got: enabled(confirm) ? "enabled" : "disabled", ok: enabled(confirm))
    }
    _ = screenshot(d, p, "apps-add-sheet-selected-\(tag)")
    if let field, let confirm,
       drive(d, p, "type a query", set(field, kAXValueAttribute, "zzzz-no-such-app" as CFString)) {
        wait(0.8)
        record(d, p, "Thêm after search hides selection", expected: "disabled", got: enabled(confirm) ? "enabled" : "disabled", ok: !enabled(confirm))
        if drive(d, p, "clear the query", set(field, kAXValueAttribute, "" as CFString)) {
            wait(0.8)
            record(d, p, "Thêm after search cleared", expected: "disabled", got: enabled(confirm) ? "enabled" : "disabled", ok: !enabled(confirm))
        }
    }
}

/// --sheet-shots: the sheet in this launch's appearance, empty and with a row selected.
func sheetShots(_ d: String, _ tag: String) {
    let p = sheetPage
    guard let sheet = openSheet(d) else { return }
    if settledAppCount(d, sheet) != nil, let list = require(d, p, "app list", find: { appList(sheet) }) {
        _ = screenshot(d, p, "apps-add-sheet-\(tag)")
        if let row = require(d, p, "first app row", find: { appRows(sheet).first }),
           drive(d, p, "select the first app", set(list, kAXSelectedRowsAttribute, [row] as CFArray)) {
            wait(0.8)
            _ = screenshot(d, p, "apps-add-sheet-selected-\(tag)")
        }
    }
    closeSheet(d)
}

// MARK: - Window limits (--geometry)

/// Resizes the window past its limits (item 1): it stops at Reference's widths and height.
/// At the widest, every section's first card still starts at the Form's margin and is as
/// wide as a grouped Form allows (no narrow centered column).
func measureLimits() {
    let d = "-", p = "window"
    guard drive(d, p, "resize the window", set(window, kAXSizeAttribute, axSize(Reference.probeLargeSize))) else { return }
    wait(0.6)
    check(d, p, "max window width", frame(window).width, Reference.maxWindowWidth)
    for index in sections.indices {
        let page = sections[index]
        guard showSection(d, index) else { continue }
        if let area = require(d, page, "page Form (scroll area in the detail column)", find: pageScrollArea),
           let card = require(d, page, "first card", find: { pageItems(area).first { $0.role == "AXGroup" } }) {
            record(d, page, "first card at the widest window", expected: "x \(fmt(sidebarWidth + formMargin)), width \(fmt(Reference.formCardMaxWidth))",
                   got: "x \(fmt(card.frame.minX)), width \(fmt(card.frame.width))",
                   ok: near(card.frame.minX, sidebarWidth + formMargin) && near(card.frame.width, Reference.formCardMaxWidth))
        }
    }
    guard drive(d, p, "resize the window", set(window, kAXSizeAttribute, axSize(Reference.probeSmallSize))) else { return }
    wait(0.6)
    check(d, p, "min window width", frame(window).width, Reference.minWindowWidth)
    // The content's minimum plus the toolbar.
    check(d, p, "min window height", frame(window).height, Reference.minWindowHeight)
    // Leave the default size: the app saves its frame, and the next launch must not open small.
    _ = drive(d, p, "restore the default window size", set(window, kAXSizeAttribute, axSize(Reference.windowSize)))
}

// MARK: - Legacy scroll bars (--pixels)

/// Per section: the scroll room rule (a) and a screenshot for check.swift (b), (c). On
/// Reference.scrollingSection: scrolled through its scroll bar, the bar's lane (d) and a
/// second screenshot (check.swift compares the header).
func measurePixels(_ d: String, _ tag: String) {
    for index in sections.indices {
        let page = sections[index]
        guard showSection(d, index),
              let area = require(d, page, "page Form (scroll area in the detail column)", find: pageScrollArea),
              let card = require(d, page, "first card", find: { pageItems(area).first { $0.role == "AXGroup" } }),
              let first = require(d, page, "first card or header", find: { pageItems(area).first })
        else { continue }
        let w = frame(window)
        let full = w.width - sidebarWidth - 2 * formMargin
        // (a) Legacy bars: only a page that needs one shows it; the page may get narrower
        // by exactly the system's legacy bar width, and nothing moves.
        check(d, page, "(a) first card x", card.frame.minX, sidebarWidth + formMargin)
        check(d, page, "(a) first item y", first.frame.minY, Reference.formFirstItemY)
        var shot: [String: CGRect] = ["column": rel(area), "firstCard": card.frame]
        let bar = pageScrollBar()
        if let bar {
            let r = rel(bar)
            shot["scroller"] = r
            // The bar's accessibility frame is not the lane the page gives up: it measured
            // 19 pt wide, reaching 1 pt past the window, against the system's 17 (03/11/2026).
            // So the bar's width is not compared; the card width below holds the lane rule.
            record(d, page, "(a) first card width with the scroll bar", expected: "\(fmt(full)) or \(fmt(full - legacyWidth)) (narrower by the bar)",
                   got: fmt(card.frame.width), ok: near(card.frame.width, full) || near(card.frame.width, full - legacyWidth))
        } else {
            check(d, page, "(a) first card width without a scroll bar", card.frame.width, full)
        }
        _ = screenshot(d, page, "\(page)-\(tag)", frames: shot)

        guard page == Reference.scrollingSection else { continue }
        // (d) Item 10: the page that overflows shows a scroll bar; scrolled through it, the
        // header keeps covering the content (check.swift) and the bar stays in its lane.
        guard let scrollBar = requireShown(d, page, "(d) scroll bar of the page that overflows",
                                      diagnose: { "missing (legacy bars show on overflowing pages; the scrolled checks did not run)" },
                                      find: { bar }) else { continue }
        // How far the page moved: the item nearest the column's middle, which stays in view.
        let column = rel(area)
        guard let anchor = require(d, page, "(d) item in the middle of the page", find: {
            pageItems(area).min { abs($0.frame.midY - column.midY) < abs($1.frame.midY - column.midY) } })
        else { continue }
        func offset() -> CGFloat? {
            let r = rel(anchor.element)
            return r.height > 0 ? anchor.frame.minY - r.minY : nil
        }
        // The bar's value is a fraction of the scrollable height: try a tenth, then scale
        // to the probe offset.
        guard drive(d, page, "scroll the page", set(scrollBar, kAXValueAttribute, NSNumber(value: 0.1))) else { continue }
        wait(0.5)
        if let tenth = offset(), tenth > 0.5 {
            let value = min(1, 0.1 * Reference.scrollProbeOffset / tenth)
            drive(d, page, "scroll the page", set(scrollBar, kAXValueAttribute, NSNumber(value: Double(value))))
            wait(0.5)
        }
        guard let scrolled = offset() else {
            harness(d, page, "(d) page scrolls with its bar", expected: "≥ \(fmt(Reference.scrollProbeMinOffset)) pt",
                    got: "the item measured before scrolling is gone from the accessibility tree")
            continue
        }
        record(d, page, "(d) page scrolls with its bar", expected: "≥ \(fmt(Reference.scrollProbeMinOffset)) pt",
               got: "\(fmt(scrolled)) pt", ok: scrolled >= Reference.scrollProbeMinOffset)
        let lane = rel(scrollBar)
        record(d, page, "(d) scroll bar lane", expected: "right \(fmt(Reference.scrollerLane)) pt of the window, below y \(fmt(Reference.scrollerMinY))",
               got: fmt(lane), ok: lane.maxX <= w.width + Reference.tolerance && lane.minX >= w.width - Reference.scrollerLane
                && lane.minY >= Reference.scrollerMinY)
        var scrolledShot = shot
        scrolledShot["scroller"] = lane
        _ = screenshot(d, page, "\(page)-scrolled-\(tag)", frames: scrolledShot)
        drive(d, page, "scroll the page back", set(scrollBar, kAXValueAttribute, NSNumber(value: 0.0)))
        wait(0.3)
    }
}

// MARK: - Banner (--banner)

/// The app runs with --not-enabled: the "Dấu chưa được bật" banner is the first card of
/// Gõ phím and spans the column like any card.
func measureBanner(_ d: String, _ tag: String) {
    let page = sections[0]
    guard showSection(d, 0),
          let area = require(d, page, "page Form (scroll area in the detail column)", find: pageScrollArea),
          let card = require(d, page, "first card", find: { pageItems(area).first { $0.role == "AXGroup" } })
    else { return }
    let titles = ["Bật lại", "Mở Cài đặt Bàn phím…"]
    let buttons = all(card.element) { role($0) == "AXButton" }.map(label)
    record(d, page, "banner first", expected: "first card holds \(titles.joined(separator: " or "))",
           got: buttons.isEmpty ? "no button" : buttons.joined(separator: ", "), ok: buttons.contains { titles.contains($0) })
    let w = frame(window)
    check(d, page, "banner card", card.frame, CGRect(x: sidebarWidth + formMargin, y: Reference.formFirstItemY,
                                                    width: w.width - sidebarWidth - 2 * formMargin, height: card.frame.height))
    _ = screenshot(d, page, "typing-banner-\(tag)", frames: ["firstCard": card.frame])
}

// MARK: - Run

// One pass per backing scale, the primary display first.
var seenScales = Set<CGFloat>()
let displays = NSScreen.screens.filter { seenScales.insert($0.backingScaleFactor).inserted }
guard let primary = NSScreen.screens.first else { harnessAbort("displays", expected: "at least one", got: "none") }
func tag(_ screen: NSScreen) -> String { "\(fmt(screen.backingScaleFactor))x" }

if modes.contains("--geometry") {
    check("-", "window", "window size at launch", CGRect(origin: .zero, size: launchSize), CGRect(origin: .zero, size: Reference.windowSize))
    for screen in displays where moveWindow(to: screen, tag(screen)) {
        for index in sections.indices { measureSection(tag(screen), tag(screen), index) }
        measureSidebarSearch(tag(screen), tag(screen))
        measureSheet(tag(screen), tag(screen))
    }
    measureLimits()
}
if modes.contains("--pixels") || modes.contains("--banner") || modes.contains("--sheet-shots"),
   moveWindow(to: primary, tag(primary)) {
    if modes.contains("--pixels") { measurePixels(tag(primary), tag(primary)) }
    if modes.contains("--banner") { measureBanner(tag(primary), tag(primary)) }
    if modes.contains("--sheet-shots") { sheetShots(tag(primary), tag(primary)) }
}

shots["meta"] = ["primaryScale": [Double(primary.backingScaleFactor)], "dark": [appearance == "dark" ? 1 : 0]]
if let data = try? JSONSerialization.data(withJSONObject: shots, options: [.sortedKeys, .prettyPrinted]) {
    try? data.write(to: outDir.appendingPathComponent("frames.json"))
}

print("display | page | metric | expected | Dấu | result")
rows.forEach { print($0) }
failures.forEach { print("FAIL", $0) }
harnessProblems.forEach { print("HARNESS", $0) }
if !harnessProblems.isEmpty { print("\(harnessProblems.count) harness problem(s): the checker could not do its part; not a UI result.") }
if !failures.isEmpty { print("\(failures.count) real-window check(s) failed.") }
if failures.isEmpty && harnessProblems.isEmpty { print("Real-window checks passed (\(rows.count)).") }
exit(failures.isEmpty && harnessProblems.isEmpty ? 0 : 1)
