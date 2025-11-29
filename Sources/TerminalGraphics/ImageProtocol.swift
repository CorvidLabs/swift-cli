import Foundation
import ANSI
import TerminalCore

/// Protocol for terminal image rendering.
public protocol TerminalImageProtocol: Sendable {
    /// Render the image to a string that can be written to the terminal.
    func render() -> String
}

/// Size specification for terminal images.
public enum ImageSize: Sendable {
    /// Automatic sizing.
    case auto

    /// Specific number of cells.
    case cells(Int)

    /// Percentage of terminal width/height.
    case percent(Int)

    /// Pixels (for terminals that support it).
    case pixels(Int)
}

/// Base terminal image configuration.
public struct ImageConfig: Sendable {
    /// Image width.
    public var width: ImageSize

    /// Image height.
    public var height: ImageSize

    /// Whether to preserve aspect ratio.
    public var preserveAspectRatio: Bool

    /// Whether to display inline (vs block).
    public var inline: Bool

    /// Create image configuration.
    public init(
        width: ImageSize = .auto,
        height: ImageSize = .auto,
        preserveAspectRatio: Bool = true,
        inline: Bool = true
    ) {
        self.width = width
        self.height = height
        self.preserveAspectRatio = preserveAspectRatio
        self.inline = inline
    }

    public static let `default` = ImageConfig()
}
