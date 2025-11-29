import ANSI
import TerminalCore
import TerminalStyle
import TerminalInput

/// A multi-selection prompt (multiple choices).
public struct MultiSelect<T: Sendable>: Sendable {
    /// The question to ask.
    public let message: String

    /// Options to choose from.
    public let options: [Option]

    /// Initially selected indices.
    public let defaultSelected: Set<Int>

    /// Minimum selections required.
    public let minSelections: Int

    /// Maximum selections allowed.
    public let maxSelections: Int?

    /// Terminal reference.
    private let terminal: Terminal

    /// An option in the multi-select menu.
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

    /// Create a multi-select prompt.
    public init(
        _ message: String,
        options: [Option],
        selected: Set<Int> = [],
        min minSelections: Int = 0,
        max maxSelections: Int? = nil,
        terminal: Terminal = .shared
    ) {
        self.message = message
        self.options = options
        self.defaultSelected = selected
        self.minSelections = minSelections
        self.maxSelections = maxSelections
        self.terminal = terminal
    }

    /// Run the prompt and get the selected values.
    public func run() async throws -> [T] {
        guard !options.isEmpty else {
            throw TerminalError.inputError("No options provided")
        }

        var cursorIndex = 0
        var selectedIndices = defaultSelected

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
        await render(cursorIndex: cursorIndex, selected: selectedIndices, firstRender: true)

        while true {
            let event = try await terminal.readEvent()

            switch event {
            case .key(let key, _):
                switch key {
                case .arrow(.up):
                    if cursorIndex > 0 {
                        cursorIndex -= 1
                        await render(cursorIndex: cursorIndex, selected: selectedIndices)
                    }

                case .arrow(.down):
                    if cursorIndex < options.count - 1 {
                        cursorIndex += 1
                        await render(cursorIndex: cursorIndex, selected: selectedIndices)
                    }

                case .character(" "):
                    // Toggle selection
                    toggleSelection(at: cursorIndex, in: &selectedIndices)
                    await render(cursorIndex: cursorIndex, selected: selectedIndices)

                case .character("a"), .character("A"):
                    // Select all / deselect all
                    if selectedIndices.count == options.count {
                        selectedIndices = []
                    } else {
                        if let max = maxSelections {
                            selectedIndices = Set(0..<min(max, options.count))
                        } else {
                            selectedIndices = Set(0..<options.count)
                        }
                    }
                    await render(cursorIndex: cursorIndex, selected: selectedIndices)

                case .enter:
                    if selectedIndices.count >= minSelections {
                        await finalize(selected: selectedIndices)
                        return selectedIndices.sorted().map { options[$0].value }
                    }

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
                        cursorIndex = clickedOptionIndex
                        toggleSelection(at: clickedOptionIndex, in: &selectedIndices)
                        await render(cursorIndex: cursorIndex, selected: selectedIndices)
                    }
                }

            default:
                break
            }
        }
    }

    /// Toggle selection at the given index.
    private func toggleSelection(at index: Int, in selectedIndices: inout Set<Int>) {
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            if let max = maxSelections, selectedIndices.count >= max {
                // Can't select more
            } else {
                selectedIndices.insert(index)
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

    private func render(cursorIndex: Int, selected: Set<Int>, firstRender: Bool = false) async {
        if !firstRender {
            await terminal.write(ANSI.Cursor.up(options.count + 2))
        }

        await terminal.write(ANSI.Erase.lineFromCursor)
        await terminal.writeLine("? ".cyan.render() + message + " (space to select, enter to confirm)".dim.render())

        for (index, option) in options.enumerated() {
            await terminal.write(ANSI.Erase.lineFromCursor)

            let isSelected = selected.contains(index)
            let isCursor = index == cursorIndex

            let checkbox: String
            if isSelected {
                checkbox = "◉".green.render()
            } else {
                checkbox = "○".dim.render()
            }

            if isCursor {
                await terminal.write("❯ " + checkbox + " " + option.label.cyan.render())
            } else {
                await terminal.write("  " + checkbox + " " + option.label)
            }

            if let desc = option.description {
                await terminal.write(" " + desc.dim.render())
            }

            await terminal.write("\n")
        }

        // Status line
        await terminal.write(ANSI.Erase.lineFromCursor)
        let countText = "\(selected.count) selected"
        if selected.count < minSelections {
            await terminal.writeLine("  " + countText.dim.render() + " (min: \(minSelections))".dim.render())
        } else {
            await terminal.writeLine("  " + countText.dim.render())
        }
    }

    private func finalize(selected: Set<Int>) async {
        // Clear the options
        let totalLines = options.count + 2
        await terminal.write(ANSI.Cursor.up(totalLines))
        for _ in 0..<totalLines {
            await terminal.write(ANSI.Erase.line)
            await terminal.write(ANSI.Cursor.down(1))
        }
        await terminal.write(ANSI.Cursor.up(totalLines))

        // Show final selection
        let selectedLabels = selected.sorted().map { options[$0].label }.joined(separator: ", ")
        await terminal.writeLine("? ".cyan.render() + message + " " + selectedLabels.cyan.render())
    }

    private func clearAndRestore() async {
        let totalLines = options.count + 2
        await terminal.write(ANSI.Cursor.up(totalLines))
        for _ in 0..<totalLines {
            await terminal.write(ANSI.Erase.line)
            await terminal.write(ANSI.Cursor.down(1))
        }
        await terminal.write(ANSI.Cursor.up(totalLines))
    }
}

// MARK: - Convenience for String Options

extension MultiSelect where T == String {
    /// Create a multi-select prompt with string options.
    public init(
        _ message: String,
        options: [String],
        selected: Set<Int> = [],
        min minSelections: Int = 0,
        max maxSelections: Int? = nil,
        terminal: Terminal = .shared
    ) {
        self.message = message
        self.options = options.map { Option($0, value: $0) }
        self.defaultSelected = selected
        self.minSelections = minSelections
        self.maxSelections = maxSelections
        self.terminal = terminal
    }
}

// MARK: - Convenience

extension Terminal {
    /// Run a multi-selection prompt.
    public func multiSelect(_ message: String, options: [String], min: Int = 0, max: Int? = nil) async throws -> [String] {
        try await MultiSelect(message, options: options, min: min, max: max, terminal: self).run()
    }
}
