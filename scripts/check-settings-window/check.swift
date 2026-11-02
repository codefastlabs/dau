// Checks the captures written by `Dau --capture-window` (see run.sh, docs/UI-CHECKS.md).
// Window 740×560 pt (System Settings' size), captures @2x, frames in top-left window
// points. Reference numbers: docs/research/SYSTEM-SETTINGS-REFERENCE.md. The real
// window is checked separately by ax-check.swift.
import AppKit

let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let sections = ["typing", "smart", "apps", "updates"]
let modes = ["light", "dark"]
let styles = ["WhenScrolling", "Always", "Automatic"]
let scrolls = ["0", "60"]
let W: CGFloat = 740, H: CGFloat = 560
/// System Settings' sidebar column, and the grouped Form's margins.
let sidebar: CGFloat = 232, formMargin: CGFloat = 20, rowInset: CGFloat = 10

typealias Frames = [String: CGRect]
struct Pixel { var r, g, b: Double
    func distance(_ o: Pixel) -> Double { max(abs(r - o.r), abs(g - o.g), abs(b - o.b)) }
}

func loadFrames(_ dir: URL) -> [String: Frames] {
    guard let data = try? Data(contentsOf: dir.appendingPathComponent("frames.json")),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [Double]]] else { return [:] }
    var out: [String: Frames] = [:]
    for (key, entries) in json where !key.hasPrefix("colors") && !key.hasPrefix("limits") {
        var frames: Frames = [:]
        for (name, v) in entries where v.count == 4 { frames[name] = CGRect(x: v[0], y: v[1], width: v[2], height: v[3]) }
        out[key] = frames
    }
    return out
}

func image(_ url: URL) -> NSBitmapImageRep? {
    guard let data = try? Data(contentsOf: url) else { return nil }
    return NSBitmapImageRep(data: data)
}

func pixel(_ rep: NSBitmapImageRep, _ x: CGFloat, _ y: CGFloat) -> Pixel {
    let scale = CGFloat(rep.pixelsWide) / W
    var p = [Int](repeating: 0, count: 4)
    rep.getPixel(&p, atX: min(max(Int(x * scale), 0), rep.pixelsWide - 1),
                 y: min(max(Int(y * scale), 0), rep.pixelsHigh - 1))
    return Pixel(r: Double(p[0]), g: Double(p[1]), b: Double(p[2]))
}

var failures: [String] = []
var results: [(String, String, [String: Bool])] = []   // run, mode, check → pass
func fail(_ s: String) { failures.append(s) }

