import ANSI
import TerminalCore
import TerminalStyle

/// An animated spinner for indicating activity.
public actor Spinner {
    /// Spinner animation frames.
    public let style: Style

    /// Current message.
    public private(set) var message: String

    /// Animation interval in milliseconds.
    public let interval: Int

    /// Terminal reference.
    private let terminal: Terminal

    /// Whether the spinner is running.
    private var isRunning: Bool = false

    /// Current frame index.
    private var frameIndex: Int = 0

    /// Animation task.
    private var animationTask: Task<Void, Never>?

    /// Spinner styles.
    public struct Style: Sendable {
        public let frames: [String]

        public init(frames: [String]) {
            self.frames = frames.isEmpty ? ["-"] : frames
        }

        // Preset styles
        public static let dots = Style(frames: ANSI.Box.Spinner.dots)
        public static let line = Style(frames: ANSI.Box.Spinner.line)
        public static let growingDots = Style(frames: ANSI.Box.Spinner.growingDots)
        public static let circle = Style(frames: ANSI.Box.Spinner.circle)
        public static let arc = Style(frames: ANSI.Box.Spinner.arc)
        public static let box = Style(frames: ANSI.Box.Spinner.box)
        public static let arrow = Style(frames: ANSI.Box.Spinner.arrow)
        public static let bounce = Style(frames: ANSI.Box.Spinner.bounce)
        public static let clock = Style(frames: ANSI.Box.Spinner.clock)

        public static let simple = Style(frames: ["|", "/", "-", "\\"])
        public static let dots2 = Style(frames: ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"])
        public static let hamburger = Style(frames: ["☱", "☲", "☴"])
        public static let earth = Style(frames: ["🌍", "🌎", "🌏"])
        public static let moon = Style(frames: ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"])
    }

    /// Create a spinner.
    public init(
        style: Style = .dots,
        message: String = "",
        interval: Int = 80,
        terminal: Terminal = .shared
    ) {
        self.style = style
        self.message = message
        self.interval = interval
        self.terminal = terminal
    }

    /// Start the spinner.
    public func start(message: String? = nil) async {
        guard !isRunning else { return }

        if let msg = message {
            self.message = msg
        }

        isRunning = true
        await terminal.hideCursor()

        animationTask = Task { [weak self] in
            while await self?.isRunning == true {
                await self?.render()
                try? await Task.sleep(nanoseconds: UInt64(self?.interval ?? 80) * 1_000_000)
            }
        }
    }

    /// Stop the spinner with a success message.
    public func success(_ message: String? = nil) async {
        await stop(symbol: "✓".green.render(), message: message)
    }

    /// Stop the spinner with a failure message.
    public func fail(_ message: String? = nil) async {
        await stop(symbol: "✗".red.render(), message: message)
    }

    /// Stop the spinner with a warning message.
    public func warn(_ message: String? = nil) async {
        await stop(symbol: "⚠".yellow.render(), message: message)
    }

    /// Stop the spinner with an info message.
    public func info(_ message: String? = nil) async {
        await stop(symbol: "ℹ".cyan.render(), message: message)
    }

    /// Stop the spinner.
    public func stop(symbol: String? = nil, message: String? = nil) async {
        isRunning = false
        animationTask?.cancel()
        animationTask = nil

        if let msg = message {
            self.message = msg
        }

        await terminal.write("\r" + ANSI.Erase.lineFromCursor)

        if let sym = symbol {
            await terminal.write(sym + " ")
        }

        await terminal.writeLine(self.message)
        await terminal.showCursor()
    }

    /// Update the message while spinning.
    public func update(message: String) async {
        self.message = message
    }

    /// Render current frame.
    private func render() async {
        let frame = style.frames[frameIndex % style.frames.count]
        frameIndex += 1

        var output = "\r" + ANSI.Erase.lineFromCursor
        output += frame.cyan.render() + " " + message

        await terminal.write(output)
    }
}

// MARK: - Convenience Functions

extension Terminal {
    /// Run an async operation with a spinner.
    public func withSpinner<T: Sendable>(
        message: String,
        style: Spinner.Style = .dots,
        successMessage: String? = nil,
        failureMessage: String? = nil,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        let spinner = Spinner(style: style, message: message, terminal: self)
        await spinner.start()

        do {
            let result = try await operation()
            await spinner.success(successMessage ?? message)
            return result
        } catch {
            await spinner.fail(failureMessage ?? "Failed: \(message)")
            throw error
        }
    }
}
