import ANSI
import TerminalUI
import TerminalInput
import Foundation

/// Simple text editor with syntax highlighting
final class TextEditorApp: App, @unchecked Sendable {
    // Editor state
    private var lines: [String] = [""]
    private var cursorRow: Int = 0
    private var cursorCol: Int = 0
    private var scrollRow: Int = 0
    private var scrollCol: Int = 0
    private let visibleRows = 18
    private let visibleCols = 70

    // File state
    private var filePath: String? = nil
    private var fileName: String = "untitled"
    private var isModified: Bool = false
    private var fileExtension: String = ""

    // Message
    private var statusMessage: String? = nil

    init() {}

    var updateInterval: TimeInterval { 0 }

    var body: some View {
        VStack {
            // Title bar
            Text(renderTitleBar())
                .border(.single, color: isModified ? .yellow : .cyan)

            // Editor area
            editorView

            // Status bar
            Text(renderStatusBar())
        }
    }

    private var editorView: some View {
        VStack {
            ForEach(0..<visibleRows) { [self] row in
                Text(renderLine(row))
            }
        }
        .border(.rounded)
    }

    private func renderTitleBar() -> String {
        var title = "  \(fileName)"
        if isModified {
            title += " [modified]"
        }
        title += "  "
        return title
    }

    private func renderLine(_ displayRow: Int) -> String {
        let lineIndex = scrollRow + displayRow

        // Line number
        let lineNum: String
        if lineIndex < lines.count {
            lineNum = String(format: "%4d ", lineIndex + 1).dim.render()
        } else {
            lineNum = "   ~ ".dim.render()
        }

        // Line content
        var content: String
        if lineIndex < lines.count {
            let line = lines[lineIndex]
            content = highlightLine(line)

            // Handle horizontal scroll
            if scrollCol > 0 {
                // Strip ANSI codes for scrolling, then re-apply
                let plain = stripAnsi(content)
                if scrollCol < plain.count {
                    content = String(plain.dropFirst(scrollCol))
                } else {
                    content = ""
                }
            }
        } else {
            content = ""
        }

        // Show cursor
        if lineIndex == cursorRow {
            content = insertCursor(content, at: cursorCol - scrollCol)
        }

        // Pad to visible width
        let plainLen = stripAnsi(content).count
        if plainLen < visibleCols {
            content += String(repeating: " ", count: visibleCols - plainLen)
        }

        return lineNum + content
    }

    private func insertCursor(_ line: String, at position: Int) -> String {
        let plain = stripAnsi(line)
        let pos = max(0, min(position, plain.count))

        if pos >= plain.count {
            // Cursor at end
            return line + "_".bold.cyan.render()
        }

        // Insert cursor marker at position
        let before = String(plain.prefix(pos))
        let cursorChar = String(plain[plain.index(plain.startIndex, offsetBy: pos)])
        let after = String(plain.dropFirst(pos + 1))

        return before + cursorChar.bold.cyan.underline.render() + after
    }

    private func stripAnsi(_ str: String) -> String {
        let pattern = "\u{001B}\\[[0-9;]*m"
        return str.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }

    private func highlightLine(_ line: String) -> String {
        // Basic syntax highlighting based on file extension
        switch fileExtension {
        case "swift":
            return highlightSwift(line)
        case "py":
            return highlightPython(line)
        case "js", "ts":
            return highlightJS(line)
        case "json":
            return highlightJSON(line)
        default:
            return line
        }
    }

    private func highlightSwift(_ line: String) -> String {
        var result = line

        // Keywords
        let keywords = ["import", "func", "var", "let", "if", "else", "for", "while", "return",
                       "class", "struct", "enum", "protocol", "extension", "private", "public",
                       "static", "final", "async", "await", "try", "catch", "throw", "guard",
                       "switch", "case", "default", "break", "continue", "self", "Self", "nil",
                       "true", "false", "init", "deinit", "typealias", "associatedtype", "where"]

        for kw in keywords {
            result = result.replacingOccurrences(
                of: "\\b\(kw)\\b",
                with: kw.magenta.render(),
                options: .regularExpression
            )
        }

        // Comments
        if let range = result.range(of: "//.*$", options: .regularExpression) {
            let comment = String(result[range])
            result = result.replacingCharacters(in: range, with: comment.green.dim.render())
        }

        // Strings
        result = highlightStrings(result)

        return result
    }

