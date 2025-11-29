import ANSI
import TerminalCore

/// A styled text segment with formatting attributes.
public struct StyledText: Sendable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible {
    /// The raw text content.
    public let content: String

    /// Foreground color.
    public var foreground: ANSI.Color?

    /// Background color.
    public var background: ANSI.Color?

    /// Text styles applied.
    public var styles: Set<TextStyle>

    /// URL for hyperlink (if any).
    public var url: String?

    /// Child segments (for composed styled text).
    public var children: [StyledText]

    /// Text styles.
    public enum TextStyle: Hashable, Sendable {
        case bold
        case dim
        case italic
        case underline
        case blink
        case reverse
        case hidden
        case strikethrough
    }

    // MARK: - Initialization

    /// Create styled text from a string.
    public init(_ content: String) {
        self.content = content
        self.foreground = nil
        self.background = nil
        self.styles = []
        self.url = nil
        self.children = []
    }

    /// Create styled text from a string literal.
    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// Create composed styled text from children.
    public init(children: [StyledText]) {
        self.content = ""
        self.foreground = nil
        self.background = nil
        self.styles = []
        self.url = nil
        self.children = children
    }

    // MARK: - Result Builder

    /// Build styled text from multiple segments.
    @resultBuilder
    public struct Builder {
        public static func buildBlock(_ components: StyledText...) -> StyledText {
            StyledText(children: components)
        }

        public static func buildExpression(_ expression: String) -> StyledText {
            StyledText(expression)
        }

        public static func buildExpression(_ expression: StyledText) -> StyledText {
            expression
        }

        public static func buildOptional(_ component: StyledText?) -> StyledText {
            component ?? StyledText("")
        }

        public static func buildEither(first component: StyledText) -> StyledText {
            component
        }

        public static func buildEither(second component: StyledText) -> StyledText {
            component
        }

        public static func buildArray(_ components: [StyledText]) -> StyledText {
            StyledText(children: components)
        }
    }

    /// Create styled text using a result builder.
    public init(@Builder _ builder: () -> StyledText) {
        let built = builder()
        self = built
    }

    // MARK: - Style Modifiers

    /// Set foreground color.
    public func foreground(_ color: ANSI.Color) -> StyledText {
        var copy = self
        copy.foreground = color
        return copy
    }

    /// Set background color.
    public func background(_ color: ANSI.Color) -> StyledText {
        var copy = self
        copy.background = color
        return copy
    }

    /// Add a text style.
    public func style(_ style: TextStyle) -> StyledText {
        var copy = self
        copy.styles.insert(style)
        return copy
    }

    /// Set hyperlink URL.
    public func link(_ url: String) -> StyledText {
        var copy = self
        copy.url = url
        return copy
    }

    // MARK: - Convenience Style Modifiers

    public var bold: StyledText { style(.bold) }
    public var dim: StyledText { style(.dim) }
    public var italic: StyledText { style(.italic) }
    public var underline: StyledText { style(.underline) }
    public var blink: StyledText { style(.blink) }
    public var reverse: StyledText { style(.reverse) }
    public var hidden: StyledText { style(.hidden) }
    public var strikethrough: StyledText { style(.strikethrough) }

    // MARK: - Foreground Color Shortcuts

    public var black: StyledText { foreground(.black) }
    public var red: StyledText { foreground(.red) }
    public var green: StyledText { foreground(.green) }
    public var yellow: StyledText { foreground(.yellow) }
    public var blue: StyledText { foreground(.blue) }
    public var magenta: StyledText { foreground(.magenta) }
    public var cyan: StyledText { foreground(.cyan) }
    public var white: StyledText { foreground(.white) }
    public var gray: StyledText { foreground(.gray) }
    public var grey: StyledText { foreground(.grey) }

    public var brightBlack: StyledText { foreground(.brightBlack) }
    public var brightRed: StyledText { foreground(.brightRed) }
    public var brightGreen: StyledText { foreground(.brightGreen) }
    public var brightYellow: StyledText { foreground(.brightYellow) }
    public var brightBlue: StyledText { foreground(.brightBlue) }
    public var brightMagenta: StyledText { foreground(.brightMagenta) }
    public var brightCyan: StyledText { foreground(.brightCyan) }
    public var brightWhite: StyledText { foreground(.brightWhite) }

    // MARK: - Background Color Shortcuts

    public var onBlack: StyledText { background(.black) }
    public var onRed: StyledText { background(.red) }
    public var onGreen: StyledText { background(.green) }
    public var onYellow: StyledText { background(.yellow) }
    public var onBlue: StyledText { background(.blue) }
    public var onMagenta: StyledText { background(.magenta) }
    public var onCyan: StyledText { background(.cyan) }
    public var onWhite: StyledText { background(.white) }

    // MARK: - RGB Colors

    /// Set foreground to RGB color.
    public func rgb(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> StyledText {
        foreground(.rgb(r, g, b))
    }

    /// Set foreground to hex color.
    public func hex(_ value: UInt32) -> StyledText {
        foreground(.hex(value))
    }

    /// Set background to RGB color.
    public func onRGB(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> StyledText {
        background(.rgb(r, g, b))
    }

    /// Set background to hex color.
    public func onHex(_ value: UInt32) -> StyledText {
        background(.hex(value))
    }

    // MARK: - Rendering

    /// Render to an ANSI-escaped string.
    public func render(colorMode: ColorMode = .auto) -> String {
        if !children.isEmpty {
            return children.map { $0.render(colorMode: colorMode) }.joined()
        }

        guard !content.isEmpty else { return "" }

        var result = ""

        // Start hyperlink if present
        if let url = url {
            result += ANSI.Hyperlink.start(url: url)
        }

        // Apply styles
        var appliedAnyCodes = false

        if let fg = foreground {
            result += ANSI.Style.foreground(fg)
            appliedAnyCodes = true
        }

        if let bg = background {
            result += ANSI.Style.background(bg)
            appliedAnyCodes = true
        }

        for style in styles {
            result += style.ansiCode
            appliedAnyCodes = true
        }

        // Add content
        result += content

        // Reset if we applied any codes
        if appliedAnyCodes {
            result += ANSI.Style.reset
        }

        // End hyperlink if present
        if url != nil {
            result += ANSI.Hyperlink.end
        }

        return result
    }

    /// CustomStringConvertible
    public var description: String {
        render()
    }

    /// The plain text without any styling.
    public var plainText: String {
        if !children.isEmpty {
            return children.map(\.plainText).joined()
        }
        return content
    }

    /// The length of the plain text (visible characters).
    public var length: Int {
        plainText.count
    }
}

extension StyledText.TextStyle {
    var ansiCode: String {
        switch self {
        case .bold: return ANSI.Style.bold
        case .dim: return ANSI.Style.dim
        case .italic: return ANSI.Style.italic
        case .underline: return ANSI.Style.underline
        case .blink: return ANSI.Style.blink
        case .reverse: return ANSI.Style.reverse
        case .hidden: return ANSI.Style.hidden
        case .strikethrough: return ANSI.Style.strikethrough
        }
    }
}

// MARK: - Concatenation

extension StyledText {
    /// Concatenate two styled texts.
    public static func + (lhs: StyledText, rhs: StyledText) -> StyledText {
        StyledText(children: [lhs, rhs])
    }

    /// Concatenate styled text with a string.
    public static func + (lhs: StyledText, rhs: String) -> StyledText {
        lhs + StyledText(rhs)
    }

    /// Concatenate a string with styled text.
    public static func + (lhs: String, rhs: StyledText) -> StyledText {
        StyledText(lhs) + rhs
    }
}
