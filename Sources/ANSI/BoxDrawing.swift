/// Unicode box drawing characters
extension ANSI {
    /// Box drawing characters for creating borders and frames
    public enum Box: Sendable {
        // MARK: - Single Line

        /// Single line box drawing characters
        public enum Single: Sendable {
            public static let horizontal: Character = "─"
            public static let vertical: Character = "│"
            public static let topLeft: Character = "┌"
            public static let topRight: Character = "┐"
            public static let bottomLeft: Character = "└"
            public static let bottomRight: Character = "┘"
            public static let verticalRight: Character = "├"
            public static let verticalLeft: Character = "┤"
            public static let horizontalDown: Character = "┬"
            public static let horizontalUp: Character = "┴"
            public static let cross: Character = "┼"
        }

        // MARK: - Double Line

        /// Double line box drawing characters
        public enum Double: Sendable {
            public static let horizontal: Character = "═"
            public static let vertical: Character = "║"
            public static let topLeft: Character = "╔"
            public static let topRight: Character = "╗"
            public static let bottomLeft: Character = "╚"
            public static let bottomRight: Character = "╝"
            public static let verticalRight: Character = "╠"
            public static let verticalLeft: Character = "╣"
            public static let horizontalDown: Character = "╦"
            public static let horizontalUp: Character = "╩"
            public static let cross: Character = "╬"
        }

        // MARK: - Rounded

        /// Rounded corner box drawing characters
        public enum Rounded: Sendable {
            public static let horizontal: Character = "─"
            public static let vertical: Character = "│"
            public static let topLeft: Character = "╭"
            public static let topRight: Character = "╮"
            public static let bottomLeft: Character = "╰"
            public static let bottomRight: Character = "╯"
            public static let verticalRight: Character = "├"
            public static let verticalLeft: Character = "┤"
            public static let horizontalDown: Character = "┬"
            public static let horizontalUp: Character = "┴"
            public static let cross: Character = "┼"
        }

        // MARK: - Heavy (Bold)

        /// Heavy/bold box drawing characters
        public enum Heavy: Sendable {
            public static let horizontal: Character = "━"
            public static let vertical: Character = "┃"
            public static let topLeft: Character = "┏"
            public static let topRight: Character = "┓"
            public static let bottomLeft: Character = "┗"
            public static let bottomRight: Character = "┛"
            public static let verticalRight: Character = "┣"
            public static let verticalLeft: Character = "┫"
            public static let horizontalDown: Character = "┳"
            public static let horizontalUp: Character = "┻"
            public static let cross: Character = "╋"
        }

        // MARK: - ASCII

        /// ASCII-only box drawing (fallback for non-Unicode terminals)
        public enum ASCII: Sendable {
            public static let horizontal: Character = "-"
            public static let vertical: Character = "|"
            public static let topLeft: Character = "+"
            public static let topRight: Character = "+"
            public static let bottomLeft: Character = "+"
            public static let bottomRight: Character = "+"
            public static let verticalRight: Character = "+"
            public static let verticalLeft: Character = "+"
            public static let horizontalDown: Character = "+"
            public static let horizontalUp: Character = "+"
            public static let cross: Character = "+"
        }

        // MARK: - Block Elements

        /// Block elements for progress bars and fills
        public enum Block: Sendable {
            public static let full: Character = "█"
            public static let sevenEighths: Character = "▉"
            public static let threeQuarters: Character = "▊"
            public static let fiveEighths: Character = "▋"
            public static let half: Character = "▌"
            public static let threeEighths: Character = "▍"
            public static let quarter: Character = "▎"
            public static let eighth: Character = "▏"

            public static let lightShade: Character = "░"
            public static let mediumShade: Character = "▒"
            public static let darkShade: Character = "▓"

            public static let upperHalf: Character = "▀"
            public static let lowerHalf: Character = "▄"
            public static let leftHalf: Character = "▌"
            public static let rightHalf: Character = "▐"

            /// Horizontal progress bar segments (0-8)
            public static let horizontalSegments: [Character] = [
                " ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", "█"
            ]

            /// Vertical progress bar segments (0-8)
            public static let verticalSegments: [Character] = [
                " ", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"
            ]
        }

        // MARK: - Spinners

        /// Spinner/loading animation frames
        public enum Spinner: Sendable {
            /// Braille dots spinner
            public static let dots: [String] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

            /// Line spinner
            public static let line: [String] = ["-", "\\", "|", "/"]

            /// Growing dots
            public static let growingDots: [String] = [".  ", ".. ", "...", ".. ", ".  ", "   "]

            /// Circle quarters
            public static let circle: [String] = ["◐", "◓", "◑", "◒"]

            /// Arc spinner
            public static let arc: [String] = ["◜", "◠", "◝", "◞", "◡", "◟"]

            /// Box spinner
            public static let box: [String] = ["▖", "▘", "▝", "▗"]

            /// Arrow spinner
            public static let arrow: [String] = ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"]

            /// Bouncing bar
            public static let bounce: [String] = ["[    ]", "[=   ]", "[==  ]", "[=== ]", "[ ===]", "[  ==]", "[   =]", "[    ]"]

            /// Clock spinner
            public static let clock: [String] = ["🕛", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚"]
        }

        // MARK: - Symbols

        /// Common symbols
        public enum Symbol: Sendable {
            public static let checkmark: Character = "✓"
            public static let cross: Character = "✗"
            public static let bullet: Character = "•"
            public static let arrow: Character = "→"
            public static let arrowRight: Character = "→"
            public static let arrowLeft: Character = "←"
            public static let arrowUp: Character = "↑"
            public static let arrowDown: Character = "↓"
            public static let ellipsis: Character = "…"
            public static let info: Character = "ℹ"
            public static let warning: Character = "⚠"
            public static let star: Character = "★"
            public static let starOutline: Character = "☆"
            public static let heart: Character = "♥"
            public static let diamond: Character = "◆"
            public static let circle: Character = "●"
            public static let circleOutline: Character = "○"
            public static let square: Character = "■"
            public static let squareOutline: Character = "□"
            public static let triangleRight: Character = "▶"
            public static let triangleLeft: Character = "◀"
            public static let triangleUp: Character = "▲"
            public static let triangleDown: Character = "▼"
        }
    }
}
