import AppKit
import SwiftUI
import DauShared

/// Frames reported by the app's `layoutProbe` modifiers, in window points (top-left).
@MainActor
final class ProbeLog {
    var frames: [String: CGRect] = [:]
}

/// An off-screen window that draws as the key, main window, so controls and the
/// sidebar selection show their active look (accent colors) as in the mockup.
final class ActiveLookWindow: NSWindow {
    override var isKeyWindow: Bool { true }
    override var isMainWindow: Bool { true }
}

/// Renders SwiftUI views in an off-screen window and writes PNGs.
@MainActor
enum Snapshot {
    struct Result {
        let rep: NSBitmapImageRep
        let frames: [String: CGRect]
        let scale: CGFloat
    }

    @discardableResult
    static func render<V: View>(_ view: V, to url: URL?, appearance: NSAppearance.Name,
                                size: CGSize = CGSize(width: 820, height: 600), settle: Int = 30) -> Result? {
        let log = ProbeLog()
        let window = ActiveLookWindow(contentRect: CGRect(origin: CGPoint(x: -6000, y: -6000), size: size),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                              backing: .buffered, defer: false)
        window.toolbarStyle = .unified
        window.appearance = NSAppearance(named: appearance)
        let root = view
            .environment(\.layoutProbe) { name, frame in log.frames[name] = frame.isNull ? nil : frame }
            .environment(\.appearsActive, true)
        let host = NSHostingView(rootView: root)
        host.appearance = window.appearance
        host.frame = CGRect(origin: .zero, size: size)
        window.contentView = host
        window.orderFrontRegardless()
        for _ in 0..<settle {
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
            host.layoutSubtreeIfNeeded()
        }
        // The window's frame view draws the window background and title bar too.
        let frameView = host.superview ?? host
        frameView.display()
        let bounds = frameView.convert(host.bounds, from: host)
        guard let rep = frameView.bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        frameView.cacheDisplay(in: bounds, to: rep)
        if let url, let data = rep.representation(using: .png, properties: [:]) {
            do {
                try data.write(to: url)
                print(url.path)
            } catch {
                print("cannot write \(url.path): \(error)")
            }
        }
        // The close button, in the same top-left window coordinates as the probes.
        var frames = log.frames
        if let button = window.standardWindowButton(.closeButton), let superview = button.superview {
            let r = superview.convert(button.frame, to: nil)
            frames["close"] = CGRect(x: r.minX, y: size.height - r.maxY, width: r.width, height: r.height)
        }
        window.orderOut(nil)
        return Result(rep: rep, frames: frames, scale: CGFloat(rep.pixelsWide) / size.width)
    }

    /// Presents `sheet` with SwiftUI's `.sheet` on an off-screen window of `parentSize`
    /// and renders the sheet window alone (its toolbar search field and button bar
    /// included; no vibrancy). Nil when no sheet attached.
    @discardableResult
    static func renderSheet<V: View>(_ sheet: V, to url: URL?, appearance: NSAppearance.Name,
                                     parentSize: CGSize = CGSize(width: 740, height: 560),
                                     settle: Int = 60) -> NSBitmapImageRep? {
        let window = ActiveLookWindow(contentRect: CGRect(origin: CGPoint(x: -6000, y: -6000), size: parentSize),
                                      styleMask: [.titled, .closable, .fullSizeContentView],
                                      backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: appearance)
        let host = NSHostingView(rootView: Color.clear.sheet(isPresented: .constant(true)) { sheet })
        host.frame = CGRect(origin: .zero, size: parentSize)
        window.contentView = host
        window.orderFrontRegardless()
        for _ in 0..<settle {
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        }
        defer { window.orderOut(nil) }
        guard let sheetWindow = window.attachedSheet, let content = sheetWindow.contentView else { return nil }
        content.layoutSubtreeIfNeeded()
        let frameView = content.superview ?? content
        frameView.display()
        guard let rep = frameView.bitmapImageRepForCachingDisplay(in: frameView.bounds) else { return nil }
        frameView.cacheDisplay(in: frameView.bounds, to: rep)
        if let url, let data = rep.representation(using: .png, properties: [:]) {
            do {
                try data.write(to: url)
                print(url.path)
            } catch {
                print("cannot write \(url.path): \(error)")
            }
        }
        sheetWindow.sheetParent?.endSheet(sheetWindow)
        return rep
    }

    /// Raw sRGB bytes of one pixel (the capture's bytes are sRGB values even though the
    /// bitmap is tagged Display P3; converting would shift mid-grays).
    static func pixel(_ result: Result, at point: CGPoint) -> (r: Double, g: Double, b: Double) {
        var p = [Int](repeating: 0, count: 4)
        let x = min(max(Int(point.x * result.scale), 0), result.rep.pixelsWide - 1)
        let y = min(max(Int(point.y * result.scale), 0), result.rep.pixelsHigh - 1)
        result.rep.getPixel(&p, atX: x, y: y)
        return (Double(p[0]) / 255, Double(p[1]) / 255, Double(p[2]) / 255)
    }

