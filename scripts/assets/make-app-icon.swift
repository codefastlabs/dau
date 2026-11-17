// Builds the source files of the Dấu app icons: the two Icon Composer documents
// (Apps/Dau/Resources/AppIcon.icon, AppIconDev.icon) and the flat SVGs in Resources/Brand/.
//
// Standard icon (docs/Brand.md "Biểu tượng", D25): "ấ" in Giấy on a Mực plate, the circumflex in
// the letter colour and only the acute in Son. Development icon (docs/Brand.md "Biểu tượng bản
// phát triển", D25): the same letter on a Chì plate with a Hổ phách diagonal stripe across the
// bottom-right corner (mockup polygon 52,100 100,52 100,74 74,100), outside the "a".
//
// Geometry follows the canvas mockup "Nhận diện – biểu tượng ứng dụng" (a 100 × 100 design):
//   letter "a"   Be Vietnam Pro Bold (700), size 64, centred on x = 48, baseline y = 80
//   circumflex   stroke M34 35 L47 25 L60 35, width 7, round caps and joins, Giấy
//   acute        stroke M63 24 L73 13, width 7.5, round caps, Son
//
// Icon Composer documents. The plate is not a layer but the document's background fill, and
// macOS cuts the plate shape itself, so the layers are drawn on the whole 1024 canvas: the
// mockup's 100 grid maps to 0…1024 (the flat SVGs keep the 824 pt plate of the macOS icon grid
// inside a 1024 canvas). Each layer is one outlined path in its own SVG, so no font is needed
// when Xcode compiles it. The Dark appearance is a second fill (for the plate, and for
// the stripe of the development icon); Clear and Tinted are derived by macOS from the layers.
// One document has one set of shapes for every size, so there are no thicker-mark variants
// for 16–32 pt.
//
// Only the letter comes from the font: its contours are extracted once into
// Resources/Brand/app-icon-glyphs.txt, so rendering never needs the font (never commit the
// font file).
//
// Usage (normally via scripts/assets/make-app-icon.sh):
//   make-app-icon.swift outline <BeVietnamPro-Bold.ttf> <glyphs.txt>
//       Extract the contours and advance width of "a" in font units, y up.
//   make-app-icon.swift render <glyphs.txt> <svg-dir> <icon-dir>
//       Write AppIcon.svg and AppIconDev.svg to <svg-dir>, and AppIcon.icon and AppIconDev.icon
//       to <icon-dir>.

import CoreGraphics
import CoreText
import Foundation

// MARK: - Path model (canvas space: 1024 × 1024, y down, like SVG)

enum Cmd {
    case move(CGPoint)
    case line(CGPoint)
    case quad(CGPoint, CGPoint)            // control, end
    case cubic(CGPoint, CGPoint, CGPoint)  // control 1, control 2, end
    case close
}

typealias Path = [Cmd]

func fmt(_ v: CGFloat) -> String {
    let r = (v * 100).rounded() / 100
    if r == r.rounded() { return String(Int(r)) }
    return String(format: "%.2f", Double(r))
        .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
}

func svgData(_ path: Path) -> String {
    func p(_ q: CGPoint) -> String { "\(fmt(q.x)) \(fmt(q.y))" }
    return path.map { c -> String in
        switch c {
        case .move(let a): return "M\(p(a))"
        case .line(let a): return "L\(p(a))"
        case .quad(let c1, let a): return "Q\(p(c1)) \(p(a))"
        case .cubic(let c1, let c2, let a): return "C\(p(c1)) \(p(c2)) \(p(a))"
        case .close: return "Z"
        }
    }.joined(separator: " ")
}

/// Parses the absolute M/L/Q/C/Z subset written by `svgData`.
func parse(_ d: String) -> Path {
    var tokens: [String] = []
    var cur = ""
    for ch in d {
        if "MLQCZ".contains(ch) {
            if !cur.isEmpty { tokens.append(cur); cur = "" }
            tokens.append(String(ch))
        } else if ch == " " || ch == "," {
            if !cur.isEmpty { tokens.append(cur); cur = "" }
        } else {
            cur.append(ch)
        }
    }
    if !cur.isEmpty { tokens.append(cur) }
    var i = 0
    func num() -> CGFloat {
        defer { i += 1 }
        guard let v = Double(tokens[i]) else { fatalError("bad number \(tokens[i])") }
        return CGFloat(v)
    }
    func pt() -> CGPoint { let x = num(); return CGPoint(x: x, y: num()) }
    var out: Path = []
    while i < tokens.count {
        let op = tokens[i]; i += 1
        switch op {
        case "M": out.append(.move(pt()))
        case "L": out.append(.line(pt()))
        case "Q": let c = pt(); out.append(.quad(c, pt()))
        case "C": let c1 = pt(); let c2 = pt(); out.append(.cubic(c1, c2, pt()))
        case "Z": out.append(.close)
        default: fatalError("unsupported path command \(op)")
        }
    }
    return out
}

