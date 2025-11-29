import ANSI
import TerminalCore
import TerminalStyle

/// A progress bar with customizable appearance.
public actor ProgressBar {
    /// Total value (100%).
    public let total: Int

    /// Current progress value.
    public private(set) var current: Int = 0

    /// Progress bar style.
    public let style: Style

    /// Width in characters.
    public let width: Int

    /// Whether to show percentage.
    public let showPercentage: Bool

    /// Whether to show the value.
    public let showValue: Bool

    /// Message to display.
    public private(set) var message: String

    /// Terminal reference.
    private let terminal: Terminal

    /// Whether the progress bar is active.
    private var isActive: Bool = false

    /// Progress bar styles.
    public struct Style: Sendable {
        public let filled: Character
        public let empty: Character
        public let leftCap: String
        public let rightCap: String
        public let filledColor: ANSI.Color?
        public let emptyColor: ANSI.Color?

        public init(
            filled: Character = "█",
            empty: Character = "░",
            leftCap: String = "",
            rightCap: String = "",
            filledColor: ANSI.Color? = .green,
            emptyColor: ANSI.Color? = .gray
        ) {
            self.filled = filled
            self.empty = empty
            self.leftCap = leftCap
            self.rightCap = rightCap
            self.filledColor = filledColor
            self.emptyColor = emptyColor
        }

        // Preset styles
        public static let blocks = Style(filled: "█", empty: "░")
        public static let shades = Style(filled: "█", empty: "▒")
        public static let classic = Style(filled: "=", empty: "-", leftCap: "[", rightCap: "]", filledColor: nil, emptyColor: nil)
        public static let dots = Style(filled: "●", empty: "○")
        public static let arrows = Style(filled: "▶", empty: "▷")
        public static let squares = Style(filled: "■", empty: "□")
    }

    /// Create a progress bar.
    public init(
        total: Int,
        style: Style = .blocks,
        width: Int = 40,
        showPercentage: Bool = true,
        showValue: Bool = false,
        message: String = "",
        terminal: Terminal = .shared
    ) {
        self.total = max(1, total)
        self.style = style
        self.width = width
        self.showPercentage = showPercentage
        self.showValue = showValue
        self.message = message
        self.terminal = terminal
    }

    /// Update progress.
    public func update(current: Int, message: String? = nil) async {
        self.current = min(max(0, current), total)
        if let msg = message {
            self.message = msg
        }
        await render()
    }

    /// Increment progress by amount.
    public func increment(by amount: Int = 1, message: String? = nil) async {
        await update(current: current + amount, message: message)
    }

    /// Start the progress bar.
    public func start(message: String? = nil) async {
        isActive = true
        if let msg = message {
            self.message = msg
        }
        await terminal.hideCursor()
        await render()
    }

    /// Finish the progress bar.
    public func finish(message: String? = nil) async {
        current = total
        if let msg = message {
            self.message = msg
        }
        await render()
        await terminal.write("\n")
        await terminal.showCursor()
        isActive = false
    }

    /// Render the progress bar.
    private func render() async {
        let percentage = Double(current) / Double(total)
        let filledWidth = Int(Double(width) * percentage)
        let emptyWidth = width - filledWidth

        var bar = style.leftCap

        // Filled portion
        if let color = style.filledColor {
            bar += ANSI.Style.foreground(color)
        }
        bar += String(repeating: style.filled, count: filledWidth)
        if style.filledColor != nil {
            bar += ANSI.Style.reset
        }

        // Empty portion
        if let color = style.emptyColor {
            bar += ANSI.Style.foreground(color)
        }
        bar += String(repeating: style.empty, count: emptyWidth)
        if style.emptyColor != nil {
            bar += ANSI.Style.reset
        }

        bar += style.rightCap

        // Build output string
        var output = "\r" + ANSI.Erase.lineFromCursor

        if !message.isEmpty {
            output += message + " "
        }

        output += bar

        if showPercentage {
            output += String(format: " %3.0f%%", percentage * 100)
        }

        if showValue {
            output += " (\(current)/\(total))"
        }

        await terminal.write(output)
    }
}

// MARK: - Convenience Functions

extension Terminal {
    /// Create and run a progress bar for an async operation.
    public func withProgress<T>(
        total: Int,
        message: String = "",
        style: ProgressBar.Style = .blocks,
        operation: @escaping (ProgressBar) async throws -> T
    ) async throws -> T {
        let progress = ProgressBar(total: total, style: style, message: message, terminal: self)
        await progress.start()
        do {
            let result = try await operation(progress)
            await progress.finish()
            return result
        } catch {
            await progress.finish(message: "Failed".red.render())
            throw error
        }
    }
}
