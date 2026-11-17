// Draws the background of the Dấu disk image window: Giấy with the faint Mực arrow of the
// canvas artboard "Cửa sổ ảnh đĩa DMG" (docs/canvas/src/DmgWindow.dc.html). No icon and no
// text: Finder draws the Dấu icon and the Applications link.
//
//   make-dmg-background <out-dir>   writes DmgBackground.png (640 × 400 px, 72 dpi) and
//                                   DmgBackground@2x.png (1280 × 800 px, 144 dpi)
//
// Arrow: the artboard's 120 × 40 svg placed at (260, 160) pt of the content area; a shaft
// M6 20 H108 and a head M94 8 L110 20 L94 32, each 4 wide, round caps and joins, Mực at 45%,
// painted as two separate paths like the svg does.
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let width = 640, height = 400  // pt, the window content area
let giay = CGColor(srgbRed: 0xF6 / 255, green: 0xF1 / 255, blue: 0xE7 / 255, alpha: 1)
let muc45 = CGColor(srgbRed: 0x10 / 255, green: 0x28 / 255, blue: 0x5A / 255, alpha: 0.45)

func render(scale: Int) -> CGImage {
    let ctx = CGContext(data: nil, width: width * scale, height: height * scale, bitsPerComponent: 8,
                        bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    // Flip to a top-left origin in points.
    ctx.translateBy(x: 0, y: CGFloat(height * scale))
    ctx.scaleBy(x: CGFloat(scale), y: -CGFloat(scale))
    ctx.setFillColor(giay)
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    ctx.translateBy(x: 260, y: 160)
    ctx.setStrokeColor(muc45)
    ctx.setLineWidth(4)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.beginPath()
    ctx.move(to: CGPoint(x: 6, y: 20)); ctx.addLine(to: CGPoint(x: 108, y: 20))
    ctx.strokePath()
    ctx.beginPath()
    ctx.move(to: CGPoint(x: 94, y: 8)); ctx.addLine(to: CGPoint(x: 110, y: 20)); ctx.addLine(to: CGPoint(x: 94, y: 32))
    ctx.strokePath()
    return ctx.makeImage()!
}

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: make-dmg-background <out-dir>\n".utf8)); exit(2)
}
let dir = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
for scale in [1, 2] {
    let url = dir.appendingPathComponent(scale == 1 ? "DmgBackground.png" : "DmgBackground@2x.png")
    let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    let dpi = 72 * scale
    CGImageDestinationAddImage(dest, render(scale: scale),
                               [kCGImagePropertyDPIWidth: dpi, kCGImagePropertyDPIHeight: dpi] as CFDictionary)
    guard CGImageDestinationFinalize(dest) else { fatalError("cannot write \(url.path)") }
    print("wrote \(url.path)")
}
