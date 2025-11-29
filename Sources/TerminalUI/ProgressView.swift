import ANSI

/// A view that displays progress as a bar.
public struct ProgressView: View, Sendable {
    let value: Double  // 0.0 to 1.0
    let total: Double
    let width: Int
    let style: Style
    let showPercentage: Bool

    /// Progress bar display style.
    public enum Style: Sendable {
        /// Block characters: ████████░░░░
        case blocks
        /// ASCII bar: [========  ]
        case bar
        /// Dots: ●●●●●○○○○○
        case dots
    }

    /// Create a progress view with a value from 0.0 to 1.0.
    public init(
        value: Double,
        total: Double = 1.0,
        width: Int = 20,
        style: Style = .blocks,
        showPercentage: Bool = true
    ) {
        self.value = value
        self.total = total
        self.width = width
        self.style = style
        self.showPercentage = showPercentage
    }

    public var body: some View {
        let progress = total > 0 ? min(1.0, max(0.0, value / total)) : 0.0
        let filled = Int(progress * Double(width))
        let empty = width - filled
        let percentage = Int(progress * 100)

        let barString: String
        switch style {
        case .blocks:
            let filledChars = String(repeating: "█", count: filled)
            let emptyChars = String(repeating: "░", count: empty)
            barString = filledChars + emptyChars

        case .bar:
            let filledChars = String(repeating: "=", count: filled)
            let emptyChars = String(repeating: " ", count: empty)
            barString = "[" + filledChars + emptyChars + "]"

        case .dots:
            let filledChars = String(repeating: "●", count: filled)
            let emptyChars = String(repeating: "○", count: empty)
            barString = filledChars + emptyChars
        }

        if showPercentage {
            return Text("\(barString) \(percentage)%")
        } else {
            return Text(barString)
        }
    }
}

// MARK: - Convenience Initializers

extension ProgressView {
    /// Create a progress view for a percentage value (0-100).
    public static func percentage(_ value: Double, width: Int = 20, style: Style = .blocks) -> ProgressView {
        ProgressView(value: value, total: 100, width: width, style: style)
    }
}

// MARK: - DirectRenderable Conformance

extension ProgressView: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        let progress = total > 0 ? min(1.0, max(0.0, value / total)) : 0.0
        let filled = Int(progress * Double(self.width))
        let empty = self.width - filled
        let percentage = Int(progress * 100)

        let barString: String
        switch style {
        case .blocks:
            let filledChars = String(repeating: "█", count: filled)
            let emptyChars = String(repeating: "░", count: empty)
            barString = filledChars + emptyChars

        case .bar:
            let filledChars = String(repeating: "=", count: filled)
            let emptyChars = String(repeating: " ", count: empty)
            barString = "[" + filledChars + emptyChars + "]"

        case .dots:
            let filledChars = String(repeating: "●", count: filled)
            let emptyChars = String(repeating: "○", count: empty)
            barString = filledChars + emptyChars
        }

        if showPercentage {
            return ["\(barString) \(percentage)%"]
        } else {
            return [barString]
        }
    }
}