func transform(_ path: Path, _ f: (CGPoint) -> CGPoint) -> Path {
    path.map { c in
        switch c {
        case .move(let a): return .move(f(a))
        case .line(let a): return .line(f(a))
        case .quad(let c1, let a): return .quad(f(c1), f(a))
        case .cubic(let c1, let c2, let a): return .cubic(f(c1), f(c2), f(a))
        case .close: return .close
        }
    }
}

func cgPath(_ path: Path) -> CGPath {
    let p = CGMutablePath()
    for c in path {
        switch c {
        case .move(let a): p.move(to: a)
        case .line(let a): p.addLine(to: a)
        case .quad(let c1, let a): p.addQuadCurve(to: a, control: c1)
        case .cubic(let c1, let c2, let a): p.addCurve(to: a, control1: c1, control2: c2)
        case .close: p.closeSubpath()
        }
    }
    return p
}

func path(_ cg: CGPath) -> Path {
    var out: Path = []
    cg.applyWithBlock { e in
        let el = e.pointee
        switch el.type {
        case .moveToPoint: out.append(.move(el.points[0]))
        case .addLineToPoint: out.append(.line(el.points[0]))
        case .addQuadCurveToPoint: out.append(.quad(el.points[0], el.points[1]))
        case .addCurveToPoint: out.append(.cubic(el.points[0], el.points[1], el.points[2]))
        case .closeSubpath: out.append(.close)
        @unknown default: break
        }
    }
    return out
}

func bounds(_ path: Path) -> CGRect { cgPath(path).boundingBoxOfPath }

// MARK: - outline: font → glyph contours

func outline(fontURL: URL, out: URL) throws {
    guard let descs = CTFontManagerCreateFontDescriptorsFromURL(fontURL as CFURL) as? [CTFontDescriptor],
          let desc = descs.first else { fatalError("cannot read font \(fontURL.path)") }
    let upm = CGFloat(CTFontGetUnitsPerEm(CTFontCreateWithFontDescriptor(desc, 1, nil)))
    let font = CTFontCreateWithFontDescriptor(desc, upm, nil)  // 1 point = 1 font unit
    var chars = Array("a".utf16)
    var glyphs = [CGGlyph](repeating: 0, count: chars.count)
    guard CTFontGetGlyphsForCharacters(font, &chars, &glyphs, chars.count),
          let glyphPath = CTFontCreatePathForGlyph(font, glyphs[0], nil) else {
        fatalError("font has no glyph for a")
    }
    let advance = CTFontGetAdvancesForGlyphs(font, .horizontal, glyphs, nil, 1)
    let name = CTFontCopyFullName(font) as String
    let version = (CTFontCopyName(font, kCTFontVersionNameKey) as String?) ?? "?"
    let text = """
    # Outline of "a" from \(name) (\(version)), SIL Open Font License 1.1,
    # https://github.com/bettergui/BeVietnamPro (via github.com/google/fonts, ofl/bevietnampro).
    # Font units (\(Int(upm))/em), y up, baseline 0. Generated by
    # scripts/assets/make-app-icon.sh outline; the font file is not part of the repo.
    em \(fmt(upm))
    advance \(fmt(advance))
    a \(svgData(path(glyphPath)))

    """
    try text.write(to: out, atomically: true, encoding: .utf8)
    print("wrote \(out.path)")
}

// MARK: - Geometry

// macOS (Big Sur and later) icon grid: 824 × 824 plate centred on the 1024 canvas,
// continuous ("squircle") corners with radius ≈ 185.4 (mockup: rx 22.4 on 100 ≈ 184.6).
// Used by the flat SVGs; the Icon Composer documents fill the whole canvas.
let plateRect = CGRect(x: 100, y: 100, width: 824, height: 824)
let plateRadius: CGFloat = 185.4

