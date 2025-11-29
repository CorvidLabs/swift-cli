/// Screen and line erase sequences
extension ANSI {
    /// Screen and line erasing sequences
    public enum Erase: Sendable {
        // MARK: - Screen

        /// Clear from cursor to end of screen
        public static let screenFromCursor: String = "\(ANSI.CSI)0J"

        /// Clear from beginning of screen to cursor
        public static let screenToCursor: String = "\(ANSI.CSI)1J"

        /// Clear entire screen
        public static let screen: String = "\(ANSI.CSI)2J"

        /// Clear entire screen and scrollback buffer
        public static let screenAndScrollback: String = "\(ANSI.CSI)3J"

        // MARK: - Line

        /// Clear from cursor to end of line
        public static let lineFromCursor: String = "\(ANSI.CSI)0K"

        /// Clear from beginning of line to cursor
        public static let lineToCursor: String = "\(ANSI.CSI)1K"

        /// Clear entire line
        public static let line: String = "\(ANSI.CSI)2K"

        // MARK: - Characters

        /// Delete n characters at cursor position
        public static func characters(_ n: Int) -> String {
            "\(ANSI.CSI)\(n)P"
        }

        /// Insert n blank characters at cursor position
        public static func insertCharacters(_ n: Int) -> String {
            "\(ANSI.CSI)\(n)@"
        }

        /// Insert n blank lines at cursor position
        public static func insertLines(_ n: Int) -> String {
            "\(ANSI.CSI)\(n)L"
        }

        /// Delete n lines at cursor position
        public static func deleteLines(_ n: Int) -> String {
            "\(ANSI.CSI)\(n)M"
        }
    }
}