    /// The part `rect` (points, top-left origin) of a @2x bitmap, enlarged so one point
    /// becomes `scale` pixels.
    static func crop(_ rep: NSBitmapImageRep, _ rect: CGRect, scale: CGFloat) -> NSBitmapImageRep? {
        let pointScale = CGFloat(rep.pixelsWide) / rep.size.width
        let w = Int(rect.width * scale), h = Int(rect.height * scale)
        guard let out = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
                                         bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
              let cg = rep.cgImage,
              let part = cg.cropping(to: CGRect(x: rect.minX * pointScale, y: rect.minY * pointScale,
                                                width: rect.width * pointScale, height: rect.height * pointScale))
        else { return nil }
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: out)
        context?.imageInterpolation = .none
        NSGraphicsContext.current = context
        NSImage(cgImage: part, size: rect.size).draw(in: CGRect(x: 0, y: 0, width: w, height: h))
        NSGraphicsContext.restoreGraphicsState()
        return out
    }

    /// Writes bitmaps side by side, top-aligned, with a gap.
    static func sideBySide(_ reps: [NSBitmapImageRep], to url: URL) {
        let gap = 40
        let w = reps.map(\.pixelsWide).reduce(0, +) + gap * (reps.count - 1)
        let h = reps.map(\.pixelsHigh).max() ?? 0
        guard let out = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
                                         bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: out)
        NSColor.gray.setFill()
        CGRect(x: 0, y: 0, width: w, height: h).fill()
        var x = 0
        for rep in reps {
            rep.draw(in: CGRect(x: x, y: h - rep.pixelsHigh, width: rep.pixelsWide, height: rep.pixelsHigh))
            x += rep.pixelsWide + gap
        }
        NSGraphicsContext.restoreGraphicsState()
        if let data = out.representation(using: .png, properties: [:]) {
            try? data.write(to: url)
            print(url.path)
        }
    }

    /// Writes images side by side in a grid.
    static func grid(_ images: [URL], columns: Int, to url: URL) {
        let loaded = images.compactMap { NSImage(contentsOf: $0) }
        guard let first = loaded.first?.representations.first else { return }
        let w = first.pixelsWide, h = first.pixelsHigh
        let rows = (loaded.count + columns - 1) / columns
        guard let out = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w * columns, pixelsHigh: h * rows,
                                         bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: out)
        for (i, image) in loaded.enumerated() {
            let col = i % columns, row = i / columns
            image.draw(in: CGRect(x: col * w, y: (rows - 1 - row) * h, width: w, height: h))
        }
        NSGraphicsContext.restoreGraphicsState()
        if let data = out.representation(using: .png, properties: [:]) {
            try? data.write(to: url)
            print(url.path)
        }
    }

    /// Settings for the Apps page: one stored rule, Slack, a suggestion the user
    /// accepted ("Đề xuất" chip, "Có gạch chân"). Cursor and Zalo come from `sampleList`
    /// without a rule, so they show under "Đề xuất" (only when installed, like in the app).
    static func sampleSettings() -> DauSettings {
        var s = DauSettings.defaults
        s.upsert(AppRule(bundleID: "com.tinyspeck.slackmacgap", displayName: "Slack",
                         underline: true, source: .suggested))
        return s
    }

    /// A few suggestions instead of the shipped list, so the page does not depend on
    /// which other suggested apps are installed.
    static let sampleList = CompatibilityList(version: 1, apps: [
        .init(bundleIDs: ["com.todesktop.230313mzl4w4u92"], name: "Cursor"),
        .init(bundleIDs: ["com.tinyspeck.slackmacgap"], name: "Slack"),
        .init(bundleIDs: ["com.vng.zalo"], name: "Zalo"),
    ])
}

/// WCAG contrast ratio of two sRGB colors.
func contrastRatio(_ a: (r: Double, g: Double, b: Double), _ b: (r: Double, g: Double, b: Double)) -> Double {
    func lum(_ c: (r: Double, g: Double, b: Double)) -> Double {
        func ch(_ v: Double) -> Double { v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b)
    }
    let la = lum(a), lb = lum(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
}

/// `color` (with alpha) resolved under `appearance` and composited over `background`.
@MainActor
func composite(_ color: NSColor, over background: (r: Double, g: Double, b: Double),
               appearance: NSAppearance.Name) -> (r: Double, g: Double, b: Double) {
    var c = color
    NSAppearance(named: appearance)!.performAsCurrentDrawingAppearance {
        c = color.usingColorSpace(.sRGB) ?? color
    }
    let a = Double(c.alphaComponent)
    return (Double(c.redComponent) * a + background.r * (1 - a),
            Double(c.greenComponent) * a + background.g * (1 - a),
            Double(c.blueComponent) * a + background.b * (1 - a))
}
