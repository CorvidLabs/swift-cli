/// ANSI - Pure ANSI escape code generation
///
/// This package provides type-safe generation of ANSI escape sequences
/// with zero dependencies. No I/O operations - just string generation.
///
/// ## Usage
///
/// ```swift
/// import ANSI
///
/// // Control sequences
/// let up = ANSI.Cursor.up(5)           // Move cursor up 5 lines
/// let clear = ANSI.Erase.screen        // Clear entire screen
///
/// // Colors and styles
/// let red = ANSI.Style.foreground(.red)
/// let bold = ANSI.Style.bold
/// let reset = ANSI.Style.reset
///
/// // Compose escape sequences
/// print("\(red)\(bold)Error!\(reset)")
/// ```
public enum ANSI: Sendable {
    /// Escape character (ESC, 0x1B)
    public static let escape: Character = "\u{1B}"

    /// Escape string
    public static let ESC: String = "\u{1B}"

    /// Control Sequence Introducer (ESC [)
    public static let CSI: String = "\u{1B}["

    /// Operating System Command (ESC ])
    public static let OSC: String = "\u{1B}]"

    /// Device Control String (ESC P)
    public static let DCS: String = "\u{1B}P"

    /// String Terminator (ESC \)
    public static let ST: String = "\u{1B}\\"

    /// Bell character
    public static let BEL: String = "\u{07}"

    /// Backspace
    public static let BS: String = "\u{08}"

    /// Horizontal Tab
    public static let HT: String = "\u{09}"

    /// Line Feed
    public static let LF: String = "\u{0A}"

    /// Carriage Return
    public static let CR: String = "\u{0D}"
}
