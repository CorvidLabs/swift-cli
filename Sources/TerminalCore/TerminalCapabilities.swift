import Foundation

/// Detected terminal capabilities.
public struct TerminalCapabilities: Sendable {
    /// Maximum color depth supported.
    public let colorDepth: ColorDepth

    /// Whether the terminal supports Unicode.
    public let supportsUnicode: Bool

    /// Whether mouse input is supported.
    public let supportsMouse: Bool

    /// Whether the terminal supports the alternate screen buffer.
    public let supportsAlternateScreen: Bool

    /// Whether hyperlinks (OSC 8) are supported.
    public let supportsHyperlinks: Bool

    /// Whether synchronized output is supported.
    public let supportsSynchronizedOutput: Bool

    /// Whether the terminal supports 24-bit color.
    public let supportsTrueColor: Bool

    /// Image protocol support.
    public let imageProtocol: ImageProtocol?

    /// Terminal program name if detected.
    public let terminalProgram: String?

    /// Terminal emulator version if available.
    public let terminalVersion: String?

    /// Whether running in a TTY.
    public let isTTY: Bool

    /// Whether running in CI environment.
    public let isCI: Bool

    /// Color depth levels.
    public enum ColorDepth: Int, Sendable, Comparable {
        case none = 0
        case basic = 4       // 16 colors
        case palette256 = 8  // 256 colors
        case trueColor = 24  // 16 million colors

        public static func < (lhs: ColorDepth, rhs: ColorDepth) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// Supported image protocols.
    public enum ImageProtocol: String, Sendable {
        case iterm2 = "iterm2"
        case kitty = "kitty"
        case sixel = "sixel"
    }

    /// Detect terminal capabilities from environment.
    public static func detect() -> TerminalCapabilities {
        let env = ProcessInfo.processInfo.environment

        // Check if running in a TTY
        let isTTY = isatty(STDOUT_FILENO) != 0

        // Check for CI environment
        let isCI = env["CI"] != nil ||
                   env["GITHUB_ACTIONS"] != nil ||
                   env["TRAVIS"] != nil ||
                   env["CIRCLECI"] != nil ||
                   env["GITLAB_CI"] != nil

        // Detect terminal program
        let termProgram = env["TERM_PROGRAM"]
        let termVersion = env["TERM_PROGRAM_VERSION"]
        let term = env["TERM"] ?? ""

        // Detect color support
        let colorDepth = detectColorDepth(env: env, term: term, isTTY: isTTY)

        // Detect Unicode support
        let supportsUnicode = detectUnicodeSupport(env: env, term: term)

        // Detect image protocol
        let imageProtocol = detectImageProtocol(env: env, termProgram: termProgram)

        // Detect true color support
        let supportsTrueColor = colorDepth == .trueColor

        // Most modern terminals support these features
        let supportsAlternateScreen = isTTY && term != "dumb"
        let supportsMouse = isTTY && term != "dumb"

        // Hyperlink support (OSC 8)
        let supportsHyperlinks = detectHyperlinkSupport(termProgram: termProgram)

        // Synchronized output
        let supportsSynchronizedOutput = detectSynchronizedOutputSupport(termProgram: termProgram)

        return TerminalCapabilities(
            colorDepth: colorDepth,
            supportsUnicode: supportsUnicode,
            supportsMouse: supportsMouse,
            supportsAlternateScreen: supportsAlternateScreen,
            supportsHyperlinks: supportsHyperlinks,
            supportsSynchronizedOutput: supportsSynchronizedOutput,
            supportsTrueColor: supportsTrueColor,
            imageProtocol: imageProtocol,
            terminalProgram: termProgram,
            terminalVersion: termVersion,
            isTTY: isTTY,
            isCI: isCI
        )
    }

    private static func detectColorDepth(env: [String: String], term: String, isTTY: Bool) -> ColorDepth {
        // Check FORCE_COLOR
        if let forceColor = env["FORCE_COLOR"] {
            if forceColor == "0" || forceColor.lowercased() == "false" {
                return .none
            }
            return .trueColor
        }

        // Check NO_COLOR
        if env["NO_COLOR"] != nil {
            return .none
        }

        // Not a TTY, no colors
        if !isTTY {
            return .none
        }

        // Check for explicit color support
        if let colorterm = env["COLORTERM"] {
            if colorterm == "truecolor" || colorterm == "24bit" {
                return .trueColor
            }
        }

        // Check TERM_PROGRAM for known true color terminals
        if let termProgram = env["TERM_PROGRAM"] {
            let trueColorTerminals = [
                "iTerm.app", "Apple_Terminal", "Hyper", "vscode",
                "Terminus", "Tabby", "WezTerm", "Alacritty"
            ]
            if trueColorTerminals.contains(termProgram) {
                return .trueColor
            }
        }

        // Check TERM for color support
        if term.contains("256color") || term.contains("256") {
            return .palette256
        }

        if term.contains("color") || term.contains("xterm") || term.contains("screen") || term.contains("tmux") {
            return .basic
        }

        if term == "dumb" {
            return .none
        }

        // Default to basic color support for TTYs
        return .basic
    }

    private static func detectUnicodeSupport(env: [String: String], term: String) -> Bool {
        // Check LANG and LC_ALL for UTF-8
        let lang = env["LANG"] ?? ""
        let lcAll = env["LC_ALL"] ?? ""
        let lcCtype = env["LC_CTYPE"] ?? ""

        if lang.contains("UTF-8") || lang.contains("utf8") ||
           lcAll.contains("UTF-8") || lcAll.contains("utf8") ||
           lcCtype.contains("UTF-8") || lcCtype.contains("utf8") {
            return true
        }

        // Most modern terminals support Unicode
        if term != "dumb" && !term.isEmpty {
            return true
        }

        return false
    }

    private static func detectImageProtocol(env: [String: String], termProgram: String?) -> ImageProtocol? {
        // Check for Kitty
        if env["KITTY_WINDOW_ID"] != nil {
            return .kitty
        }

        // Check for iTerm2
        if let prog = termProgram, prog == "iTerm.app" {
            return .iterm2
        }

        // Check LC_TERMINAL
        if let lcTerminal = env["LC_TERMINAL"], lcTerminal.lowercased() == "iterm2" {
            return .iterm2
        }

        // Check TERM for sixel support
        if let term = env["TERM"], term.contains("sixel") {
            return .sixel
        }

        return nil
    }

    private static func detectHyperlinkSupport(termProgram: String?) -> Bool {
        guard let prog = termProgram else { return false }
        let supportedTerminals = [
            "iTerm.app", "WezTerm", "Tabby", "Hyper",
            "vscode", "Alacritty", "Kitty"
        ]
        return supportedTerminals.contains(prog)
    }

    private static func detectSynchronizedOutputSupport(termProgram: String?) -> Bool {
        guard let prog = termProgram else { return false }
        let supportedTerminals = [
            "iTerm.app", "WezTerm", "Kitty", "Alacritty"
        ]
        return supportedTerminals.contains(prog)
    }
}
