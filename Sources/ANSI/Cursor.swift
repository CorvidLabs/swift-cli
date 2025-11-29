/// Cursor control escape sequences
extension ANSI {
    /// Cursor movement and control sequences
    public enum Cursor: Sendable {
        // MARK: - Movement

        /// Move cursor up by n lines
        public static func up(_ n: Int = 1) -> String {
            "\(ANSI.CSI)\(n)A"
        }

        /// Move cursor down by n lines
        public static func down(_ n: Int = 1) -> String {
            "\(ANSI.CSI)\(n)B"
        }

        /// Move cursor forward (right) by n columns
        public static func forward(_ n: Int = 1) -> String {
            "\(ANSI.CSI)\(n)C"
        }

        /// Move cursor backward (left) by n columns
        public static func backward(_ n: Int = 1) -> String {
            "\(ANSI.CSI)\(n)D"
        }

        /// Move cursor to beginning of line n lines down
        public static func nextLine(_ n: Int = 1) -> String {
            "\(ANSI.CSI)\(n)E"
        }

        /// Move cursor to beginning of line n lines up
        public static func previousLine(_ n: Int = 1) -> String {
            "\(ANSI.CSI)\(n)F"
        }

        /// Move cursor to column n (1-based)
        public static func column(_ n: Int) -> String {
            "\(ANSI.CSI)\(n)G"
        }

        /// Move cursor to row and column (1-based)
        public static func position(row: Int, column: Int) -> String {
            "\(ANSI.CSI)\(row);\(column)H"
        }

        /// Move cursor to row and column (1-based) - alternate form
        public static func moveTo(row: Int, column: Int) -> String {
            "\(ANSI.CSI)\(row);\(column)f"
        }

        /// Move cursor to home position (1,1)
        public static let home: String = "\(ANSI.CSI)H"

        // MARK: - Visibility

        /// Hide cursor
        public static let hide: String = "\(ANSI.CSI)?25l"

        /// Show cursor
        public static let show: String = "\(ANSI.CSI)?25h"

        // MARK: - Save/Restore

        /// Save cursor position (DEC)
        public static let save: String = "\(ANSI.CSI)s"

        /// Restore cursor position (DEC)
        public static let restore: String = "\(ANSI.CSI)u"

        /// Save cursor position (SCO)
        public static let saveSCO: String = "\(ANSI.ESC)7"

        /// Restore cursor position (SCO)
        public static let restoreSCO: String = "\(ANSI.ESC)8"

        // MARK: - Cursor Style

        /// Cursor shape styles
        public enum Shape: Int, Sendable {
            case `default` = 0
            case blinkingBlock = 1
            case steadyBlock = 2
            case blinkingUnderline = 3
            case steadyUnderline = 4
            case blinkingBar = 5
            case steadyBar = 6
        }

        /// Set cursor shape
        public static func shape(_ shape: Shape) -> String {
            "\(ANSI.CSI)\(shape.rawValue) q"
        }

        // MARK: - Scrolling

        /// Scroll up by n lines
        public static func scrollUp(_ n: Int = 1) -> String {
            "\(ANSI.CSI)\(n)S"
        }

        /// Scroll down by n lines
        public static func scrollDown(_ n: Int = 1) -> String {
            "\(ANSI.CSI)\(n)T"
        }

        /// Set scroll region (top and bottom rows, 1-based)
        public static func setScrollRegion(top: Int, bottom: Int) -> String {
            "\(ANSI.CSI)\(top);\(bottom)r"
        }

        /// Reset scroll region to full screen
        public static let resetScrollRegion: String = "\(ANSI.CSI)r"

        // MARK: - Request

        /// Request cursor position (response: ESC[row;columnR)
        public static let requestPosition: String = "\(ANSI.CSI)6n"
    }
}
