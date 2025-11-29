import TerminalCore
import TerminalStyle

/// A type that can be rendered to the terminal.
public protocol Renderable: Sendable {
    /// Render to a string.
    func render(width: Int?) -> String
}

/// Context for rendering.
public struct RenderContext: Sendable {
    /// Available width in characters.
    public let width: Int

    /// Available height in characters.
    public let height: Int

    /// Whether Unicode is supported.
    public let supportsUnicode: Bool

    /// Color mode.
    public let colorMode: ColorMode

    /// Create a render context.
    public init(
        width: Int = 80,
        height: Int = 24,
        supportsUnicode: Bool = true,
        colorMode: ColorMode = .auto
    ) {
        self.width = width
        self.height = height
        self.supportsUnicode = supportsUnicode
        self.colorMode = colorMode
    }

    /// Create from terminal.
    public static func from(_ terminal: Terminal) async -> RenderContext {
        let size = await terminal.size
        let caps = await terminal.capabilities
        return RenderContext(
            width: size.columns,
            height: size.rows,
            supportsUnicode: caps.supportsUnicode,
            colorMode: .auto
        )
    }
}
