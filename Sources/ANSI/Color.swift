/// ANSI color definitions
extension ANSI {
    /// Standard 16 ANSI colors
    public enum Color16: Int, Sendable, CaseIterable {
        case black = 0
        case red = 1
        case green = 2
        case yellow = 3
        case blue = 4
        case magenta = 5
        case cyan = 6
        case white = 7

        // Bright variants
        case brightBlack = 8
        case brightRed = 9
        case brightGreen = 10
        case brightYellow = 11
        case brightBlue = 12
        case brightMagenta = 13
        case brightCyan = 14
        case brightWhite = 15

        /// Alias for brightBlack
        public static let gray: Color16 = .brightBlack

        /// Alias for brightBlack
        public static let grey: Color16 = .brightBlack

        /// SGR code for foreground
        public var foregroundCode: Int {
            rawValue < 8 ? 30 + rawValue : 90 + (rawValue - 8)
        }

        /// SGR code for background
        public var backgroundCode: Int {
            rawValue < 8 ? 40 + rawValue : 100 + (rawValue - 8)
        }
    }

    /// 256-color palette index (0-255)
    public struct Color256: Sendable, Equatable, Hashable, ExpressibleByIntegerLiteral {
        public let index: UInt8

        public init(_ index: UInt8) {
            self.index = index
        }

        public init(integerLiteral value: UInt8) {
            self.index = value
        }

        /// Create a color from the 6x6x6 color cube (r, g, b each 0-5)
        public static func cube(r: UInt8, g: UInt8, b: UInt8) -> Color256 {
            let r = min(r, 5)
            let g = min(g, 5)
            let b = min(b, 5)
            return Color256(16 + 36 * r + 6 * g + b)
        }

        /// Create a grayscale color (0-23, where 0 is dark and 23 is light)
        public static func grayscale(_ level: UInt8) -> Color256 {
            Color256(232 + min(level, 23))
        }

        // Standard colors as Color256
        public static let black: Color256 = 0
        public static let red: Color256 = 1
        public static let green: Color256 = 2
        public static let yellow: Color256 = 3
        public static let blue: Color256 = 4
        public static let magenta: Color256 = 5
        public static let cyan: Color256 = 6
        public static let white: Color256 = 7
    }

    /// True color (24-bit RGB)
    public struct TrueColor: Sendable, Equatable, Hashable {
        public let red: UInt8
        public let green: UInt8
        public let blue: UInt8

        public init(red: UInt8, green: UInt8, blue: UInt8) {
            self.red = red
            self.green = green
            self.blue = blue
        }

        public init(r: UInt8, g: UInt8, b: UInt8) {
            self.red = r
            self.green = g
            self.blue = b
        }

        /// Create from hex value (e.g., 0xFF5500)
        public init(hex: UInt32) {
            self.red = UInt8((hex >> 16) & 0xFF)
            self.green = UInt8((hex >> 8) & 0xFF)
            self.blue = UInt8(hex & 0xFF)
        }

        /// Create from hex string (e.g., "#FF5500" or "FF5500")
        public init?(hexString: String) {
            var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            if hex.hasPrefix("#") {
                hex.removeFirst()
            }
            guard hex.count == 6, let value = UInt32(hex, radix: 16) else {
                return nil
            }
            self.init(hex: value)
        }

        // Common colors
        public static let black = TrueColor(r: 0, g: 0, b: 0)
        public static let white = TrueColor(r: 255, g: 255, b: 255)
        public static let red = TrueColor(r: 255, g: 0, b: 0)
        public static let green = TrueColor(r: 0, g: 255, b: 0)
        public static let blue = TrueColor(r: 0, g: 0, b: 255)
        public static let yellow = TrueColor(r: 255, g: 255, b: 0)
        public static let magenta = TrueColor(r: 255, g: 0, b: 255)
        public static let cyan = TrueColor(r: 0, g: 255, b: 255)
        public static let orange = TrueColor(r: 255, g: 165, b: 0)
        public static let pink = TrueColor(r: 255, g: 192, b: 203)
        public static let purple = TrueColor(r: 128, g: 0, b: 128)
        public static let gray = TrueColor(r: 128, g: 128, b: 128)
        public static let grey = gray
    }

    /// Unified color type supporting all color modes
    public enum Color: Sendable, Equatable, Hashable {
        case `default`
        case standard(Color16)
        case palette(Color256)
        case rgb(TrueColor)

        // Convenience initializers
        public static func rgb(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> Color {
            .rgb(TrueColor(r: r, g: g, b: b))
        }

        public static func hex(_ value: UInt32) -> Color {
            .rgb(TrueColor(hex: value))
        }

        public static func palette(_ index: UInt8) -> Color {
            .palette(Color256(index))
        }

        // Standard color shortcuts
        public static let black: Color = .standard(.black)
        public static let red: Color = .standard(.red)
        public static let green: Color = .standard(.green)
        public static let yellow: Color = .standard(.yellow)
        public static let blue: Color = .standard(.blue)
        public static let magenta: Color = .standard(.magenta)
        public static let cyan: Color = .standard(.cyan)
        public static let white: Color = .standard(.white)

        public static let brightBlack: Color = .standard(.brightBlack)
        public static let brightRed: Color = .standard(.brightRed)
        public static let brightGreen: Color = .standard(.brightGreen)
        public static let brightYellow: Color = .standard(.brightYellow)
        public static let brightBlue: Color = .standard(.brightBlue)
        public static let brightMagenta: Color = .standard(.brightMagenta)
        public static let brightCyan: Color = .standard(.brightCyan)
        public static let brightWhite: Color = .standard(.brightWhite)

        public static let gray: Color = .standard(.gray)
        public static let grey: Color = .standard(.grey)
    }
}
