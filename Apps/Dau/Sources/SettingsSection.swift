import AppKit
import SwiftUI

/// The four sections of the Settings window (docs/UI.md).
enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
    case typing
    case smart
    case apps
    case updates

    var id: String { rawValue }

    var title: String { String(localized: titleResource) }

    /// The title as a catalog entry: the sidebar row and the page title.
    var titleResource: LocalizedStringResource {
        switch self {
        case .typing: "Typing"
        case .smart: "Smart Typing"
        case .apps: "Apps"
        case .updates: "Updates & Support"
        }
    }

    /// Words the sidebar search matches, besides the title, as catalog entries: the
    /// visible row titles, section headers, choices and buttons of the section, so the
    /// search finds the words in the language the window shows them.
    var keywordResources: [LocalizedStringResource] {
        switch self {
        case .typing:
            ["Preview", "Typing method", "Telex", "VNI", "Simple Telex", "Tone mark placement",
             "Modern", "Classic", "Free mark placement", "Input source shortcut",
             "Switch Vietnamese ↔ English"]
        case .smart:
            ["Foreign words", "Restore non-Vietnamese words", "Editing typed words",
             "Add marks to typed words", "Advanced", "Consonant shortcuts",
             "Allow consonants z, f, w, j"]
        case .apps:
            ["App rules", "Add App", "Underline", "No Underline", "Suggested", "Turn On Underline"]
        case .updates:
            // The update rows exist only on a build with an updater (D7).
            (UpdaterConfiguration.isConfiguredForThisApp
                ? ["Check for Updates…", "Automatically check for updates", "Release channel", "Beta", "Stable"] : [])
            + ["Version", "Wrong text in an app", "Report a Problem…", "Remove Dấu from this Mac",
               "Uninstall…", "Privacy"]
        }
    }

    /// Case- and diacritic-insensitive match on the words as shown ("go phim" finds
    /// "Typing" in Vietnamese, "typing" finds "Typing" in English).
    func matches(_ query: String) -> Bool {
        matches(query) { String(localized: $0) }
    }

    /// `localize` turns a catalog entry into the shown words: `String(localized:)` in the
    /// app; tests pass one that reads a chosen language of the catalog.
    func matches(_ query: String, localize: (LocalizedStringResource) -> String) -> Bool {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return true }
        let words = ([titleResource] + keywordResources).map(localize)
        return words.contains { $0.searchContains(query) }
    }
}

extension String {
    /// Whether `query` occurs in the string, ignoring case and diacritics, with "đ" read
    /// as "d" too (it is a letter of its own, not a "d" with a mark, so diacritic folding
    /// keeps it): "de xuat" finds "Suggested", as people type without marks.
    func searchContains(_ query: String) -> Bool {
        func fold(_ s: String) -> String {
            s.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
                .replacingOccurrences(of: "đ", with: "d")
        }
        return fold(self).contains(fold(query))
    }
}

/// Sidebar icon: a tile at System Settings' sidebar icon size (20 pt, measured; see
/// docs/research/SystemSettingsReference.md) in a system color, with the mockup's solid
/// white glyph (canvas artboards "Settings…": tile 20 with corner radius 5, a 24-unit
/// viewBox drawn at 18 pt in its centre).
/// Drawn into a non-template image so the sidebar's vibrancy does not wash it out.
/// Decorative; the label beside it carries the meaning.
struct SectionIcon: View {
    let section: SettingsSection

    static let size: CGFloat = 20
    static let cornerRadius: CGFloat = 5
    static let glyphSize: CGFloat = 18

    var body: some View {
        Image(nsImage: SectionIcon.tile(section))
            .frame(width: Self.size, height: Self.size)
            .accessibilityHidden(true)
    }

    @MainActor private static var cache: [SettingsSection: NSImage] = [:]

