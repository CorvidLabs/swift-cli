import Foundation
import ANSI
import TerminalCore

/// Auto-detecting terminal image that selects the best protocol.
public struct TerminalImage: TerminalImageProtocol, Sendable {
    /// Raw image data.
    public let data: Data

    /// Image configuration.
    public let config: ImageConfig

    /// Detected or specified protocol.
    public let imageProtocol: TerminalCapabilities.ImageProtocol?

    /// Create a terminal image from data.
    public init(data: Data, config: ImageConfig = .default, protocol imageProtocol: TerminalCapabilities.ImageProtocol? = nil) {
        self.data = data
        self.config = config
        self.imageProtocol = imageProtocol
    }

    /// Create a terminal image from a file URL.
    public init(contentsOf url: URL, config: ImageConfig = .default, protocol imageProtocol: TerminalCapabilities.ImageProtocol? = nil) throws {
        self.data = try Data(contentsOf: url)
        self.config = config
        self.imageProtocol = imageProtocol
    }

    /// Create a terminal image from a file path.
    public init(path: String, config: ImageConfig = .default, protocol imageProtocol: TerminalCapabilities.ImageProtocol? = nil) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(contentsOf: url, config: config, protocol: imageProtocol)
    }

    /// Render using the detected or specified protocol.
    public func render() -> String {
        let proto = imageProtocol ?? detectProtocol()

        switch proto {
        case .iterm2:
            return ITerm2Image(data: data, config: config).render()
        case .kitty:
            return KittyImage(data: data, config: config).render()
        case .sixel:
            // Sixel requires encoded data, fall back to placeholder
            return "[Image: Sixel encoding not fully implemented]"
        case .none:
            return "[Image: No supported protocol detected]"
        }
    }

    private func detectProtocol() -> TerminalCapabilities.ImageProtocol? {
        let caps = TerminalCapabilities.detect()
        return caps.imageProtocol
    }
}

// MARK: - Terminal Extension

extension Terminal {
    /// Render an image using the best available protocol.
    public func renderImage(data: Data, config: ImageConfig = .default) {
        let image = TerminalImage(data: data, config: config, protocol: capabilities.imageProtocol)
        writeLine(image.render())
    }

    /// Render an image from a file.
    public func renderImage(path: String, config: ImageConfig = .default) throws {
        let image = try TerminalImage(path: path, config: config, protocol: capabilities.imageProtocol)
        writeLine(image.render())
    }

    /// Render an image from a URL.
    public func renderImage(url: URL, config: ImageConfig = .default) throws {
        let image = try TerminalImage(contentsOf: url, config: config, protocol: capabilities.imageProtocol)
        writeLine(image.render())
    }

    /// Render an iTerm2 image.
    public func render(_ image: ITerm2Image) {
        writeLine(image.render())
    }

    /// Render a Kitty image.
    public func render(_ image: KittyImage) {
        writeLine(image.render())
    }

    /// Render a generic terminal image.
    public func render(_ image: TerminalImage) {
        writeLine(image.render())
    }
}
