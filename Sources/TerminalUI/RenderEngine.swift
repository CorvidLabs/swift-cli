import ANSI
import TerminalCore
import TerminalStyle
import TerminalLayout

/// Engine for rendering views to terminal output.
public struct RenderEngine: Sendable {
    /// Render a view to lines of text.
    public static func render<V: View>(_ view: V, size: Size) -> [String] {
        renderView(view, size: size)
    }

    /// Render a view to a single string.
    public static func renderString<V: View>(_ view: V, size: Size) -> String {
        render(view, size: size).joined(separator: "\n")
    }

    private static func renderView<V: View>(_ view: V, size: Size) -> [String] {
        // Handle primitive views
        if let text = view as? Text {
            let rendered = text.toStyledText().render()
            return rendered.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        }

        if view is EmptyView {
            return []
        }

        if let spacer = view as? Spacer {
            let height = spacer.minLength ?? 1
            return Array(repeating: "", count: height)
        }

        if view is Divider {
            return [String(repeating: "─", count: size.width)]
        }

        // Handle AnyView
        if let anyView = view as? AnyView {
            return anyView.renderLines(size: size)
        }

        // Try to render body for compound views
        // This is a simplified approach - we just render the body
        return renderBodyIfPossible(view, size: size)
    }

    private static func renderBodyIfPossible<V: View>(_ view: V, size: Size) -> [String] {
        // Check if the view can render itself directly
        if let renderable = view as? DirectRenderable {
            return renderable._directRender(size: size, visibleLength: { Self.visibleLength($0) })
        }

        // For views with a body, try to render it
        // This uses Swift's type system to handle the recursion
        if V.Body.self == Never.self {
            // Primitive view without body implementation
            return ["[\(type(of: view))]"]
        }

        return renderView(view.body, size: size)
    }

    /// Calculate visible length of a string, excluding ANSI escape sequences.
    /// Uses a fast single-pass character scanner instead of regex for performance.
    internal static func visibleLength(_ string: String) -> Int {
        var count = 0
        var inEscape = false
        var inOsc = false
        var iterator = string.unicodeScalars.makeIterator()

        while let char = iterator.next() {
            if char == "\u{1B}" {
                // Start of escape sequence
                if let next = iterator.next() {
                    if next == "[" {
                        inEscape = true  // CSI sequence
                    } else if next == "]" {
                        inOsc = true     // OSC sequence
                    } else {
                        // Unknown escape, count both characters
                        count += 2
                    }
                }
            } else if inEscape {
                // CSI sequence ends with a letter
                if char.properties.generalCategory == .uppercaseLetter ||
                   char.properties.generalCategory == .lowercaseLetter {
                    inEscape = false
                }
            } else if inOsc {
                // OSC sequence ends with BEL (0x07)
                if char == "\u{07}" {
                    inOsc = false
                }
            } else {
                count += 1
            }
        }
        return count
    }
}
