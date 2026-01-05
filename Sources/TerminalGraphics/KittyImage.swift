import Foundation
import ANSI
import TerminalCore

/**
 Kitty graphics protocol implementation.

 Reference: https://sw.kovidgoyal.net/kitty/graphics-protocol/
 */
public struct KittyImage: TerminalImageProtocol, Sendable {
    /// Raw image data (PNG recommended).
    public let data: Data

    /// Image configuration.
    public let config: ImageConfig

    /// Transmission format.
    public let format: Format

    /// Image format.
    public enum Format: Int, Sendable {
        case rgb = 24      // Raw RGB
        case rgba = 32     // Raw RGBA
        case png = 100     // PNG (recommended)
    }

    /// Create a Kitty image from data.
    public init(data: Data, format: Format = .png, config: ImageConfig = .default) {
        self.data = data
        self.format = format
        self.config = config
    }

    /// Create a Kitty image from a file URL.
    public init(contentsOf url: URL, config: ImageConfig = .default) throws {
        self.data = try Data(contentsOf: url)
        self.format = .png
        self.config = config
    }

    /// Create a Kitty image from a file path.
    public init(path: String, config: ImageConfig = .default) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(contentsOf: url, config: config)
    }

    /// Render the image to escape sequences.
    public func render() -> String {
        // Kitty graphics use chunked transmission for large images
        // Format: ESC_G<control data>;<payload>ESC\

        let base64Data = data.base64EncodedString()
        let chunkSize = 4096

        var result = ""
        var offset = 0

        while offset < base64Data.count {
            let remaining = base64Data.count - offset
            let currentChunkSize = min(chunkSize, remaining)
            let isFirst = offset == 0
            let isLast = offset + currentChunkSize >= base64Data.count

            let startIndex = base64Data.index(base64Data.startIndex, offsetBy: offset)
            let endIndex = base64Data.index(startIndex, offsetBy: currentChunkSize)
            let chunk = String(base64Data[startIndex..<endIndex])

            var control: [String] = []

            if isFirst {
                // First chunk includes format and action
                control.append("a=T")  // Transmit and display
                control.append("f=\(format.rawValue)")

                // Size
                switch config.width {
                case .cells(let n):
                    control.append("c=\(n)")
                case .pixels(let px):
                    control.append("w=\(px)")
                default:
                    break
                }

                switch config.height {
                case .cells(let n):
                    control.append("r=\(n)")
                case .pixels(let px):
                    control.append("h=\(px)")
                default:
                    break
                }
            }

            // More chunks to come?
            if !isLast {
                control.append("m=1")
            } else {
                control.append("m=0")
            }

            let controlStr = control.joined(separator: ",")
            result += "\(ANSI.ESC)_G\(controlStr);\(chunk)\(ANSI.ST)"

            offset += currentChunkSize
        }

        return result
    }
}
