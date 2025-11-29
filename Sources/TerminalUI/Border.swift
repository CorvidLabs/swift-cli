import ANSI
import TerminalLayout

/// A view modifier that adds a border around content.
public struct BorderedView<Content: View>: View, Sendable {
    public let content: Content
    public let style: BoxStyle
    public let title: String?
    public let borderColor: ANSI.Color?

    public init(
        content: Content,
        style: BoxStyle = .rounded,
        title: String? = nil,
        borderColor: ANSI.Color? = nil
    ) {
        self.content = content
        self.style = style
        self.title = title
        self.borderColor = borderColor
    }

    public var body: Never {
        fatalError("BorderedView is rendered directly")
    }
}

extension BorderedView: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        // Render content with reduced size (accounting for border)
        let contentSize = Size(
            width: max(0, size.width - 2),
            height: max(0, size.height - 2)
        )
        let contentLines = RenderEngine.render(AnyView(content), size: contentSize)

        // Calculate the max content width (clamped to available space)
        let rawMaxWidth = contentLines.map { visibleLength($0) }.max() ?? 0
        let maxContentWidth = min(rawMaxWidth, contentSize.width)

        // Helper to apply border color
        func colorize(_ char: Character) -> String {
            let str = String(char)
            if let color = borderColor {
                return ANSI.Style.foreground(color) + str + ANSI.Style.reset
            }
            return str
        }

        var result: [String] = []

        // Top border with optional title
        var topLine = colorize(style.topLeft)
        if let title = title, !title.isEmpty {
            let titleText = " \(title) "
            let remainingWidth = maxContentWidth - visibleLength(titleText)
            if remainingWidth >= 0 {
                topLine += titleText
                topLine += String(repeating: colorize(style.horizontal), count: remainingWidth)
            } else {
                topLine += String(repeating: colorize(style.horizontal), count: maxContentWidth)
            }
        } else {
            topLine += String(repeating: colorize(style.horizontal), count: maxContentWidth)
        }
        topLine += colorize(style.topRight)
        result.append(topLine)

        // Content lines with side borders
        for line in contentLines {
            let lineWidth = visibleLength(line)
            // Truncate line if wider than max width
            let truncatedLine: String
            if lineWidth > maxContentWidth {
                truncatedLine = truncateToWidth(line, width: maxContentWidth, visibleLength: visibleLength)
            } else {
                truncatedLine = line
            }
            let truncatedWidth = visibleLength(truncatedLine)
            let padding = String(repeating: " ", count: max(0, maxContentWidth - truncatedWidth))
            result.append(colorize(style.vertical) + truncatedLine + padding + colorize(style.vertical))
        }

        // Handle empty content
        if contentLines.isEmpty {
            let emptyLine = String(repeating: " ", count: maxContentWidth)
            result.append(colorize(style.vertical) + emptyLine + colorize(style.vertical))
        }

        // Bottom border
        var bottomLine = colorize(style.bottomLeft)
        bottomLine += String(repeating: colorize(style.horizontal), count: maxContentWidth)
        bottomLine += colorize(style.bottomRight)
        result.append(bottomLine)

        return result
    }

    /// Truncate a string to fit within a given visible width, preserving ANSI codes.
    private func truncateToWidth(_ string: String, width: Int, visibleLength: (String) -> Int) -> String {
        var result = ""
        var visibleCount = 0
        var inEscape = false
        var inOsc = false

        for char in string {
            if char == "\u{1B}" {
                // Start collecting escape sequence
                result.append(char)
                inEscape = true
                continue
            }

            if inEscape {
                result.append(char)
                if char == "[" {
                    // CSI sequence continues
                } else if char == "]" {
                    inOsc = true
                    inEscape = false
                } else if char.isLetter {
                    // End of CSI sequence
                    inEscape = false
                }
                continue
            }

            if inOsc {
                result.append(char)
                if char == "\u{07}" {
                    inOsc = false
                }
                continue
            }

            // Regular visible character
            if visibleCount < width {
                result.append(char)
                visibleCount += 1
            } else {
                break
            }
        }

        return result
    }
}

extension View {
    /// Add a border around the view.
    public func border(_ style: BoxStyle = .rounded, title: String? = nil, color: ANSI.Color? = nil) -> BorderedView<Self> {
        BorderedView(content: self, style: style, title: title, borderColor: color)
    }

    /// Add a rounded border.
    public func roundedBorder(title: String? = nil, color: ANSI.Color? = nil) -> BorderedView<Self> {
        border(.rounded, title: title, color: color)
    }

    /// Add a single-line border.
    public func singleBorder(title: String? = nil, color: ANSI.Color? = nil) -> BorderedView<Self> {
        border(.single, title: title, color: color)
    }

    /// Add a double-line border.
    public func doubleBorder(title: String? = nil, color: ANSI.Color? = nil) -> BorderedView<Self> {
        border(.double, title: title, color: color)
    }
}
