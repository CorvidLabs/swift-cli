import ANSI
import TerminalCore
import TerminalStyle
import TerminalInput

/// A selection prompt (single choice).
public struct Select<T: Sendable>: Sendable {
    /// The question to ask.
    public let message: String

    /// Options to choose from.
    public let options: [Option]

    /// Initially selected index.
    public let defaultIndex: Int

    /// Terminal reference.
    private let terminal: Terminal

    /// An option in the select menu.
    public struct Option: Sendable {
        public let label: String
        public let value: T
        public let description: String?

        public init(_ label: String, value: T, description: String? = nil) {
            self.label = label
            self.value = value
            self.description = description
        }
    }

    /// Create a select prompt.
    public init(
        _ message: String,
        options: [Option],
        default defaultIndex: Int = 0,
        terminal: Terminal = .shared
    ) {
        self.message = message
        self.options = options
        self.defaultIndex = min(max(0, defaultIndex), options.count - 1)
        self.terminal = terminal
    }

    /// Run the prompt and get the selected value.
    public func run() async throws -> T {
        guard !options.isEmpty else {
            throw TerminalError.inputError("No options provided")
        }

        var selectedIndex = defaultIndex

        try await terminal.enableRawMode()
        defer { Task { try? await terminal.disableRawMode() } }

        await terminal.hideCursor()
        defer { Task { await terminal.showCursor() } }

        // Enable mouse tracking
        await terminal.enableMouse()
        defer { Task { await terminal.disableMouse() } }

        // Get starting row for mouse click calculation
        let startRow = await getStartRow()

        // Initial render
        await render(selectedIndex: selectedIndex, firstRender: true)

        while true {
            let event = try await terminal.readEvent()

            switch event {
            case .key(let key, _):
                switch key {
                case .arrow(.up):
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                        await render(selectedIndex: selectedIndex)
                    }

                case .arrow(.down):
                    if selectedIndex < options.count - 1 {
                        selectedIndex += 1
                        await render(selectedIndex: selectedIndex)
                    }

                case .enter:
                    await finalize(selectedIndex: selectedIndex)
                    return options[selectedIndex].value

                case .ctrl(let c) where c == "c" || c == "C":
                    await clearAndRestore()
                    throw TerminalError.cancelled

                default:
                    break
                }

            case .mouse(let mouseEvent):
                // Handle mouse clicks on options
                if mouseEvent.action == .press && mouseEvent.button == .left {
                    // Options start at row startRow + 1 (after the question line)
                    let clickedOptionIndex = mouseEvent.row - startRow - 2
                    if clickedOptionIndex >= 0 && clickedOptionIndex < options.count {
                        selectedIndex = clickedOptionIndex
                        await finalize(selectedIndex: selectedIndex)
                        return options[selectedIndex].value
                    }
                }

            default:
                break
            }
        }
    }

    /// Get current cursor row position.
    private func getStartRow() async -> Int {
        // Query actual cursor position
        if let position = try? await terminal.queryCursorPosition() {
            return position.row
        }
        // Fallback: assume near bottom of terminal
        let size = await terminal.size
        return size.rows
    }

    private func render(selectedIndex: Int, firstRender: Bool = false) async {
        if !firstRender {
            // Move cursor up to redraw
            await terminal.write(ANSI.Cursor.up(options.count + 1))
        }

        await terminal.write(ANSI.Erase.lineFromCursor)
        await terminal.writeLine("? ".cyan.render() + message)

        for (index, option) in options.enumerated() {
            await terminal.write(ANSI.Erase.lineFromCursor)

            if index == selectedIndex {
                await terminal.write("❯ ".cyan.render() + option.label.cyan.render())
            } else {
                await terminal.write("  " + option.label)
            }

            if let desc = option.description {
                await terminal.write(" " + desc.dim.render())
            }

            await terminal.write("\n")
        }
    }

    private func finalize(selectedIndex: Int) async {
        // Clear the options
        await terminal.write(ANSI.Cursor.up(options.count + 1))
        for _ in 0...options.count {
            await terminal.write(ANSI.Erase.line)
            await terminal.write(ANSI.Cursor.down(1))
        }
        await terminal.write(ANSI.Cursor.up(options.count + 1))

        // Show final selection
        await terminal.writeLine("? ".cyan.render() + message + " " + options[selectedIndex].label.cyan.render())
    }

    private func clearAndRestore() async {
        await terminal.write(ANSI.Cursor.up(options.count + 1))
        for _ in 0...options.count {
            await terminal.write(ANSI.Erase.line)
            await terminal.write(ANSI.Cursor.down(1))
        }
        await terminal.write(ANSI.Cursor.up(options.count + 1))
    }
}

// MARK: - Convenience for String Options

extension Select where T == String {
    /// Create a select prompt with string options.
    public init(
        _ message: String,
        options: [String],
        default defaultIndex: Int = 0,
        terminal: Terminal = .shared
    ) {
        self.message = message
        self.options = options.map { Option($0, value: $0) }
        self.defaultIndex = min(max(0, defaultIndex), options.count - 1)
        self.terminal = terminal
    }
}

// MARK: - Convenience

extension Terminal {
    /// Run a selection prompt.
    public func select(_ message: String, options: [String]) async throws -> String {
        try await Select(message, options: options, terminal: self).run()
    }

    /// Run a selection prompt with typed options.
    public func select<T: Sendable>(_ message: String, options: [Select<T>.Option]) async throws -> T {
        try await Select(message, options: options, terminal: self).run()
    }
}
