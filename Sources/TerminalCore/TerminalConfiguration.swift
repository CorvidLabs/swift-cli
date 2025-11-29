/// Configuration options for terminal behavior.
public struct TerminalConfiguration: Sendable {
    /// Color output mode.
    public var colorMode: ColorMode

    /// Whether to force color output regardless of capability detection.
    public var forceColor: Bool

    /// Whether to use Unicode box drawing characters.
    public var useUnicode: Bool

    /// Whether to enable mouse tracking by default.
    public var enableMouse: Bool

    /// Whether to use the alternate screen buffer for full-screen apps.
    public var useAlternateScreen: Bool

    /// Create a configuration with specified options.
    public init(
        colorMode: ColorMode = .auto,
        forceColor: Bool = false,
        useUnicode: Bool = true,
        enableMouse: Bool = false,
        useAlternateScreen: Bool = false
    ) {
        self.colorMode = colorMode
        self.forceColor = forceColor
        self.useUnicode = useUnicode
        self.enableMouse = enableMouse
        self.useAlternateScreen = useAlternateScreen
    }

    /// Default configuration.
    public static let `default` = TerminalConfiguration()

    /// Configuration optimized for full-screen TUI apps.
    public static let fullscreen = TerminalConfiguration(
        colorMode: .auto,
        forceColor: false,
        useUnicode: true,
        enableMouse: true,
        useAlternateScreen: true
    )

    /// Minimal configuration for basic CLI output.
    public static let minimal = TerminalConfiguration(
        colorMode: .none,
        forceColor: false,
        useUnicode: false,
        enableMouse: false,
        useAlternateScreen: false
    )
}

/// Color output modes.
public enum ColorMode: Sendable {
    /// Automatically detect color support.
    case auto

    /// No color output.
    case none

    /// 16 standard ANSI colors.
    case basic

    /// 256 color palette.
    case palette256

    /// 24-bit true color.
    case trueColor
}
