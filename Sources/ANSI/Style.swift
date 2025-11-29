/// SGR (Select Graphic Rendition) text styling sequences
extension ANSI {
    /// Text style and color sequences (SGR - Select Graphic Rendition)
    public enum Style: Sendable {
        // MARK: - Reset

        /// Reset all attributes to default
        public static let reset: String = "\(ANSI.CSI)0m"

        // MARK: - Text Styles

        /// Bold/bright
        public static let bold: String = "\(ANSI.CSI)1m"

        /// Dim/faint
        public static let dim: String = "\(ANSI.CSI)2m"

        /// Italic
        public static let italic: String = "\(ANSI.CSI)3m"

        /// Underline
        public static let underline: String = "\(ANSI.CSI)4m"

        /// Slow blink
        public static let blink: String = "\(ANSI.CSI)5m"

        /// Rapid blink (not widely supported)
        public static let rapidBlink: String = "\(ANSI.CSI)6m"

        /// Reverse video (swap foreground/background)
        public static let reverse: String = "\(ANSI.CSI)7m"

        /// Hidden/invisible text
        public static let hidden: String = "\(ANSI.CSI)8m"

        /// Strikethrough
        public static let strikethrough: String = "\(ANSI.CSI)9m"

        // MARK: - Style Resets

        /// Reset bold/dim
        public static let noBold: String = "\(ANSI.CSI)22m"

        /// Reset italic
        public static let noItalic: String = "\(ANSI.CSI)23m"

        /// Reset underline
        public static let noUnderline: String = "\(ANSI.CSI)24m"

        /// Reset blink
        public static let noBlink: String = "\(ANSI.CSI)25m"

        /// Reset reverse
        public static let noReverse: String = "\(ANSI.CSI)27m"

        /// Reset hidden
        public static let noHidden: String = "\(ANSI.CSI)28m"

        /// Reset strikethrough
        public static let noStrikethrough: String = "\(ANSI.CSI)29m"

        // MARK: - Underline Styles (not widely supported)

        /// Double underline
        public static let doubleUnderline: String = "\(ANSI.CSI)21m"

        /// Curly underline
        public static let curlyUnderline: String = "\(ANSI.CSI)4:3m"

        /// Dotted underline
        public static let dottedUnderline: String = "\(ANSI.CSI)4:4m"

        /// Dashed underline
        public static let dashedUnderline: String = "\(ANSI.CSI)4:5m"

        // MARK: - Foreground Colors (16-color)

        /// Set foreground to standard color
        public static func foreground(_ color: Color16) -> String {
            "\(ANSI.CSI)\(color.foregroundCode)m"
        }

        /// Set foreground to default
        public static let foregroundDefault: String = "\(ANSI.CSI)39m"

        // MARK: - Background Colors (16-color)

        /// Set background to standard color
        public static func background(_ color: Color16) -> String {
            "\(ANSI.CSI)\(color.backgroundCode)m"
        }

        /// Set background to default
        public static let backgroundDefault: String = "\(ANSI.CSI)49m"

        // MARK: - 256-Color

        /// Set foreground to 256-color palette
        public static func foreground(_ color: Color256) -> String {
            "\(ANSI.CSI)38;5;\(color.index)m"
        }

        /// Set background to 256-color palette
        public static func background(_ color: Color256) -> String {
            "\(ANSI.CSI)48;5;\(color.index)m"
        }

        // MARK: - True Color (24-bit)

        /// Set foreground to true color
        public static func foreground(_ color: TrueColor) -> String {
            "\(ANSI.CSI)38;2;\(color.red);\(color.green);\(color.blue)m"
        }

        /// Set foreground to RGB values
        public static func foreground(r: UInt8, g: UInt8, b: UInt8) -> String {
            "\(ANSI.CSI)38;2;\(r);\(g);\(b)m"
        }

        /// Set background to true color
        public static func background(_ color: TrueColor) -> String {
            "\(ANSI.CSI)48;2;\(color.red);\(color.green);\(color.blue)m"
        }

        /// Set background to RGB values
        public static func background(r: UInt8, g: UInt8, b: UInt8) -> String {
            "\(ANSI.CSI)48;2;\(r);\(g);\(b)m"
        }

        // MARK: - Unified Color

        /// Set foreground color (supports all color modes)
        public static func foreground(_ color: Color) -> String {
            switch color {
            case .default:
                return foregroundDefault
            case .standard(let c):
                return foreground(c)
            case .palette(let c):
                return foreground(c)
            case .rgb(let c):
                return foreground(c)
            }
        }

        /// Set background color (supports all color modes)
        public static func background(_ color: Color) -> String {
            switch color {
            case .default:
                return backgroundDefault
            case .standard(let c):
                return background(c)
            case .palette(let c):
                return background(c)
            case .rgb(let c):
                return background(c)
            }
        }

        // MARK: - Underline Color (not widely supported)

        /// Set underline color to 256-color palette
        public static func underlineColor(_ color: Color256) -> String {
            "\(ANSI.CSI)58;5;\(color.index)m"
        }

        /// Set underline color to true color
        public static func underlineColor(_ color: TrueColor) -> String {
            "\(ANSI.CSI)58;2;\(color.red);\(color.green);\(color.blue)m"
        }

        /// Reset underline color to default
        public static let underlineColorDefault: String = "\(ANSI.CSI)59m"

        // MARK: - Combined Sequences

        /// Combine multiple SGR parameters into one sequence
        public static func combined(_ codes: Int...) -> String {
            "\(ANSI.CSI)\(codes.map(String.init).joined(separator: ";"))m"
        }
    }
}