/// Mockup 100 × 100 design space → flat SVG canvas (plate on the macOS grid).
let grid = plateRect.width / 100
func fromGrid(_ p: CGPoint) -> CGPoint {
    CGPoint(x: plateRect.minX + grid * p.x, y: plateRect.minY + grid * p.y)
}

/// Flat SVG canvas → Icon Composer canvas (the plate fills the 1024 square).
func toDocument(_ p: CGPoint) -> CGPoint {
    let k = 1024 / plateRect.width
    return CGPoint(x: (p.x - plateRect.minX) * k, y: (p.y - plateRect.minY) * k)
}

/// Rounded rect with continuous corners (the iOS 7+/macOS 11+ shape), y down.
/// Control points follow the widely published reconstruction of UIBezierPath's
/// continuous-corner curve; extent of each corner is 1.52866 × radius.
func squircle(_ r: CGRect, radius: CGFloat) -> Path {
    let k = min(radius, min(r.width, r.height) / 2 / 1.52866483)
    func tl(_ a: CGFloat, _ b: CGFloat) -> CGPoint { CGPoint(x: r.minX + a * k, y: r.minY + b * k) }
    func tr(_ a: CGFloat, _ b: CGFloat) -> CGPoint { CGPoint(x: r.maxX - a * k, y: r.minY + b * k) }
    func br(_ a: CGFloat, _ b: CGFloat) -> CGPoint { CGPoint(x: r.maxX - a * k, y: r.maxY - b * k) }
    func bl(_ a: CGFloat, _ b: CGFloat) -> CGPoint { CGPoint(x: r.minX + a * k, y: r.maxY - b * k) }
    typealias F = (CGFloat, CGFloat) -> CGPoint
    // One corner, from one edge to the next; `swap` mirrors the corner for the corners that
    // start on a vertical edge.
    func corner(_ f: F, swap: Bool) -> Path {
        func q(_ a: CGFloat, _ b: CGFloat) -> CGPoint { swap ? f(b, a) : f(a, b) }
        return [
            .cubic(q(1.08849323, 0), q(0.86840689, 0), q(0.66993427, 0.06549600)),
            .line(q(0.63149399, 0.07491100)),
            .cubic(q(0.37282392, 0.16905899), q(0.16906013, 0.37282401), q(0.07491176, 0.63149399)),
            .cubic(q(0, 0.86840701), q(0, 1.08849299), q(0, 1.52866483)),
        ]
    }
    var p: Path = [.move(tl(1.52866483, 0)), .line(tr(1.52866483, 0))]
    p += corner(tr, swap: false)
    p.append(.line(br(0, 1.52866483)))
    p += corner(br, swap: true)
    p.append(.line(bl(1.52866483, 0)))
    p += corner(bl, swap: false)
    p.append(.line(tl(0, 1.52866483)))
    p += corner(tl, swap: true)
    p.append(.close)
    return p
}

struct Colour {
    let hex: String
    var rgb: (r: Double, g: Double, b: Double) {
        let v = Int(hex.dropFirst(), radix: 16)!
        return (Double((v >> 16) & 0xFF) / 255, Double((v >> 8) & 0xFF) / 255, Double(v & 0xFF) / 255)
    }
    /// Icon Composer's colour syntax.
    var iconColour: String { String(format: "srgb:%.5f,%.5f,%.5f,1.00000", rgb.r, rgb.g, rgb.b) }
}

// docs/Brand.md "Màu".
let muc = Colour(hex: "#10285A")          // Mực: plate
let mucDark = Colour(hex: "#0B0F1A")      // Mực, kiểu Tối (mockup "Nhận diện – biểu tượng ứng dụng")
let giay = Colour(hex: "#F6F1E7")         // Giấy: letter and circumflex
let son = Colour(hex: "#E0533D")          // Son: acute only
let chi = Colour(hex: "#2C2F35")          // Chì: development plate
let chiDark = Colour(hex: "#1A1B1F")
let hoPhach = Colour(hex: "#F2B705")      // Hổ phách: development stripe
let hoPhachDark = Colour(hex: "#D9A400")

struct Layer {
    let id: String
    let path: Path
    let fill: Colour
}

struct Glyph {
    let em: CGFloat
    let advance: CGFloat
    let a: Path
}

// Mockup letter placement (grid units).
let letterSize: CGFloat = 64
let letterCentreX: CGFloat = 48
let letterBaseline: CGFloat = 80
let circumflexWidth: CGFloat = 7
let acuteWidth: CGFloat = 7.5