for style in styles {
    for scroll in scrolls {
        let run = "\(style)-\(scroll)"
        let dir = root.appendingPathComponent(run)
        let frames = loadFrames(dir)
        for mode in modes {
            var checks: [String: Bool] = ["a": true, "b": true, "c": true, "d": true, "e": true]
            func bad(_ check: String, _ message: String) { checks[check] = false; fail("\(run) \(mode) (\(check)) \(message)") }

            // (a) Same frames in every section. Positions (x, y) must be equal; widths
            // may differ only by the legacy scroll bar's width, and only on a section
            // that shows one (its clip view is narrower than its scroll view).
            let legacyWidth = NSScroller.scrollerWidth(for: .regular, scrollerStyle: .legacy)
            func room(_ section: String) -> CGFloat? {
                guard let f = frames["\(section)-\(mode)"], let sv = f["scrollView"], let clip = f["clip"] else { return nil }
                return sv.width - clip.width
            }
            for section in sections {
                if let r = room(section), abs(r) > 0.5, abs(r - legacyWidth) > 0.5 {
                    bad("a", "\(section) scroll bar takes \(r) pt, not the legacy width \(legacyWidth)")
                }
            }
            func same(_ name: String, width: Bool, y: Bool = true) {
                var values: [String] = []
                for section in sections {
                    guard let r = frames["\(section)-\(mode)"]?[name] else { continue }
                    let w = width ? r.width + (room(section) ?? 0) : 0
                    values.append("\(r.minX),\(y ? r.minY : 0),\(w)")
                }
                if values.count != sections.count { bad("a", "\(name) missing"); return }
                if Set(values).count > 1 { bad("a", "\(name) differs (x, y, width + scroll bar): \(values)") }
            }
            same("content", width: true)
            // The first row's y depends on whether the page starts with a section header.
            same("firstRow", width: true, y: false)
            same("title", width: false)
            same("close", width: false)
            if Set(sections.compactMap { frames["\($0)-\(mode)"]?["close"] }).count > 1 { bad("a", "close size differs") }

            for section in sections {
                let key = "\(section)-\(mode)"
                guard let f = frames[key], let rep = image(dir.appendingPathComponent("\(key).png")) else {
                    bad("a", "\(key) capture missing"); continue
                }
                let scroller = f["scroller"].flatMap { $0.width > 0 ? $0 : nil }
                // Page color: the Form's left margin, between the sidebar and the cards.
                let low = H - 40
                let page = pixel(rep, sidebar + formMargin / 2, low)

                // (b) Page background reaches the right edge (or the system scroll bar,
                // which then sits at the edge), and the toolbar band is one color from
                // the middle to the right edge.
                let edgeX = (scroller.map { $0.minX <= W - 10 && $0.maxY > low } ?? false) ? scroller!.minX - 2 : W - 2
                if page.distance(pixel(rep, edgeX, low)) > 6 {
                    bad("b", "\(key) page color stops before the right edge (x \(edgeX))")
                }
                if let s = scroller, s.maxX < W - 0.5 {
                    bad("b", "\(key) scroll bar ends at \(s.maxX), not at the window edge")
                }
                if section != "apps" {   // the Apps toolbar holds the search field there
                    let mid = pixel(rep, (sidebar + W) / 2 + 60, 44), edge = pixel(rep, W - 3, 44)
                    if mid.distance(edge) > 6 { bad("b", "\(key) toolbar color differs at the right edge") }
                }

                // (c) No strip of another color in the Form's right margin, except the
                // scroll bar.
                var stray = 0
                for x in stride(from: W - formMargin + 2, to: W, by: 1) {
                    for y in stride(from: 64, to: H - 40, by: 16) {
                        if let s = scroller, s.insetBy(dx: -1, dy: -1).contains(CGPoint(x: x, y: y)) { continue }
                        if pixel(rep, x, y).distance(page) > 6 { stray += 1 }
                    }
                }
                if stray > 0 { bad("c", "\(key) \(stray) right-margin samples differ from the page color") }

                // (d) Scrolled: the header looks as when not scrolled; scroll bar inside
                // the window right below the header.
                if scroll != "0", section == "updates" {
                    if let base = image(root.appendingPathComponent("\(style)-0/\(key).png")) {
                        var diff = 0.0, n = 0.0
                        // Right of the page title ("Cập nhật & hỗ trợ" ends near x 380): the
                        // off-screen window sometimes lays the whole toolbar out half a
                        // point apart between runs, which moves the title's pixels.
                        for x in stride(from: CGFloat(400), to: W - 24, by: 6) {
                            for y in stride(from: CGFloat(6), to: 46, by: 4) {
                                diff += pixel(rep, x, y).distance(pixel(base, x, y)); n += 1
                            }
                        }
                        if diff / n > 4 { bad("d", "\(key) content shows through the header (mean diff \(Int(diff / n)))") }
                    }
                    if let s = scroller {
                        if s.maxX > W + 0.5 || s.minX < W - 20 || s.minY < 51 { bad("d", "\(key) scroll bar at \(s)") }
                    } else {
                        bad("d", "\(key) no scroll bar")
                    }
                }

                // (e) Traffic lights, title, first row, Apps search field and + button.
                // System Settings: lights at 18,18 16×16 (AX), i.e. 19,19 14×14 drawn;
                // title text from the detail column's margin (232 + 20), centered in
                // the 52 pt toolbar.
                if f["close"] != CGRect(x: 19, y: 19, width: 14, height: 14) { bad("e", "\(key) close at \(String(describing: f["close"]))") }
                if let t = f["title"], abs(t.minX - (sidebar + formMargin)) > 1 || abs(t.midY - 26) > 1 { bad("e", "\(key) title at \(t)") }
                if f["title"] == nil { bad("e", "\(key) title missing") }
                // Item 1: the cards span the column with the Form's margins (no narrow
                // centered column): first row = card inset by the row's 10 pt.
                if let r = f["firstRow"], let c = f["content"] {
                    let card = c.width - 2 * formMargin
                    if abs(r.minX - (c.minX + formMargin + rowInset)) > 0.5 || abs(r.width - (card - 2 * rowInset)) > 0.5 {
                        bad("e", "\(key) first row at \(r), content \(c)")
                    }
                }
                if section == "apps" {
                    // Native toolbar controls: the "+" (round) then the system search
                    // field at the trailing edge, both right of the title.
                    guard let s = f["headerSearch"], let a = f["headerAdd"] else { bad("e", "\(key) header controls missing"); continue }
                    if abs(a.width - a.height) > 0.5 { bad("e", "\(key) + not round: \(a)") }
                    if a.minX < (f["title"]?.maxX ?? W) + 8 || a.maxX > s.minX { bad("e", "\(key) + at \(a), search at \(s)") }
                    if s.maxX > W - 4 || s.maxX < W - 24 || s.height < 24 { bad("e", "\(key) search at \(s)") }
                }
            }
            results.append((run, mode, checks))
        }
    }
}

