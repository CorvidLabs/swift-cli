/// A view that arranges its children in a horizontal line.
public struct HStack<Content: View>: View, Sendable {
    public let alignment: VerticalAlignment
    public let spacing: Int
    public let content: Content

    public enum VerticalAlignment: Sendable {
        case top
        case center
        case bottom
    }

    public init(
        alignment: VerticalAlignment = .center,
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never {
        fatalError("HStack does not have a body")
    }
}

extension HStack: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        // Get child outputs with flexible spacer widths
        let (childOutputs, childWidths) = getChildOutputsWithFlexibleSpacers(size: size, visibleLength: visibleLength)

        if childOutputs.isEmpty {
            return []
        }

        // Calculate max height
        let maxHeight = childOutputs.map { $0.count }.max() ?? 0

        // Pad children to have same height based on alignment
        var paddedChildren: [[String]] = []
        for (index, child) in childOutputs.enumerated() {
            let width = childWidths[index]
            let paddingNeeded = maxHeight - child.count

            var padded: [String] = []
            let emptyLine = String(repeating: " ", count: width)

            switch alignment {
            case .top:
                padded = child
                for _ in 0..<paddingNeeded {
                    padded.append(emptyLine)
                }
            case .center:
                let topPad = paddingNeeded / 2
                let bottomPad = paddingNeeded - topPad
                for _ in 0..<topPad {
                    padded.append(emptyLine)
                }
                padded.append(contentsOf: child)
                for _ in 0..<bottomPad {
                    padded.append(emptyLine)
                }
            case .bottom:
                for _ in 0..<paddingNeeded {
                    padded.append(emptyLine)
                }
                padded.append(contentsOf: child)
            }

            // Ensure each line has consistent width (pad short lines)
            paddedChildren.append(padded.map { line in
                let lineWidth = visibleLength(line)
                if lineWidth < width {
                    return line + String(repeating: " ", count: width - lineWidth)
                }
                return line
            })
        }

        // Combine horizontally with spacing
        let spacerStr = String(repeating: " ", count: spacing)
        var result: [String] = []
        for row in 0..<maxHeight {
            var rowParts: [String] = []
            for child in paddedChildren {
                if row < child.count {
                    rowParts.append(child[row])
                }
            }
            result.append(rowParts.joined(separator: spacerStr))
        }

        return result
    }

    private func getChildOutputsWithFlexibleSpacers(size: Size, visibleLength: (String) -> Int) -> ([[String]], [Int]) {
        // Use Mirror to check if content is a tuple (TupleView)
        let mirror = Mirror(reflecting: content)

        // Get children from TupleView or single content
        var children: [Any] = []
        if let tupleValue = mirror.descendant("value") {
            let tupleMirror = Mirror(reflecting: tupleValue)
            for child in tupleMirror.children {
                children.append(child.value)
            }
        }

        if children.isEmpty {
            // Single child
            children = [content]
        }

        // First pass: render non-spacers, count spacers
        var spacerIndices: [Int] = []
        var fixedOutputs: [[String]?] = []
        var fixedWidths: [Int?] = []
        var totalFixedWidth = 0
        var spacerMinWidths: [Int] = []

        for (childIndex, child) in children.enumerated() {
            if let spacer = child as? Spacer {
                spacerIndices.append(childIndex)
                spacerMinWidths.append(spacer.minLength ?? 0)
                fixedOutputs.append(nil)
                fixedWidths.append(nil)
            } else if let view = child as? any View {
                let output = RenderEngine.render(AnyView(view), size: size)
                let width = output.map { visibleLength($0) }.max() ?? 0
                totalFixedWidth += width
                fixedOutputs.append(output)
                fixedWidths.append(width)
            } else {
                fixedOutputs.append([])
                fixedWidths.append(0)
            }
        }

        // Calculate spacing width
        let spacingWidth = spacing * max(0, children.count - 1)
        totalFixedWidth += spacingWidth

        // Calculate space for spacers
        let totalMinSpacerWidth = spacerMinWidths.reduce(0, +)
        let availableForSpacers = max(totalMinSpacerWidth, size.width - totalFixedWidth)
        let spacerCount = spacerIndices.count

        // Distribute space among spacers
        var spacePerSpacer: [Int] = []
        if spacerCount > 0 {
            let baseSpace = availableForSpacers / spacerCount
            var remainder = availableForSpacers % spacerCount

            for minWidth in spacerMinWidths {
                var space = max(minWidth, baseSpace)
                if remainder > 0 {
                    space += 1
                    remainder -= 1
                }
                spacePerSpacer.append(space)
            }
        }

        // Second pass: build outputs with spacer widths
        var outputs: [[String]] = []
        var widths: [Int] = []
        var spacerIndex = 0
        for fixedOutput in fixedOutputs {
            if let output = fixedOutput {
                outputs.append(output)
                let width = output.map { visibleLength($0) }.max() ?? 0
                widths.append(width)
            } else {
                // This is a spacer - render as empty space
                let width = spacerIndex < spacePerSpacer.count ? spacePerSpacer[spacerIndex] : 1
                outputs.append([String(repeating: " ", count: width)])
                widths.append(width)
                spacerIndex += 1
            }
        }

        return (outputs, widths)
    }
}
