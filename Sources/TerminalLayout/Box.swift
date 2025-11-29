import ANSI
import TerminalStyle

/// A box with optional border and content.
public struct Box: Renderable, Sendable {
    /// Content lines.
    public let content: [String]

    /// Border style.
    public let style: BoxStyle

    /// Padding inside the box.
    public let padding: Padding

    /// Title (displayed in top border).
    public let title: String?

    /// Title alignment.
    public let titleAlignment: Alignment

    /// Border color.
    public let borderColor: ANSI.Color?

    /// Padding values.
    public struct Padding: Sendable {
        public let top: Int
        public let bottom: Int
        public let left: Int
        public let right: Int

        public init(top: Int = 0, bottom: Int = 0, left: Int = 0, right: Int = 0) {
            self.top = top
            self.bottom = bottom
            self.left = left
            self.right = right
        }

        public init(horizontal: Int = 0, vertical: Int = 0) {
            self.top = vertical
            self.bottom = vertical
            self.left = horizontal
            self.right = horizontal
        }

        public init(_ all: Int) {
            self.top = all
            self.bottom = all
            self.left = all
            self.right = all
        }

        public static let none = Padding()
        public static let small = Padding(horizontal: 1, vertical: 0)
        public static let medium = Padding(horizontal: 2, vertical: 1)
        public static let large = Padding(horizontal: 3, vertical: 2)
    }

    /// Text alignment.
    public enum Alignment: Sendable {
        case left
        case center
        case right
    }

    /// Create a box with string content.
    public init(
        _ content: String,
        style: BoxStyle = .rounded,
        padding: Padding = .small,
        title: String? = nil,
        titleAlignment: Alignment = .left,
        borderColor: ANSI.Color? = nil
    ) {
        self.content = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        self.style = style
        self.padding = padding
        self.title = title
        self.titleAlignment = titleAlignment
        self.borderColor = borderColor
    }

    /// Create a box with multiple lines.
    public init(
        lines: [String],
        style: BoxStyle = .rounded,
        padding: Padding = .small,
        title: String? = nil,
        titleAlignment: Alignment = .left,
        borderColor: ANSI.Color? = nil
    ) {
        self.content = lines
        self.style = style
        self.padding = padding
        self.title = title
        self.titleAlignment = titleAlignment
        self.borderColor = borderColor
    }

    /// Render the box.
    public func render(width: Int? = nil) -> String {
        let contentWidth = content.map { visibleLength($0) }.max() ?? 0
        let innerWidth = contentWidth + padding.left + padding.right
        let totalWidth = width.map { max($0 - 2, innerWidth) } ?? innerWidth

        var lines: [String] = []

        // Helper to apply border color
        func borderChar(_ char: Character) -> String {
            if let color = borderColor {
                return ANSI.Style.foreground(color) + String(char) + ANSI.Style.reset
            }
            return String(char)
        }

        // Top border
        var topBorder = borderChar(style.topLeft)
        if let title = title {
            let titleStr = " \(title) "
            let remainingWidth = totalWidth - visibleLength(titleStr)

            switch titleAlignment {
            case .left:
                topBorder += titleStr
                topBorder += String(repeating: style.horizontal, count: max(0, remainingWidth))
            case .center:
                let leftPad = remainingWidth / 2
                let rightPad = remainingWidth - leftPad
                topBorder += String(repeating: style.horizontal, count: max(0, leftPad))
                topBorder += titleStr
                topBorder += String(repeating: style.horizontal, count: max(0, rightPad))
            case .right:
                topBorder += String(repeating: style.horizontal, count: max(0, remainingWidth))
                topBorder += titleStr
            }
        } else {
            topBorder += String(repeating: style.horizontal, count: totalWidth)
        }
        topBorder += borderChar(style.topRight)
        lines.append(topBorder)

        // Top padding
        for _ in 0..<padding.top {
            lines.append(borderChar(style.vertical) + String(repeating: " ", count: totalWidth) + borderChar(style.vertical))
        }

        // Content lines
        for line in content {
            let lineLength = visibleLength(line)
            let leftPad = String(repeating: " ", count: padding.left)
            let rightPad = String(repeating: " ", count: max(0, totalWidth - lineLength - padding.left))
            lines.append(borderChar(style.vertical) + leftPad + line + rightPad + borderChar(style.vertical))
        }

        // Bottom padding
        for _ in 0..<padding.bottom {
            lines.append(borderChar(style.vertical) + String(repeating: " ", count: totalWidth) + borderChar(style.vertical))
        }

        // Bottom border
        let bottomBorder = borderChar(style.bottomLeft) +
                          String(repeating: style.horizontal, count: totalWidth) +
                          borderChar(style.bottomRight)
        lines.append(bottomBorder)

        return lines.joined(separator: "\n")
    }

    /// Calculate visible length (excluding ANSI codes).
    private func visibleLength(_ string: String) -> Int {
        // Remove ANSI escape sequences
        var result = string
        while let range = result.range(of: "\u{1B}\\[[0-9;]*[a-zA-Z]", options: .regularExpression) {
            result.removeSubrange(range)
        }
        // Also remove OSC sequences
        while let range = result.range(of: "\u{1B}\\][^\u{07}]*\u{07}", options: .regularExpression) {
            result.removeSubrange(range)
        }
        return result.count
    }
}

// MARK: - Convenience Initializers

extension Box {
    /// Create a simple box with text.
    public static func simple(_ text: String) -> Box {
        Box(text, style: .single, padding: .small)
    }

    /// Create a rounded box with text.
    public static func rounded(_ text: String) -> Box {
        Box(text, style: .rounded, padding: .small)
    }

    /// Create a double-bordered box.
    public static func double(_ text: String) -> Box {
        Box(text, style: .double, padding: .small)
    }

    /// Create a heavy-bordered box.
    public static func heavy(_ text: String) -> Box {
        Box(text, style: .heavy, padding: .small)
    }
}
