import Foundation
import ANSI
import TerminalCore

/**
 iTerm2 inline image protocol.

 Reference: https://iterm2.com/documentation-images.html
 */
public struct ITerm2Image: TerminalImageProtocol, Sendable {
    /// Raw image data (PNG, JPEG, GIF, etc.).
    public let data: Data

    /// Image configuration.
    public let config: ImageConfig

    /// Optional name for the image.
    public let name: String?

    /// Create an iTerm2 image from data.
    public init(data: Data, config: ImageConfig = .default, name: String? = nil) {
        self.data = data
        self.config = config
        self.name = name
    }

    /// Create an iTerm2 image from a file URL.
    public init(contentsOf url: URL, config: ImageConfig = .default) throws {
        self.data = try Data(contentsOf: url)
        self.config = config
        self.name = url.lastPathComponent
    }

    /// Create an iTerm2 image from a file path.
    public init(path: String, config: ImageConfig = .default) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(contentsOf: url, config: config)
    }

    /// Render the image to an escape sequence.
    public func render() -> String {
        // Format: OSC 1337 ; File=[arguments] : base64data BEL
        var args: [String] = ["inline=1"]

        // Name
        if let name = name {
            let encodedName = Data(name.utf8).base64EncodedString()
            args.append("name=\(encodedName)")
        }

        // Size
        args.append(contentsOf: sizeArgs())

        // Preserve aspect ratio
        if config.preserveAspectRatio {
            args.append("preserveAspectRatio=1")
        } else {
            args.append("preserveAspectRatio=0")
        }

        let base64Data = data.base64EncodedString()
        let argsString = args.joined(separator: ";")

        return "\(ANSI.OSC)1337;File=\(argsString):\(base64Data)\(ANSI.BEL)"
    }

    private func sizeArgs() -> [String] {
        var args: [String] = []

        switch config.width {
        case .auto:
            args.append("width=auto")
        case .cells(let n):
            args.append("width=\(n)")
        case .percent(let p):
            args.append("width=\(p)%")
        case .pixels(let px):
            args.append("width=\(px)px")
        }

        switch config.height {
        case .auto:
            args.append("height=auto")
        case .cells(let n):
            args.append("height=\(n)")
        case .percent(let p):
            args.append("height=\(p)%")
        case .pixels(let px):
            args.append("height=\(px)px")
        }

        return args
    }
}