    private func highlightPython(_ line: String) -> String {
        var result = line

        let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return",
                       "import", "from", "as", "try", "except", "finally", "with", "lambda",
                       "True", "False", "None", "and", "or", "not", "in", "is", "pass",
                       "break", "continue", "raise", "yield", "async", "await", "self"]

        for kw in keywords {
            result = result.replacingOccurrences(
                of: "\\b\(kw)\\b",
                with: kw.magenta.render(),
                options: .regularExpression
            )
        }

        // Comments
        if let range = result.range(of: "#.*$", options: .regularExpression) {
            let comment = String(result[range])
            result = result.replacingCharacters(in: range, with: comment.green.dim.render())
        }

        result = highlightStrings(result)
        return result
    }

    private func highlightJS(_ line: String) -> String {
        var result = line

        let keywords = ["function", "const", "let", "var", "if", "else", "for", "while",
                       "return", "class", "extends", "import", "export", "from", "default",
                       "try", "catch", "finally", "throw", "new", "this", "super", "async",
                       "await", "true", "false", "null", "undefined", "typeof", "instanceof"]

        for kw in keywords {
            result = result.replacingOccurrences(
                of: "\\b\(kw)\\b",
                with: kw.magenta.render(),
                options: .regularExpression
            )
        }

        // Comments
        if let range = result.range(of: "//.*$", options: .regularExpression) {
            let comment = String(result[range])
            result = result.replacingCharacters(in: range, with: comment.green.dim.render())
        }

        result = highlightStrings(result)
        return result
    }

    private func highlightJSON(_ line: String) -> String {
        var result = line

        // Keys (before colon)
        result = result.replacingOccurrences(
            of: "\"([^\"]+)\"\\s*:",
            with: "\"\("$1".cyan.render())\":",
            options: .regularExpression
        )

        // String values
        result = highlightStrings(result)

        // Numbers
        result = result.replacingOccurrences(
            of: ":\\s*(-?\\d+\\.?\\d*)",
            with: ": " + "$1".yellow.render(),
            options: .regularExpression
        )

        // Booleans and null
        result = result.replacingOccurrences(of: "true", with: "true".magenta.render())
        result = result.replacingOccurrences(of: "false", with: "false".magenta.render())
        result = result.replacingOccurrences(of: "null", with: "null".red.render())

        return result
    }

    private func highlightStrings(_ line: String) -> String {
        // Simple string highlighting (doesn't handle escapes perfectly)
        var result = line
        let pattern = "\"[^\"]*\""
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range).reversed()
            for match in matches {
                if let swiftRange = Range(match.range, in: result) {
                    let str = String(result[swiftRange])
                    result = result.replacingCharacters(in: swiftRange, with: str.yellow.render())
                }
            }
        }
        return result
    }

    private func renderStatusBar() -> String {
        if let msg = statusMessage {
            return "  \(msg)  "
        }
        let pos = "Ln \(cursorRow + 1), Col \(cursorCol + 1)"
        let ext = fileExtension.isEmpty ? "plain" : fileExtension
        return "  \(pos)  |  \(ext)  |  Ctrl+S: Save  |  Ctrl+Q: Quit  "
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        statusMessage = nil

        switch key {
        // Navigation
        case .arrow(.up):
            moveCursor(row: -1, col: 0)
            return true

        case .arrow(.down):
            moveCursor(row: 1, col: 0)
            return true

        case .arrow(.left):
            moveCursor(row: 0, col: -1)
            return true

        case .arrow(.right):
            moveCursor(row: 0, col: 1)
            return true

        case .home:
            cursorCol = 0
            updateScroll()
            return true

        case .end:
            cursorCol = currentLine.count
            updateScroll()
            return true

        // Editing
        case .enter:
            insertNewline()
            return true

        case .backspace:
            deleteBackward()
            return true

        case .delete:
            deleteForward()
            return true

        case .character(let c):
            insertCharacter(c)
            return true

        // Control keys
        case .ctrl("s"), .ctrl("S"):
            saveFile()
            return true

        case .ctrl("q"), .ctrl("Q"):
            if isModified {
                statusMessage = "Unsaved changes! Press Ctrl+Q again to quit."
            }
            return false // Let app handle quit

        case .tab:
            insertCharacter("\t")
            return true

        default:
            return false
        }
    }

    private var currentLine: String {
        guard cursorRow < lines.count else { return "" }
        return lines[cursorRow]
    }

    private func moveCursor(row: Int, col: Int) {
        let newRow = max(0, min(lines.count - 1, cursorRow + row))
        cursorRow = newRow

        if col != 0 {
            let newCol = cursorCol + col
            if newCol < 0 && cursorRow > 0 {
                // Move to end of previous line
                cursorRow -= 1
                cursorCol = currentLine.count
            } else if newCol > currentLine.count && cursorRow < lines.count - 1 {
                // Move to start of next line
                cursorRow += 1
                cursorCol = 0
            } else {
                cursorCol = max(0, min(currentLine.count, newCol))
            }
        } else {
            // Vertical move - clamp to line length
            cursorCol = min(cursorCol, currentLine.count)
        }

        updateScroll()
    }

    private func insertCharacter(_ char: Character) {
        guard cursorRow < lines.count else { return }

        var line = lines[cursorRow]
        let index = line.index(line.startIndex, offsetBy: min(cursorCol, line.count))
        line.insert(char, at: index)
        lines[cursorRow] = line
        cursorCol += 1
        isModified = true
        updateScroll()
    }

    private func insertNewline() {
        guard cursorRow < lines.count else { return }

        let line = lines[cursorRow]
        let index = line.index(line.startIndex, offsetBy: min(cursorCol, line.count))
        let before = String(line[..<index])
        let after = String(line[index...])

        lines[cursorRow] = before
        lines.insert(after, at: cursorRow + 1)
        cursorRow += 1
        cursorCol = 0
        isModified = true
        updateScroll()
    }

    private func deleteBackward() {
        if cursorCol > 0 {
            // Delete character before cursor
            var line = lines[cursorRow]
            let index = line.index(line.startIndex, offsetBy: cursorCol - 1)
            line.remove(at: index)
            lines[cursorRow] = line
            cursorCol -= 1
            isModified = true
        } else if cursorRow > 0 {
            // Merge with previous line
            let currentLine = lines[cursorRow]
            let prevLength = lines[cursorRow - 1].count
            lines[cursorRow - 1] += currentLine
            lines.remove(at: cursorRow)
            cursorRow -= 1
            cursorCol = prevLength
            isModified = true
        }
        updateScroll()
    }

    private func deleteForward() {
        guard cursorRow < lines.count else { return }

        var line = lines[cursorRow]
        if cursorCol < line.count {
            // Delete character at cursor
            let index = line.index(line.startIndex, offsetBy: cursorCol)
            line.remove(at: index)
            lines[cursorRow] = line
            isModified = true
        } else if cursorRow < lines.count - 1 {
            // Merge with next line
            lines[cursorRow] += lines[cursorRow + 1]
            lines.remove(at: cursorRow + 1)
            isModified = true
        }
    }

    private func updateScroll() {
        // Vertical scroll
        if cursorRow < scrollRow {
            scrollRow = cursorRow
        } else if cursorRow >= scrollRow + visibleRows {
            scrollRow = cursorRow - visibleRows + 1
        }

        // Horizontal scroll
        if cursorCol < scrollCol {
            scrollCol = cursorCol
        } else if cursorCol >= scrollCol + visibleCols - 5 {
            scrollCol = cursorCol - visibleCols + 5
        }
    }

    private func saveFile() {
        guard let path = filePath else {
            statusMessage = "No file path set"
            return
        }

        let content = lines.joined(separator: "\n")
        do {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            isModified = false
            statusMessage = "Saved!"
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
        }
    }

    // MARK: - File Loading

    func loadFile(path: String) {
        filePath = path
        fileName = (path as NSString).lastPathComponent
        fileExtension = (path as NSString).pathExtension.lowercased()

        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            lines = content.components(separatedBy: "\n")
            if lines.isEmpty {
                lines = [""]
            }
            isModified = false
            cursorRow = 0
            cursorCol = 0
            scrollRow = 0
            scrollCol = 0
        } catch {
            statusMessage = "Error loading: \(error.localizedDescription)"
            lines = [""]
        }
    }

    func newFile(name: String = "untitled") {
        filePath = nil
        fileName = name
        fileExtension = ""
        lines = [""]
        isModified = false
        cursorRow = 0
        cursorCol = 0
    }
}
