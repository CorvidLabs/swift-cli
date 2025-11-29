import ANSI

/// String extensions for chainable styling.
extension String {
    // MARK: - Text Styles

    /// Make text bold.
    public var bold: StyledText {
        StyledText(self).bold
    }

    /// Make text dim/faint.
    public var dim: StyledText {
        StyledText(self).dim
    }

    /// Make text italic.
    public var italic: StyledText {
        StyledText(self).italic
    }

    /// Make text underlined.
    public var underline: StyledText {
        StyledText(self).underline
    }

    /// Make text blink.
    public var blink: StyledText {
        StyledText(self).blink
    }

    /// Reverse foreground and background colors.
    public var reverse: StyledText {
        StyledText(self).reverse
    }

    /// Hide text (invisible but takes up space).
    public var hidden: StyledText {
        StyledText(self).hidden
    }

    /// Add strikethrough.
    public var strikethrough: StyledText {
        StyledText(self).strikethrough
    }

    // MARK: - Foreground Colors (Standard)

    /// Black foreground.
    public var black: StyledText {
        StyledText(self).black
    }

    /// Red foreground.
    public var red: StyledText {
        StyledText(self).red
    }

    /// Green foreground.
    public var green: StyledText {
        StyledText(self).green
    }

    /// Yellow foreground.
    public var yellow: StyledText {
        StyledText(self).yellow
    }

    /// Blue foreground.
    public var blue: StyledText {
        StyledText(self).blue
    }

    /// Magenta foreground.
    public var magenta: StyledText {
        StyledText(self).magenta
    }

    /// Cyan foreground.
    public var cyan: StyledText {
        StyledText(self).cyan
    }

    /// White foreground.
    public var white: StyledText {
        StyledText(self).white
    }

    /// Gray foreground.
    public var gray: StyledText {
        StyledText(self).gray
    }

    /// Grey foreground (alias for gray).
    public var grey: StyledText {
        StyledText(self).grey
    }

    // MARK: - Foreground Colors (Bright)

    /// Bright black foreground.
    public var brightBlack: StyledText {
        StyledText(self).brightBlack
    }

    /// Bright red foreground.
    public var brightRed: StyledText {
        StyledText(self).brightRed
    }

    /// Bright green foreground.
    public var brightGreen: StyledText {
        StyledText(self).brightGreen
    }

    /// Bright yellow foreground.
    public var brightYellow: StyledText {
        StyledText(self).brightYellow
    }

    /// Bright blue foreground.
    public var brightBlue: StyledText {
        StyledText(self).brightBlue
    }

    /// Bright magenta foreground.
    public var brightMagenta: StyledText {
        StyledText(self).brightMagenta
    }

    /// Bright cyan foreground.
    public var brightCyan: StyledText {
        StyledText(self).brightCyan
    }

    /// Bright white foreground.
    public var brightWhite: StyledText {
        StyledText(self).brightWhite
    }

    // MARK: - Background Colors

    /// Black background.
    public var onBlack: StyledText {
        StyledText(self).onBlack
    }

    /// Red background.
    public var onRed: StyledText {
        StyledText(self).onRed
    }

    /// Green background.
    public var onGreen: StyledText {
        StyledText(self).onGreen
    }

    /// Yellow background.
    public var onYellow: StyledText {
        StyledText(self).onYellow
    }

    /// Blue background.
    public var onBlue: StyledText {
        StyledText(self).onBlue
    }

    /// Magenta background.
    public var onMagenta: StyledText {
        StyledText(self).onMagenta
    }

    /// Cyan background.
    public var onCyan: StyledText {
        StyledText(self).onCyan
    }

    /// White background.
    public var onWhite: StyledText {
        StyledText(self).onWhite
    }

    // MARK: - Color Methods

    /// Set foreground color.
    public func foreground(_ color: ANSI.Color) -> StyledText {
        StyledText(self).foreground(color)
    }

    /// Set background color.
    public func background(_ color: ANSI.Color) -> StyledText {
        StyledText(self).background(color)
    }

    /// Set foreground to RGB color.
    public func rgb(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> StyledText {
        StyledText(self).rgb(r, g, b)
    }

    /// Set foreground to hex color.
    public func hex(_ value: UInt32) -> StyledText {
        StyledText(self).hex(value)
    }

    /// Set background to RGB color.
    public func onRGB(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> StyledText {
        StyledText(self).onRGB(r, g, b)
    }

    /// Set background to hex color.
    public func onHex(_ value: UInt32) -> StyledText {
        StyledText(self).onHex(value)
    }

    // MARK: - Hyperlink

    /// Make text a hyperlink.
    public func link(_ url: String) -> StyledText {
        StyledText(self).link(url)
    }

    /// Convert to styled text (no styling applied).
    public var styled: StyledText {
        StyledText(self)
    }
}