/// Outlines a round-capped polyline given in grid units (flat SVG canvas).
func outlinedStroke(_ points: [CGPoint], width: CGFloat) -> Path {
    let line = CGMutablePath()
    line.addLines(between: points.map(fromGrid))
    return path(line.copy(strokingWithWidth: width * grid, lineCap: .round, lineJoin: .round, miterLimit: 10))
}

/// The letter and its two marks, bottom to top, on the flat SVG canvas.
func glyphLayers(_ g: Glyph) -> [Layer] {
    // SVG text-anchor="middle" centres the advance box on x.
    let k = letterSize / g.em
    let originX = letterCentreX - k * g.advance / 2
    let a = transform(g.a) { p in
        fromGrid(CGPoint(x: originX + k * p.x, y: letterBaseline - k * p.y))
    }
    return [
        Layer(id: "a", path: a, fill: giay),
        Layer(id: "circumflex",
              path: outlinedStroke([CGPoint(x: 34, y: 35), CGPoint(x: 47, y: 25), CGPoint(x: 60, y: 35)],
                                   width: circumflexWidth),
              fill: giay),
        Layer(id: "acute",
              path: outlinedStroke([CGPoint(x: 63, y: 24), CGPoint(x: 73, y: 13)], width: acuteWidth),
              fill: son),
    ]
}

let stripeGrid: [CGPoint] = [(52, 100), (100, 52), (100, 74), (74, 100)].map { CGPoint(x: $0.0, y: $0.1) }

func stripePath(_ map: (CGPoint) -> CGPoint) -> Path {
    let pts = stripeGrid.map(map)
    var p: Path = [.move(pts[0])]
    for q in pts.dropFirst() { p.append(.line(q)) }
    p.append(.close)
    return p
}

// Drop shadow under the plate of the flat SVGs, as on the macOS icon template.
let shadowOffsetY: CGFloat = 10
let shadowBlur: CGFloat = 20
let shadowAlpha: CGFloat = 0.30

// MARK: - Flat SVG

