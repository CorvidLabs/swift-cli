/// Edge insets for padding.
public struct EdgeInsets: Sendable, Equatable {
    public let top: Int
    public let leading: Int
    public let bottom: Int
    public let trailing: Int

    public init(top: Int = 0, leading: Int = 0, bottom: Int = 0, trailing: Int = 0) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    public init(_ all: Int) {
        self.top = all
        self.leading = all
        self.bottom = all
        self.trailing = all
    }

    public init(horizontal: Int = 0, vertical: Int = 0) {
        self.top = vertical
        self.leading = horizontal
        self.bottom = vertical
        self.trailing = horizontal
    }

    public static let zero = EdgeInsets()
}

/// A view modifier that adds padding around content.
public struct PaddedView<Content: View>: View, Sendable {
    public let content: Content
    public let padding: EdgeInsets

    public init(content: Content, padding: EdgeInsets) {
        self.content = content
        self.padding = padding
    }

    public var body: Never {
        fatalError("PaddedView is rendered directly")
    }
}

extension PaddedView: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        // Render content with reduced size
        let contentSize = Size(
            width: max(0, size.width - padding.leading - padding.trailing),
            height: max(0, size.height - padding.top - padding.bottom)
        )
        let contentLines = RenderEngine.render(AnyView(content), size: contentSize)

        // Calculate the max content width for consistent padding
        let maxContentWidth = contentLines.map { visibleLength($0) }.max() ?? 0
        let totalWidth = maxContentWidth + padding.leading + padding.trailing

        var result: [String] = []

        // Add top padding
        let emptyLine = String(repeating: " ", count: totalWidth)
        for _ in 0..<padding.top {
            result.append(emptyLine)
        }

        // Add content with horizontal padding
        let leftPad = String(repeating: " ", count: padding.leading)
        let rightPadBase = String(repeating: " ", count: padding.trailing)
        for line in contentLines {
            let lineWidth = visibleLength(line)
            let rightPad = String(repeating: " ", count: maxContentWidth - lineWidth) + rightPadBase
            result.append(leftPad + line + rightPad)
        }

        // Add bottom padding
        for _ in 0..<padding.bottom {
            result.append(emptyLine)
        }

        return result
    }
}

extension View {
    /// Add padding to all edges.
    public func padding(_ all: Int = 1) -> PaddedView<Self> {
        PaddedView(content: self, padding: EdgeInsets(all))
    }

    /// Add padding with specific insets.
    public func padding(_ insets: EdgeInsets) -> PaddedView<Self> {
        PaddedView(content: self, padding: insets)
    }

    /// Add horizontal and vertical padding.
    public func padding(horizontal: Int = 0, vertical: Int = 0) -> PaddedView<Self> {
        PaddedView(content: self, padding: EdgeInsets(horizontal: horizontal, vertical: vertical))
    }
}
