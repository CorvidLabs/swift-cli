import Foundation
import ANSI
import TerminalCore

/**
 Sixel graphics protocol implementation.
 
 Sixel is an older but widely supported terminal graphics format.
 Note: Full sixel encoding requires complex color quantization.
 This is a simplified implementation.
 */
public struct SixelImage: TerminalImageProtocol, Sendable {
    /// Pre-encoded sixel data.
    public let sixelData: String

    /// Image configuration.
    public let config: ImageConfig

    /// Create from pre-encoded sixel data.
    public init(sixelData: String, config: ImageConfig = .default) {
        self.sixelData = sixelData
        self.config = config
    }

    /// Render the sixel image.
    public func render() -> String {
        // Sixel format: ESC P [params] q <sixel data> ESC \
        return "\(ANSI.DCS)0;0;0q\(sixelData)\(ANSI.ST)"
    }
}

/// Sixel encoder for simple images.
public struct SixelEncoder: Sendable {
    /**
     Encode RGB pixel data to sixel format.
     - Parameters:
       - pixels: RGB pixel data (3 bytes per pixel: R, G, B)
       - width: Image width
       - height: Image height
       - maxColors: Maximum colors in palette (2-256)
     - Returns: Sixel encoded string
     */
    public static func encode(pixels: [UInt8], width: Int, height: Int, maxColors: Int = 256) -> String {
        // This is a simplified encoder that works for basic images
        // A full implementation would need color quantization

        var result = ""

        // Sixel header with aspect ratio
        result += "\"1;1;\(width);\(height)"

        // Simple color palette (grayscale for now)
        let colors = min(maxColors, 256)
        for i in 0..<colors {
            let gray = (i * 100) / (colors - 1)
            result += "#\(i);2;\(gray);\(gray);\(gray)"
        }

        // Encode pixels in 6-row bands
        for band in stride(from: 0, to: height, by: 6) {
            if band > 0 {
                result += "-" // New line
            }

            // For each column
            for x in 0..<width {
                var sixel: UInt8 = 0

                // Each sixel represents 6 vertical pixels
                for dy in 0..<6 {
                    let y = band + dy
                    if y < height {
                        let pixelIndex = (y * width + x) * 3
                        if pixelIndex + 2 < pixels.count {
                            let r = pixels[pixelIndex]
                            let g = pixels[pixelIndex + 1]
                            let b = pixels[pixelIndex + 2]

                            // Simple threshold for black/white
                            let gray = (Int(r) + Int(g) + Int(b)) / 3
                            if gray > 127 {
                                sixel |= (1 << dy)
                            }
                        }
                    }
                }

                // Sixel character = value + 63
                result += String(UnicodeScalar(sixel + 63))
            }
        }

        return result
    }
}
