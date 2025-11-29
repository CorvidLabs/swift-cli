/// Alignment for ZStack.
public struct ZStackAlignment: Sendable {
    public let horizontal: HStack<EmptyView>.VerticalAlignment
    public let vertical: VStack<EmptyView>.HorizontalAlignment

    public init(horizontal: HStack<EmptyView>.VerticalAlignment, vertical: VStack<EmptyView>.HorizontalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    public static let center = ZStackAlignment(horizontal: .center, vertical: .center)
    public static let topLeading = ZStackAlignment(horizontal: .top, vertical: .leading)
    public static let top = ZStackAlignment(horizontal: .top, vertical: .center)
    public static let topTrailing = ZStackAlignment(horizontal: .top, vertical: .trailing)
    public static let leading = ZStackAlignment(horizontal: .center, vertical: .leading)
    public static let trailing = ZStackAlignment(horizontal: .center, vertical: .trailing)
    public static let bottomLeading = ZStackAlignment(horizontal: .bottom, vertical: .leading)
    public static let bottom = ZStackAlignment(horizontal: .bottom, vertical: .center)
    public static let bottomTrailing = ZStackAlignment(horizontal: .bottom, vertical: .trailing)
}

/// A view that overlays its children, aligning them in both axes.
public struct ZStack<Content: View>: View, Sendable {
    public let alignment: ZStackAlignment
    public let content: Content

    public init(
        alignment: ZStackAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: Never {
        fatalError("ZStack does not have a body")
    }
}

extension ZStack: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        // Get child outputs as separate groups
        let childOutputs = getChildOutputs(size: size)

        if childOutputs.isEmpty {
            return []
        }

        // Calculate max dimensions
        let maxHeight = childOutputs.map { $0.count }.max() ?? 0
        let maxWidth = childOutputs.flatMap { $0 }.map { visibleLength($0) }.max() ?? 0

        // Start with empty canvas
        var canvas: [[Character]] = Array(
            repeating: Array(repeating: " ", count: maxWidth),
            count: maxHeight
        )

        // Overlay each child (later children on top)
        for child in childOutputs {
            let childHeight = child.count
            let childWidth = child.map { visibleLength($0) }.max() ?? 0

            // Calculate position based on alignment
            let yOffset: Int
            switch alignment.horizontal {
            case .top:
                yOffset = 0
            case .center:
                yOffset = (maxHeight - childHeight) / 2
            case .bottom:
                yOffset = maxHeight - childHeight
            }

            let xOffset: Int
            switch alignment.vertical {
            case .leading:
                xOffset = 0
            case .center:
                xOffset = (maxWidth - childWidth) / 2
            case .trailing:
                xOffset = maxWidth - childWidth
            }

            // Overlay child onto canvas (simplified - ignores ANSI codes)
            for (rowIndex, line) in child.enumerated() {
                let y = yOffset + rowIndex
                if y >= 0 && y < maxHeight {
                    var x = xOffset
                    for char in line {
                        if x >= 0 && x < maxWidth && char != " " {
                            canvas[y][x] = char
                        }
                        x += 1
                    }
                }
            }
        }

        // Convert canvas back to strings
        return canvas.map { String($0) }
    }

    private func getChildOutputs(size: Size) -> [[String]] {
        // Use Mirror to check if content is a tuple (TupleView)
        let mirror = Mirror(reflecting: content)

        // Check if this is a TupleView by looking for a 'value' property that's a tuple
        if let tupleValue = mirror.descendant("value") {
            let tupleMirror = Mirror(reflecting: tupleValue)
            var outputs: [[String]] = []
            for child in tupleMirror.children {
                if let view = child.value as? any View {
                    outputs.append(RenderEngine.render(AnyView(view), size: size))
                }
            }
            if !outputs.isEmpty {
                return outputs
            }
        }

        // Single child - render content directly
        return [RenderEngine.render(AnyView(content), size: size)]
    }
}
