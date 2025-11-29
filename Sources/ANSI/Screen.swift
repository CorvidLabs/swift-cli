/// Screen mode and control sequences
extension ANSI {
    /// Screen buffer and mode control sequences
    public enum Screen: Sendable {
        // MARK: - Alternate Screen Buffer

        /// Enter alternate screen buffer
        public static let enterAlternate: String = "\(ANSI.CSI)?1049h"

        /// Exit alternate screen buffer
        public static let exitAlternate: String = "\(ANSI.CSI)?1049l"

        /// Enter alternate screen and save cursor
        public static let enterAlternateSaveCursor: String = "\(ANSI.CSI)?1049h\(ANSI.CSI)?25l"

        // MARK: - Line Wrapping

        /// Enable line wrapping
        public static let enableLineWrap: String = "\(ANSI.CSI)?7h"

        /// Disable line wrapping
        public static let disableLineWrap: String = "\(ANSI.CSI)?7l"

        // MARK: - Title

        /// Set terminal window title
        public static func title(_ title: String) -> String {
            "\(ANSI.OSC)0;\(title)\(ANSI.BEL)"
        }

        /// Set terminal window title (using ST terminator)
        public static func titleST(_ title: String) -> String {
            "\(ANSI.OSC)0;\(title)\(ANSI.ST)"
        }

        /// Set icon name
        public static func iconName(_ name: String) -> String {
            "\(ANSI.OSC)1;\(name)\(ANSI.BEL)"
        }

        /// Set window title only (not icon)
        public static func windowTitle(_ title: String) -> String {
            "\(ANSI.OSC)2;\(title)\(ANSI.BEL)"
        }

        // MARK: - Bracketed Paste Mode

        /// Enable bracketed paste mode
        public static let enableBracketedPaste: String = "\(ANSI.CSI)?2004h"

        /// Disable bracketed paste mode
        public static let disableBracketedPaste: String = "\(ANSI.CSI)?2004l"

        // MARK: - Focus Events

        /// Enable focus event reporting
        public static let enableFocusEvents: String = "\(ANSI.CSI)?1004h"

        /// Disable focus event reporting
        public static let disableFocusEvents: String = "\(ANSI.CSI)?1004l"

        // MARK: - Mouse Tracking

        /// Mouse tracking modes
        public enum MouseMode: Sendable {
            /// Normal tracking - button press/release
            case normal
            /// Button event tracking - includes motion while button pressed
            case buttonEvent
            /// Any event tracking - includes all motion
            case anyEvent
        }

        /// Enable mouse tracking
        public static func enableMouse(_ mode: MouseMode = .normal) -> String {
            switch mode {
            case .normal:
                return "\(ANSI.CSI)?1000h"
            case .buttonEvent:
                return "\(ANSI.CSI)?1002h"
            case .anyEvent:
                return "\(ANSI.CSI)?1003h"
            }
        }

        /// Disable mouse tracking
        public static let disableMouse: String = "\(ANSI.CSI)?1000l\(ANSI.CSI)?1002l\(ANSI.CSI)?1003l"

        /// Enable SGR extended mouse mode (for coordinates > 223)
        public static let enableSGRMouse: String = "\(ANSI.CSI)?1006h"

        /// Disable SGR extended mouse mode
        public static let disableSGRMouse: String = "\(ANSI.CSI)?1006l"

        // MARK: - Soft Reset

        /// Soft terminal reset
        public static let softReset: String = "\(ANSI.CSI)!p"
    }
}
