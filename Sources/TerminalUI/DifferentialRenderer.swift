import TerminalCore

/// Actor that manages differential rendering with caching and targeted updates.
/// Only writes changed lines to the terminal for improved performance.
public actor DifferentialRenderer {
    private var previousBuffer: RenderBuffer?
    private var currentSize: Size = .zero
    private let terminal: Terminal

    public init(terminal: Terminal = .shared) {
        self.terminal = terminal
    }

    /// Render a view, only updating changed lines.
    public func render<V: View>(_ view: V, size: Size) async {
        // Check for size change
        let sizeChanged = size != currentSize
        currentSize = size

        // Render to lines
        var lines = RenderEngine.render(view, size: size)

        // Pad/truncate to terminal height
        while lines.count < size.height {
            lines.append("")
        }
        if lines.count > size.height {
            lines = Array(lines.prefix(size.height))
        }

        // Pad each line to full width
        let paddedLines = lines.map { padLineToWidth($0, width: size.width) }

        let newBuffer = RenderBuffer(lines: paddedLines, size: size)

        // Calculate diff
        let diff = sizeChanged
            ? DiffResult(changedLines: Array(0..<paddedLines.count), isFullRepaint: true)
            : newBuffer.diff(against: previousBuffer)

        // Perform differential update
        await performUpdate(newBuffer: newBuffer, diff: diff)

        // Store for next comparison
        previousBuffer = newBuffer
    }

    private func performUpdate(newBuffer: RenderBuffer, diff: DiffResult) async {
        guard diff.hasChanges else { return }

        await terminal.beginBuffering()

        // Use full repaint when >50% of lines changed (more efficient)
        if diff.isFullRepaint || diff.changeCount > newBuffer.lines.count / 2 {
            await fullRepaint(buffer: newBuffer)
        } else {
            await targetedUpdate(buffer: newBuffer, changedLines: diff.changedLines)
        }

        await terminal.endBuffering()
    }

    private func fullRepaint(buffer: RenderBuffer) async {
        await terminal.moveCursorHome()

        for (index, line) in buffer.lines.enumerated() {
            await terminal.write(line.content)
            if index < buffer.lines.count - 1 {
                await terminal.write("\n")
            }
        }
    }

    private func targetedUpdate(buffer: RenderBuffer, changedLines: [Int]) async {
        for lineIndex in changedLines {
            guard lineIndex < buffer.lines.count else { continue }

            // Move to specific line (1-based row)
            await terminal.moveCursor(row: lineIndex + 1, column: 1)
            await terminal.write(buffer.lines[lineIndex].content)
        }
    }

    /// Force a full repaint on next render (e.g., after resize).
    public func invalidate() {
        previousBuffer = nil
    }

    private func padLineToWidth(_ line: String, width: Int) -> String {
        let visibleLength = RenderEngine.visibleLength(line)
        if visibleLength < width {
            return line + String(repeating: " ", count: width - visibleLength)
        }
        return line
    }
}