func flatSVG(_ g: Glyph, dev: Bool) -> String {
    let plate = squircle(plateRect, radius: plateRadius)
    var lines = [
        #"<?xml version="1.0" encoding="UTF-8"?>"#,
        "<!-- Dấu \(dev ? "development " : "")app icon, flat copy for the README and the web (docs/Brand.md). Generated by scripts/assets/make-app-icon.sh; do not edit by hand. -->",
        "<!-- Letter outlined from Be Vietnam Pro Bold (SIL OFL 1.1), marks are outlined strokes; no font needed. -->",
        #"<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">"#,
        "  <defs>",
        #"    <filter id="shadow" x="-10%" y="-10%" width="120%" height="125%">"#,
        "      <feDropShadow dx=\"0\" dy=\"\(fmt(shadowOffsetY))\" stdDeviation=\"\(fmt(shadowBlur / 2))\" flood-color=\"#000\" flood-opacity=\"\(fmt(shadowAlpha))\"/>",
        "    </filter>",
    ]
    if dev {
        lines.append(#"    <clipPath id="plate-clip"><path d="\#(svgData(plate))"/></clipPath>"#)
    }
    lines.append("  </defs>")
    lines.append("  <path id=\"plate\" fill=\"\((dev ? chi : muc).hex)\" filter=\"url(#shadow)\" d=\"\(svgData(plate))\"/>")
    if dev {
        lines.append("  <path id=\"stripe\" fill=\"\(hoPhach.hex)\" clip-path=\"url(#plate-clip)\" d=\"\(svgData(stripePath(fromGrid)))\"/>")
    }
    for l in glyphLayers(g) {
        lines.append("  <path id=\"\(l.id)\" fill=\"\(l.fill.hex)\" d=\"\(svgData(l.path))\"/>")
    }
    lines.append("</svg>")
    return lines.joined(separator: "\n") + "\n"
}

// MARK: - Icon Composer document

func layerSVG(_ p: Path, fill: Colour) -> String {
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
      <path fill="\(fill.hex)" d="\(svgData(p))"/>
    </svg>

    """
}

/// Writes <dir>/<name>.icon: icon.json plus Assets/*.svg (one outlined path each).
func writeIcon(_ g: Glyph, dev: Bool, into dir: URL) throws {
    let name = dev ? "AppIconDev" : "AppIcon"
    let doc = dir.appendingPathComponent("\(name).icon", isDirectory: true)
    let fm = FileManager.default
    try? fm.removeItem(at: doc)
    let assets = doc.appendingPathComponent("Assets", isDirectory: true)
    try fm.createDirectory(at: assets, withIntermediateDirectories: true)

    func write(_ file: String, _ p: Path, _ fill: Colour) throws {
        try layerSVG(p, fill: fill).write(to: assets.appendingPathComponent(file), atomically: true, encoding: .utf8)
    }
    let layers = glyphLayers(g)
    for l in layers { try write("\(l.id).svg", transform(l.path, toDocument), l.fill) }

    // Top to bottom: the acute over the circumflex, the letter at the bottom.
    func layerJSON(_ id: String) -> [String: Any] {
        ["name": id, "image-name": "\(id).svg", "glass": false]
    }
    var groups: [[String: Any]] = [[
        "layers": ["acute", "circumflex", "a"].map(layerJSON),
        "shadow": ["kind": "neutral", "opacity": 0.5],
        "translucency": ["enabled": false, "value": 0.5],
    ]]
    if dev {
        try write("stripe.svg", stripePath { toDocument(fromGrid($0)) }, hoPhach)
        groups.append([
            "layers": [[
                "name": "stripe", "image-name": "stripe.svg", "glass": false,
                // The layer fill replaces the SVG colour; the Dark rendition is the darker amber.
                "fill-specializations": [
                    ["value": ["solid": hoPhach.iconColour]],
                    ["appearance": "dark", "value": ["solid": hoPhachDark.iconColour]],
                ],
            ] as [String: Any]],
            "shadow": ["kind": "none", "opacity": 0],
            "translucency": ["enabled": false, "value": 0],
        ])
    }
    let (light, dark) = dev ? (chi, chiDark) : (muc, mucDark)
    let document: [String: Any] = [
        // Both fills go through fill-specializations (the entry without an appearance is the
        // default). With a top-level "fill" next to a Dark specialization, ictool 27.2 paints
        // the letter layers in the light fill colour in the Dark rendition.
        "fill-specializations": [
            ["value": ["solid": light.iconColour]],
            ["appearance": "dark", "value": ["solid": dark.iconColour]],
        ],
        "groups": groups,
        "supported-platforms": ["squares": ["macOS"]],
    ]
    let data = try JSONSerialization.data(withJSONObject: document,
                                          options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    try data.write(to: doc.appendingPathComponent("icon.json"))
    print("wrote \(doc.path)")
}

func loadGlyph(_ url: URL) throws -> Glyph {
    var fields: [String: String] = [:]
    for line in try String(contentsOf: url, encoding: .utf8).split(separator: "\n") {
        if line.hasPrefix("#") || line.trimmingCharacters(in: .whitespaces).isEmpty { continue }
        guard let sp = line.firstIndex(of: " ") else { continue }
        fields[String(line[..<sp])] = String(line[line.index(after: sp)...])
    }
    guard let em = fields["em"].flatMap(Double.init), let adv = fields["advance"].flatMap(Double.init),
          let a = fields["a"] else { fatalError("glyph file must define em, advance and a") }
    return Glyph(em: CGFloat(em), advance: CGFloat(adv), a: parse(a))
}

// MARK: - Main

let args = CommandLine.arguments
func usage() -> Never {
    FileHandle.standardError.write(Data("""
    usage: make-app-icon.swift outline <font.ttf> <glyphs.txt>
           make-app-icon.swift render <glyphs.txt> <svg-dir> <icon-dir>

    """.utf8))
    exit(2)
}
guard args.count >= 2 else { usage() }
switch args[1] {
case "outline" where args.count == 4:
    try outline(fontURL: URL(fileURLWithPath: args[2]), out: URL(fileURLWithPath: args[3]))
case "render" where args.count == 5:
    let glyph = try loadGlyph(URL(fileURLWithPath: args[2]))
    let svgDir = URL(fileURLWithPath: args[3], isDirectory: true)
    let iconDir = URL(fileURLWithPath: args[4], isDirectory: true)
    try FileManager.default.createDirectory(at: svgDir, withIntermediateDirectories: true)
    for dev in [false, true] {
        let file = svgDir.appendingPathComponent(dev ? "AppIconDev.svg" : "AppIcon.svg")
        try flatSVG(glyph, dev: dev).write(to: file, atomically: true, encoding: .utf8)
        print("wrote \(file.path)")
        try writeIcon(glyph, dev: dev, into: iconDir)
    }
default:
    usage()
}
