import ANSI

/// A theme for consistent styling across an application.
public struct Theme: Sendable {
    /// Primary text color.
    public var primary: ANSI.Color

    /// Secondary text color.
    public var secondary: ANSI.Color

    /// Success/positive color.
    public var success: ANSI.Color

    /// Warning color.
    public var warning: ANSI.Color

    /// Error/danger color.
    public var error: ANSI.Color

    /// Info/accent color.
    public var info: ANSI.Color

    /// Muted/dimmed color.
    public var muted: ANSI.Color

    /// Highlight/emphasis color.
    public var highlight: ANSI.Color

    /// Background color for panels.
    public var panelBackground: ANSI.Color?

    /// Border color.
    public var border: ANSI.Color

    /// Create a theme with custom colors.
    public init(
        primary: ANSI.Color = .white,
        secondary: ANSI.Color = .gray,
        success: ANSI.Color = .green,
        warning: ANSI.Color = .yellow,
        error: ANSI.Color = .red,
        info: ANSI.Color = .cyan,
        muted: ANSI.Color = .gray,
        highlight: ANSI.Color = .brightWhite,
        panelBackground: ANSI.Color? = nil,
        border: ANSI.Color = .gray
    ) {
        self.primary = primary
        self.secondary = secondary
        self.success = success
        self.warning = warning
        self.error = error
        self.info = info
        self.muted = muted
        self.highlight = highlight
        self.panelBackground = panelBackground
        self.border = border
    }

    /// Default theme.
    public static let `default` = Theme()

    /// Minimal theme with less color.
    public static let minimal = Theme(
        primary: .white,
        secondary: .gray,
        success: .white,
        warning: .white,
        error: .white,
        info: .white,
        muted: .gray,
        highlight: .white,
        panelBackground: nil,
        border: .gray
    )

    /// Vibrant theme with bright colors.
    public static let vibrant = Theme(
        primary: .brightWhite,
        secondary: .brightBlack,
        success: .brightGreen,
        warning: .brightYellow,
        error: .brightRed,
        info: .brightCyan,
        muted: .brightBlack,
        highlight: .brightMagenta,
        panelBackground: nil,
        border: .brightBlue
    )

    /// Ocean theme.
    public static let ocean = Theme(
        primary: .rgb(ANSI.TrueColor(r: 200, g: 220, b: 255)),
        secondary: .rgb(ANSI.TrueColor(r: 100, g: 140, b: 180)),
        success: .rgb(ANSI.TrueColor(r: 100, g: 220, b: 150)),
        warning: .rgb(ANSI.TrueColor(r: 255, g: 200, b: 100)),
        error: .rgb(ANSI.TrueColor(r: 255, g: 100, b: 120)),
        info: .rgb(ANSI.TrueColor(r: 100, g: 200, b: 255)),
        muted: .rgb(ANSI.TrueColor(r: 80, g: 100, b: 120)),
        highlight: .rgb(ANSI.TrueColor(r: 255, g: 255, b: 255)),
        panelBackground: .rgb(ANSI.TrueColor(r: 20, g: 30, b: 50)),
        border: .rgb(ANSI.TrueColor(r: 60, g: 80, b: 120))
    )

    /// Forest theme.
    public static let forest = Theme(
        primary: .rgb(ANSI.TrueColor(r: 200, g: 230, b: 200)),
        secondary: .rgb(ANSI.TrueColor(r: 120, g: 160, b: 120)),
        success: .rgb(ANSI.TrueColor(r: 100, g: 200, b: 100)),
        warning: .rgb(ANSI.TrueColor(r: 220, g: 180, b: 80)),
        error: .rgb(ANSI.TrueColor(r: 220, g: 80, b: 80)),
        info: .rgb(ANSI.TrueColor(r: 100, g: 180, b: 200)),
        muted: .rgb(ANSI.TrueColor(r: 80, g: 100, b: 80)),
        highlight: .rgb(ANSI.TrueColor(r: 255, g: 255, b: 200)),
        panelBackground: .rgb(ANSI.TrueColor(r: 20, g: 35, b: 20)),
        border: .rgb(ANSI.TrueColor(r: 60, g: 100, b: 60))
    )
}

// MARK: - Theme Application

extension StyledText {
    /// Apply theme's primary color.
    public func primary(_ theme: Theme) -> StyledText {
        foreground(theme.primary)
    }

    /// Apply theme's secondary color.
    public func secondary(_ theme: Theme) -> StyledText {
        foreground(theme.secondary)
    }

    /// Apply theme's success color.
    public func success(_ theme: Theme) -> StyledText {
        foreground(theme.success)
    }

    /// Apply theme's warning color.
    public func warning(_ theme: Theme) -> StyledText {
        foreground(theme.warning)
    }

    /// Apply theme's error color.
    public func error(_ theme: Theme) -> StyledText {
        foreground(theme.error)
    }

    /// Apply theme's info color.
    public func info(_ theme: Theme) -> StyledText {
        foreground(theme.info)
    }

    /// Apply theme's muted color.
    public func muted(_ theme: Theme) -> StyledText {
        foreground(theme.muted)
    }

    /// Apply theme's highlight color.
    public func highlight(_ theme: Theme) -> StyledText {
        foreground(theme.highlight)
    }
}