// Summary grid: one row per run, light then dark of each section, quarter size.
let cellW = Int(W / 2), cellH = Int(H / 2)
let rows = styles.count * scrolls.count, cols = sections.count * modes.count
if let grid = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cellW * cols, pixelsHigh: cellH * rows,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) {
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: grid)
    for (r, run) in styles.flatMap({ s in scrolls.map { "\(s)-\($0)" } }).enumerated() {
        for (c, item) in modes.flatMap({ m in sections.map { ($0, m) } }).enumerated() {
            let url = root.appendingPathComponent("\(run)/\(item.0)-\(item.1).png")
            NSImage(contentsOf: url)?.draw(in: CGRect(x: c * cellW, y: (rows - 1 - r) * cellH, width: cellW, height: cellH))
        }
    }
    NSGraphicsContext.restoreGraphicsState()
    try? grid.representation(using: .png, properties: [:])?.write(to: root.appendingPathComponent("matrix-grid.png"))
}

// (h) Item 1 at the window's limits: the window stops at sidebar + 744 pt wide (a
// grouped Form caps its cards at 704 pt and centers them in a wider column) and does
// not get narrower than System Settings' 740; at the widest the first row still starts
// at the Form's margin and spans the column (Dau --capture-window --width 976).
let maxWidth = sidebar + 744, minWidth: CGFloat = 740
var limitResults: [(String, Bool)] = []
do {
    let dir = root.appendingPathComponent("wide")
    let frames = loadFrames(dir)
    let json = (try? Data(contentsOf: dir.appendingPathComponent("frames.json")))
        .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] } ?? [:]
    for mode in modes {
        var ok = true
        func bad(_ message: String) { ok = false; fail("wide \(mode) (h) \(message)") }
        if let limits = json["limits-\(mode)"] as? [String: [Double]], let mn = limits["min"], let mx = limits["max"] {
            if abs(mx[0] - maxWidth) > 0.5 { bad("max width \(mx[0]), not \(maxWidth)") }
            if abs(mn[0] - minWidth) > 0.5 { bad("min width \(mn[0]), not \(minWidth)") }
        } else {
            bad("no window limits")
        }
        for section in sections {
            guard let r = frames["\(section)-\(mode)"]?["firstRow"], let c = frames["\(section)-\(mode)"]?["content"] else {
                bad("\(section) frames missing"); continue
            }
            if abs(c.width - 744) > 0.5 { bad("\(section) content \(c), not 744 wide") }
            if abs(r.minX - (sidebar + formMargin + rowInset)) > 0.5 || abs(r.width - (744 - 2 * formMargin - 2 * rowInset)) > 0.5 {
                bad("\(section) first row at \(r)")
            }
        }
        limitResults.append((mode, ok))
    }
}

