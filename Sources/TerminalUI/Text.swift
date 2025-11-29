import ANSI
import TerminalStyle

/// A view that displays text.
public struct Text: View, Sendable {
    public let content: String
    public var foreground: ANSI.Color?
    public var background: ANSI.Color?
    public var styles: Set<StyledText.TextStyle>

    public init(_ content: String) {
        self.content = content
        self.foreground = nil
        self.background = nil
        self.styles = []
    }

    public init(_ styledText: StyledText) {
        self.content = styledText.plainText
        self.foreground = styledText.foreground
        self.background = styledText.background
        self.styles = styledText.styles
    }

    public var body: Never {
        fatalError("Text does not have a body")
    }

    // MARK: - Style Modifiers

    /// Set foreground color.
    public func foregroundColor(_ color: ANSI.Color) -> Text {
        var copy = self
        copy.foreground = color
        return copy
    }

    /// Set background color.
    public func backgroundColor(_ color: ANSI.Color) -> Text {
        var copy = self
        copy.background = color
        return copy
    }

    /// Make text bold.
    public func bold() -> Text {
        var copy = self
        copy.styles.insert(.bold)
        return copy
    }

    /// Make text italic.
    public func italic() -> Text {
        var copy = self
        copy.styles.insert(.italic)
        return copy
    }

    /// Make text underlined.
    public func underline() -> Text {
        var copy = self
        copy.styles.insert(.underline)
        return copy
    }

    /// Make text dim.
    public func dim() -> Text {
        var copy = self
        copy.styles.insert(.dim)
        return copy
    }

    /// Add strikethrough.
    public func strikethrough() -> Text {
        var copy = self
        copy.styles.insert(.strikethrough)
        return copy
    }

    /// Render to styled text.
    public func toStyledText() -> StyledText {
        var styled = StyledText(content)
        if let fg = foreground {
            styled = styled.foreground(fg)
        }
        if let bg = background {
            styled = styled.background(bg)
        }
        for style in styles {
            styled = styled.style(style)
        }
        return styled
    }
}

// MARK: - Color Shortcuts

extension Text {
    public var black: Text { foregroundColor(.black) }
    public var red: Text { foregroundColor(.red) }
    public var green: Text { foregroundColor(.green) }
    public var yellow: Text { foregroundColor(.yellow) }
    public var blue: Text { foregroundColor(.blue) }
    public var magenta: Text { foregroundColor(.magenta) }
    public var cyan: Text { foregroundColor(.cyan) }
    public var white: Text { foregroundColor(.white) }
    public var gray: Text { foregroundColor(.gray) }
}
