import ANSI
import TerminalCore
import TerminalStyle

/// A line editor with history and editing capabilities.
public actor LineEditor {
    /// The prompt to display.
    public var prompt: StyledText

    /// Command history.
    private var history: [String]

    /// Current history index (-1 = current input).
    private var historyIndex: Int = -1

    /// Current line content.
    private var buffer: [Character] = []

    /// Cursor position within the buffer.
    private var cursorPosition: Int = 0

    /// Saved input when browsing history.
    private var savedInput: [Character] = []

    /// Maximum history size.
    public var maxHistorySize: Int = 1000

    /// Terminal reference.
    private let terminal: Terminal

    /// Input reader.
    private let reader = InputReader()

    /// Create a line editor.
    public init(prompt: StyledText = "> ".styled, history: [String] = [], terminal: Terminal = .shared) {
        self.prompt = prompt
        self.history = history
        self.terminal = terminal
    }

    /// Read a line of input.
    public func readLine() async throws -> String {
        buffer = []
        cursorPosition = 0
        historyIndex = -1
        savedInput = []

        await drawPrompt()

        while true {
            guard let byte = try await terminal.readByte() else {
                continue
            }

            // Check for escape sequence
            var bytes: [UInt8] = [byte]

            if byte == 0x1B {
                // Read more bytes for escape sequence
                try await Task.sleep(nanoseconds: 10_000_000) // 10ms
                while let nextByte = try await terminal.readByte() {
                    bytes.append(nextByte)
                    // Check if we have a complete sequence
                    if isCompleteSequence(bytes) {
                        break
                    }
                }
            }

            guard let event = reader.parse(bytes) else {
                continue
            }

            if let result = try await handleEvent(event) {
                return result
            }
        }
    }

    private func isCompleteSequence(_ bytes: [UInt8]) -> Bool {
        guard bytes.count >= 2 else { return false }

        // CSI sequence
        if bytes[1] == 0x5B {
            if let last = bytes.last {
                // Check for final byte (0x40-0x7E)
                return last >= 0x40 && last <= 0x7E
            }
        }

        // SS3 sequence
        if bytes[1] == 0x4F && bytes.count >= 3 {
            return true
        }

        // Alt+char
        if bytes.count == 2 {
            return true
        }

        return false
    }

    private func handleEvent(_ event: InputEvent) async throws -> String? {
        switch event {
        case .key(let key, let modifiers):
            return try await handleKey(key, modifiers)
        default:
            return nil
        }
    }

    private func handleKey(_ key: KeyCode, _ modifiers: Modifiers) async throws -> String? {
        switch key {
        case .enter:
            await terminal.write("\n")
            let result = String(buffer)
            if !result.isEmpty {
                addToHistory(result)
            }
            return result

        case .character(let char):
            await insertCharacter(char)

        case .backspace:
            await deleteBackward()

        case .delete:
            await deleteForward()

        case .arrow(.left):
            if modifiers.contains(.control) || modifiers.contains(.alt) {
                await moveToPreviousWord()
            } else {
                await moveCursorLeft()
            }

        case .arrow(.right):
            if modifiers.contains(.control) || modifiers.contains(.alt) {
                await moveToNextWord()
            } else {
                await moveCursorRight()
            }

        case .arrow(.up):
            await previousHistory()

        case .arrow(.down):
            await nextHistory()

        case .home:
            await moveCursorToStart()

        case .end:
            await moveCursorToEnd()

        case .ctrl(let c) where c == "c" || c == "C":
            await terminal.write("^C\n")
            throw TerminalError.cancelled

        case .ctrl(let c) where c == "d" || c == "D":
            if buffer.isEmpty {
                throw TerminalError.cancelled
            }
            await deleteForward()

        case .ctrl(let c) where c == "a" || c == "A":
            await moveCursorToStart()

        case .ctrl(let c) where c == "e" || c == "E":
            await moveCursorToEnd()

        case .ctrl(let c) where c == "k" || c == "K":
            await deleteToEnd()

        case .ctrl(let c) where c == "u" || c == "U":
            await deleteToStart()

        case .ctrl(let c) where c == "w" || c == "W":
            await deleteWord()

        case .ctrl(let c) where c == "l" || c == "L":
            await clearAndRedraw()

        case .tab:
            // Tab completion could be added here
            await insertCharacter("\t")

        default:
            break
        }

        return nil
    }

    // MARK: - Editing Operations

    private func insertCharacter(_ char: Character) async {
        buffer.insert(char, at: cursorPosition)
        cursorPosition += 1
        await redrawLine()
    }

    private func deleteBackward() async {
        guard cursorPosition > 0 else { return }
        buffer.remove(at: cursorPosition - 1)
        cursorPosition -= 1
        await redrawLine()
    }

    private func deleteForward() async {
        guard cursorPosition < buffer.count else { return }
        buffer.remove(at: cursorPosition)
        await redrawLine()
    }

    private func deleteToEnd() async {
        buffer.removeSubrange(cursorPosition...)
        await redrawLine()
    }

    private func deleteToStart() async {
        buffer.removeSubrange(..<cursorPosition)
        cursorPosition = 0
        await redrawLine()
    }

    private func deleteWord() async {
        guard cursorPosition > 0 else { return }

        var end = cursorPosition
        // Skip whitespace
        while end > 0 && buffer[end - 1] == " " {
            end -= 1
        }
        // Skip word
        while end > 0 && buffer[end - 1] != " " {
            end -= 1
        }

        buffer.removeSubrange(end..<cursorPosition)
        cursorPosition = end
        await redrawLine()
    }

    // MARK: - Cursor Movement

    private func moveCursorLeft() async {
        guard cursorPosition > 0 else { return }
        cursorPosition -= 1
        await terminal.write(ANSI.Cursor.backward(1))
    }

    private func moveCursorRight() async {
        guard cursorPosition < buffer.count else { return }
        cursorPosition += 1
        await terminal.write(ANSI.Cursor.forward(1))
    }

    private func moveCursorToStart() async {
        let distance = cursorPosition
        cursorPosition = 0
        if distance > 0 {
            await terminal.write(ANSI.Cursor.backward(distance))
        }
    }

    private func moveCursorToEnd() async {
        let distance = buffer.count - cursorPosition
        cursorPosition = buffer.count
        if distance > 0 {
            await terminal.write(ANSI.Cursor.forward(distance))
        }
    }

    private func moveToPreviousWord() async {
        guard cursorPosition > 0 else { return }

        var newPos = cursorPosition
        // Skip whitespace
        while newPos > 0 && buffer[newPos - 1] == " " {
            newPos -= 1
        }
        // Skip word
        while newPos > 0 && buffer[newPos - 1] != " " {
            newPos -= 1
        }

        let distance = cursorPosition - newPos
        cursorPosition = newPos
        if distance > 0 {
            await terminal.write(ANSI.Cursor.backward(distance))
        }
    }

    private func moveToNextWord() async {
        guard cursorPosition < buffer.count else { return }

        var newPos = cursorPosition
        // Skip current word
        while newPos < buffer.count && buffer[newPos] != " " {
            newPos += 1
        }
        // Skip whitespace
        while newPos < buffer.count && buffer[newPos] == " " {
            newPos += 1
        }

        let distance = newPos - cursorPosition
        cursorPosition = newPos
        if distance > 0 {
            await terminal.write(ANSI.Cursor.forward(distance))
        }
    }

    // MARK: - History

    private func previousHistory() async {
        guard !history.isEmpty else { return }

        if historyIndex == -1 {
            savedInput = buffer
        }

        if historyIndex < history.count - 1 {
            historyIndex += 1
            buffer = Array(history[history.count - 1 - historyIndex])
            cursorPosition = buffer.count
            await redrawLine()
        }
    }

    private func nextHistory() async {
        guard historyIndex >= 0 else { return }

        historyIndex -= 1

        if historyIndex == -1 {
            buffer = savedInput
        } else {
            buffer = Array(history[history.count - 1 - historyIndex])
        }

        cursorPosition = buffer.count
        await redrawLine()
    }

    private func addToHistory(_ line: String) {
        // Don't add duplicates
        if history.last != line {
            history.append(line)
            if history.count > maxHistorySize {
                history.removeFirst()
            }
        }
    }

    // MARK: - Drawing

    private func drawPrompt() async {
        await terminal.write(prompt)
    }

    private func redrawLine() async {
        // Move to start of input
        await terminal.write("\r")
        // Clear line
        await terminal.write(ANSI.Erase.lineFromCursor)
        // Draw prompt
        await drawPrompt()
        // Draw buffer
        await terminal.write(String(buffer))
        // Move cursor to position
        let distance = buffer.count - cursorPosition
        if distance > 0 {
            await terminal.write(ANSI.Cursor.backward(distance))
        }
    }

    private func clearAndRedraw() async {
        await terminal.clearScreen()
        await redrawLine()
    }

    // MARK: - Public API

    /// Get current history.
    public func getHistory() -> [String] {
        history
    }

    /// Set history.
    public func setHistory(_ newHistory: [String]) {
        history = newHistory
    }

    /// Clear history.
    public func clearHistory() {
        history = []
    }
}
