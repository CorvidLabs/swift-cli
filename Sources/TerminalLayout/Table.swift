import ANSI
import TerminalStyle

/// A table with columns and rows.
public struct Table: Renderable, Sendable {
    /// Column definitions.
    public let columns: [Column]

    /// Row data.
    public private(set) var rows: [[String]]

    /// Border style.
    public let style: BoxStyle

    /// Whether to show header row.
    public let showHeader: Bool

    /// Whether to show row separators.
    public let showRowSeparators: Bool

    /// Header style.
    public let headerStyle: HeaderStyle

    /// Column definition.
    public struct Column: Sendable {
        public let header: String
        public let width: Width
        public let alignment: Alignment

        public enum Width: Sendable {
            case auto
            case fixed(Int)
            case min(Int)
            case max(Int)
            case percentage(Int)
        }

        public enum Alignment: Sendable {
            case left
            case center
            case right
        }

        public init(_ header: String, width: Width = .auto, alignment: Alignment = .left) {
            self.header = header
            self.width = width
            self.alignment = alignment
        }
    }

    /// Header styling.
    public enum HeaderStyle: Sendable {
        case plain
        case bold
        case underline
        case reversed
    }

    /// Create a table.
    public init(
        columns: [Column],
        rows: [[String]] = [],
        style: BoxStyle = .single,
        showHeader: Bool = true,
        showRowSeparators: Bool = false,
        headerStyle: HeaderStyle = .bold
    ) {
        self.columns = columns
        self.rows = rows
        self.style = style
        self.showHeader = showHeader
        self.showRowSeparators = showRowSeparators
        self.headerStyle = headerStyle
    }

    /// Add a row.
    public mutating func addRow(_ row: [String]) {
        rows.append(row)
    }

    /// Render the table.
    public func render(width: Int? = nil) -> String {
        guard !columns.isEmpty else { return "" }

        let totalWidth = width ?? 80
        let columnWidths = calculateColumnWidths(totalWidth: totalWidth)

        var lines: [String] = []

        // Top border
        lines.append(renderHorizontalBorder(columnWidths, top: true))

        // Header
        if showHeader {
            lines.append(renderRow(columns.map(\.header), columnWidths, isHeader: true))
            lines.append(renderHorizontalBorder(columnWidths, separator: true))
        }

        // Data rows
        for (index, row) in rows.enumerated() {
            lines.append(renderRow(row, columnWidths, isHeader: false))
            if showRowSeparators && index < rows.count - 1 {
                lines.append(renderHorizontalBorder(columnWidths, separator: true))
            }
        }

        // Bottom border
        lines.append(renderHorizontalBorder(columnWidths, bottom: true))

        return lines.joined(separator: "\n")
    }

    private func calculateColumnWidths(totalWidth: Int) -> [Int] {
        let borderOverhead = columns.count + 1 // Vertical bars
        let availableWidth = totalWidth - borderOverhead

        var widths = [Int](repeating: 0, count: columns.count)
        var remainingWidth = availableWidth
        var autoColumns: [Int] = []

        // First pass: fixed widths and content-based calculations
        for (index, column) in columns.enumerated() {
            let contentWidth = max(
                visibleLength(column.header),
                rows.map { $0.indices.contains(index) ? visibleLength($0[index]) : 0 }.max() ?? 0
            )

            switch column.width {
            case .fixed(let w):
                widths[index] = w
                remainingWidth -= w
            case .min(let m):
                widths[index] = max(m, contentWidth)
                remainingWidth -= widths[index]
            case .max(let m):
                widths[index] = min(m, contentWidth)
                remainingWidth -= widths[index]
            case .percentage(let p):
                widths[index] = (availableWidth * p) / 100
                remainingWidth -= widths[index]
            case .auto:
                autoColumns.append(index)
            }
        }

        // Second pass: distribute remaining width to auto columns
        if !autoColumns.isEmpty && remainingWidth > 0 {
            let perColumn = remainingWidth / autoColumns.count
            for index in autoColumns {
                let contentWidth = max(
                    visibleLength(columns[index].header),
                    rows.map { $0.indices.contains(index) ? visibleLength($0[index]) : 0 }.max() ?? 0
                )
                widths[index] = max(contentWidth, perColumn)
            }
        }

        // Ensure minimum width
        return widths.map { max($0, 1) }
    }

    private func renderHorizontalBorder(_ widths: [Int], top: Bool = false, bottom: Bool = false, separator: Bool = false) -> String {
        let left: Character
        let right: Character
        let middle: Character

        if top {
            left = style.topLeft
            right = style.topRight
            middle = style.horizontalDown
        } else if bottom {
            left = style.bottomLeft
            right = style.bottomRight
            middle = style.horizontalUp
        } else {
            left = style.verticalRight
            right = style.verticalLeft
            middle = style.cross
        }

        var result = String(left)
        for (index, width) in widths.enumerated() {
            result += String(repeating: style.horizontal, count: width)
            if index < widths.count - 1 {
                result += String(middle)
            }
        }
        result += String(right)

        return result
    }

    private func renderRow(_ cells: [String], _ widths: [Int], isHeader: Bool) -> String {
        var result = String(style.vertical)

        for (index, width) in widths.enumerated() {
            let content = cells.indices.contains(index) ? cells[index] : ""
            let alignment = columns[index].alignment
            let padded = pad(content, to: width, alignment: alignment)

            let styled: String
            if isHeader {
                switch headerStyle {
                case .plain:
                    styled = padded
                case .bold:
                    styled = ANSI.Style.bold + padded + ANSI.Style.reset
                case .underline:
                    styled = ANSI.Style.underline + padded + ANSI.Style.reset
                case .reversed:
                    styled = ANSI.Style.reverse + padded + ANSI.Style.reset
                }
            } else {
                styled = padded
            }

            result += styled + String(style.vertical)
        }

        return result
    }

    private func pad(_ string: String, to width: Int, alignment: Column.Alignment) -> String {
        let visible = visibleLength(string)
        let padding = max(0, width - visible)

        switch alignment {
        case .left:
            return string + String(repeating: " ", count: padding)
        case .right:
            return String(repeating: " ", count: padding) + string
        case .center:
            let left = padding / 2
            let right = padding - left
            return String(repeating: " ", count: left) + string + String(repeating: " ", count: right)
        }
    }

    private func visibleLength(_ string: String) -> Int {
        var result = string
        while let range = result.range(of: "\u{1B}\\[[0-9;]*[a-zA-Z]", options: .regularExpression) {
            result.removeSubrange(range)
        }
        while let range = result.range(of: "\u{1B}\\][^\u{07}]*\u{07}", options: .regularExpression) {
            result.removeSubrange(range)
        }
        return result.count
    }
}

// MARK: - Convenience

extension Table {
    /// Create a simple table from data.
    public static func simple(headers: [String], rows: [[String]]) -> Table {
        Table(
            columns: headers.map { Column($0) },
            rows: rows
        )
    }
}