    @MainActor static func tile(_ section: SettingsSection) -> NSImage {
        if let image = cache[section] { return image }
        let image = NSImage(size: NSSize(width: size, height: size), flipped: true) { rect in
            section.tileColor.setFill()
            NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius).fill()
            let inset = (size - glyphSize) / 2
            let toTile = NSAffineTransform()
            toTile.translateX(by: inset, yBy: inset)
            toTile.scale(by: glyphSize / SectionGlyph.viewBox)
            toTile.concat()
            section.glyph.draw(in: .white)
            return true
        }
        image.isTemplate = false
        cache[section] = image
        return image
    }
}

/// A sidebar glyph in the mockup's 24-unit viewBox (y down): filled shapes, and the
/// stroked ones of SVG elements drawn with `stroke`.
struct SectionGlyph {
    static let viewBox: CGFloat = 24

    var filled = NSBezierPath()
    var stroked: [(path: NSBezierPath, width: CGFloat)] = []

    func draw(in color: NSColor) {
        color.set()
        filled.fill()
        for (path, width) in stroked {
            path.lineWidth = width
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.stroke()
        }
    }
}

extension SettingsSection {
    /// Tile colors: the system colors of the mockup's hues (D9: no custom colors).
    var tileColor: NSColor {
        switch self {
        case .typing: .systemBlue
        case .smart: .systemPurple
        case .apps: .systemOrange
        case .updates: .systemGreen
        }
    }

    /// The mockup's glyph, from the SVG of the canvas artboards "Settings…".
    var glyph: SectionGlyph {
        var glyph = SectionGlyph()
        let p = glyph.filled
        func roundedRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, radius: CGFloat) {
            p.append(NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: radius, yRadius: radius))
        }
        /// A four-pointed star with concave sides: each side a quadratic curve whose control
        /// point sits `waist` from the centre on the diagonal.
        func sparkle(_ cx: CGFloat, _ cy: CGFloat, radius r: CGFloat, waist w: CGFloat) {
            p.move(to: NSPoint(x: cx, y: cy - r))
            p.curve(to: NSPoint(x: cx + r, y: cy), controlPoint: NSPoint(x: cx + w, y: cy - w))
            p.curve(to: NSPoint(x: cx, y: cy + r), controlPoint: NSPoint(x: cx + w, y: cy + w))
            p.curve(to: NSPoint(x: cx - r, y: cy), controlPoint: NSPoint(x: cx - w, y: cy + w))
            p.curve(to: NSPoint(x: cx, y: cy - r), controlPoint: NSPoint(x: cx - w, y: cy - w))
            p.close()
        }
        switch self {
        case .typing:
            // A keyboard: the body with two rows of keys and the space bar cut out.
            p.windingRule = .evenOdd
            roundedRect(3, 7, 18, 10, radius: 2.5)
            for keyTop in [8.5, 10.9] {
                for column in 0..<6 { p.appendRect(NSRect(x: 4.4 + 2.6 * CGFloat(column), y: keyTop, width: 2.2, height: 1.9)) }
            }
            roundedRect(7.3, 13.4, 9.4, 1.8, radius: 0.9)
        case .smart:
            sparkle(10.5, 13.5, radius: 8, waist: 1.4)
            sparkle(18.5, 5.5, radius: 3.5, waist: 0.6)
        case .apps:
            for x in [4.375, 14.125] {
                for y in [4.375, 14.125] { roundedRect(x, y, 5.5, 5.5, radius: 1.5) }
            }
        case .updates:
            // A clockwise arrow: 300° of the circle at (12, 13), r 7.25, from -40° to 260°
            // (y down), and a head on the tangent at its end.
            let arc = NSBezierPath()
            arc.appendArc(withCenter: NSPoint(x: 12, y: 13), radius: 7.25, startAngle: -40, endAngle: 260, clockwise: false)
            glyph.stroked.append((arc, 2))
            p.move(to: NSPoint(x: 11.31, y: 9.11))
            p.line(to: NSPoint(x: 10.17, y: 2.61))
            p.line(to: NSPoint(x: 15.27, y: 5.06))
            p.close()
            glyph.stroked.append((p, 0.6))
        }
        return glyph
    }
}
