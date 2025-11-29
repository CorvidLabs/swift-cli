import TerminalCore

/// Represents a single rendered line with content and hash for fast comparison.
public struct RenderedLine: Sendable, Equatable {
    public let content: String
    private let contentHash: Int

    public init(_ content: String) {
        self.content = content
        self.contentHash = content.hashValue
    }

    public static func == (lhs: RenderedLine, rhs: RenderedLine) -> Bool {
        // Fast path: compare hashes first
        guard lhs.contentHash == rhs.contentHash else { return false }
        // Only compare strings if hashes match (collision check)
        return lhs.content == rhs.content
    }
}

/// Result of comparing two render buffers.
public struct DiffResult: Sendable {
    /// Indices of lines that changed.
    public let changedLines: [Int]
    /// Whether a full repaint is needed (e.g., size changed).
    public let isFullRepaint: Bool

    public var hasChanges: Bool { !changedLines.isEmpty }
    public var changeCount: Int { changedLines.count }
}

/// Buffer holding complete render state for differential comparison.
public struct RenderBuffer: Sendable {
    public var lines: [RenderedLine]
    public let size: Size

    public init(lines: [String], size: Size) {
        self.lines = lines.map { RenderedLine($0) }
        self.size = size
    }

    /// Compare with another buffer and return indices of changed lines.
    public func diff(against previous: RenderBuffer?) -> DiffResult {
        guard let previous = previous, previous.size == self.size else {
            // Full repaint needed (no previous or size changed)
            return DiffResult(changedLines: Array(0..<lines.count), isFullRepaint: true)
        }

        var changedIndices: [Int] = []

        for i in 0..<max(lines.count, previous.lines.count) {
            let current = i < lines.count ? lines[i] : nil
            let prev = i < previous.lines.count ? previous.lines[i] : nil

            if current != prev {
                changedIndices.append(i)
            }
        }

        return DiffResult(changedLines: changedIndices, isFullRepaint: false)
    }
}