// (f) Onboarding window (Dau --capture-onboarding, run.sh): 720×500, mockup positions
// ("OnboardingConflict", "OnboardingEnable", "Onboarding"; window at 50,40 in the
// artboard), the same in every step and both modes.
var onboardingResults: [(String, Bool)] = []
for dirName in ["onboarding", "onboarding-no-shortcut"] {
    let frames = loadFrames(root.appendingPathComponent(dirName))
    if frames.isEmpty { fail("\(dirName): no frames.json"); continue }
    for key in frames.keys.sorted() {
        let f = frames[key]!
        var ok = true
        func bad(_ message: String) { ok = false; fail("\(dirName)/\(key) (f) \(message)") }
        func near(_ a: CGFloat?, _ b: CGFloat, _ tolerance: CGFloat = 1) -> Bool { a.map { abs($0 - b) <= tolerance } ?? false }
        if f["window"]?.size != CGSize(width: 720, height: 500) { bad("window \(String(describing: f["window"]))") }
        if !near(f["onbAppName"]?.minX, 20) || !near(f["onbAppName"]?.minY, 50) { bad("app name at \(String(describing: f["onbAppName"]))") }
        if !near(f["onbTitle"]?.minX, 266) || !near(f["onbTitle"]?.minY, 40, 2) { bad("title at \(String(describing: f["onbTitle"]))") }
        if !near(f["onbCard"]?.minX, 266) || !near(f["onbCard"]?.width, 418) { bad("card at \(String(describing: f["onbCard"]))") }
        if !near(f["onbButtons"]?.maxX, 684) || !near(f["onbButtons"]?.maxY, 472) { bad("buttons at \(String(describing: f["onbButtons"]))") }
        onboardingResults.append(("\(dirName)/\(key)", ok))
    }
}

// (g) Uninstall alerts (Dau --capture-uninstall): both alerts captured as sheets in
// both modes, at an alert's size.
var uninstallResults: [(String, Bool)] = []
do {
    let dir = root.appendingPathComponent("uninstall")
    let frames = loadFrames(dir)
    for key in ["confirm", "done"].flatMap({ k in ["light", "dark"].map { "uninstall-\(k)-\($0)" } }) {
        var ok = true
        if let sheet = frames[key]?["sheet"], sheet.width >= 200, sheet.height >= 120,
           image(dir.appendingPathComponent("\(key).png")) != nil {
        } else {
            ok = false
            fail("uninstall/\(key) (g) missing or sheet too small: \(String(describing: frames[key]?["sheet"]))")
        }
        uninstallResults.append((key, ok))
    }
}

print("run | mode | a frames | b to edge | c no strip | d scrolled | e positions")
for (run, mode, c) in results {
    print(([run, mode] + ["a", "b", "c", "d", "e"].map { c[$0]! ? "ok" : "FAIL" }).joined(separator: " | "))
}
print("window limits | h wide")
for (mode, ok) in limitResults { print("wide \(mode) | \(ok ? "ok" : "FAIL")") }
print("onboarding | f positions")
for (key, ok) in onboardingResults { print("\(key) | \(ok ? "ok" : "FAIL")") }
print("uninstall | g captured")
for (key, ok) in uninstallResults { print("\(key) | \(ok ? "ok" : "FAIL")") }
failures.forEach { print("FAIL", $0) }
print(failures.isEmpty ? "All UI checks passed." : "\(failures.count) check(s) failed.")
exit(failures.isEmpty ? 0 : 1)
