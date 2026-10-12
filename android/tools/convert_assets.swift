import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Run from the project root with the iOS Assets.xcassets path as the first argument.
let source = URL(fileURLWithPath: CommandLine.arguments[1])
let destination = URL(fileURLWithPath: CommandLine.arguments[2])
try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
let files = FileManager.default.enumerator(at: source, includingPropertiesForKeys: nil)!
for case let input as URL in files {
    if input.pathExtension.lowercased() == "pdf" {
        guard let pdf = CGPDFDocument(input as CFURL), let page = pdf.page(at: 1) else { continue }
        let box = page.getBoxRect(.mediaBox)
        let longest: CGFloat = input.lastPathComponent == "HopSlideBackground.pdf" ? 1800 : 1200
        let scale = min(4, longest / max(box.width, box.height))
        let width = max(1, Int(ceil(box.width * scale)))
        let height = max(1, Int(ceil(box.height * scale)))
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { continue }
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -box.minX, y: -box.minY)
        context.drawPDFPage(page)
        let output = destination.appendingPathComponent(input.deletingPathExtension().lastPathComponent + ".png")
        guard let image = context.makeImage(), let writer = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil) else { continue }
        CGImageDestinationAddImage(writer, image, nil)
        guard CGImageDestinationFinalize(writer) else { fatalError("Unable to convert \(input.path)") }
        print("\(output.lastPathComponent): \(width)×\(height)")
    } else if input.pathExtension.lowercased() == "png" && !input.path.contains("AppIcon") {
        let output = destination.appendingPathComponent(input.lastPathComponent)
        if FileManager.default.fileExists(atPath: output.path) { continue }
        try FileManager.default.copyItem(at: input, to: output)
    }
}
