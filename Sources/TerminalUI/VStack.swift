/// A view that arranges its children in a vertical line.
public struct VStack<Content: View>: View, Sendable {
    public let alignment: HorizontalAlignment
    public let spacing: Int
    public let content: Content

    public enum HorizontalAlignment: Sendable {
        case leading
        case center
        case trailing
    }

    public init(
        alignment: HorizontalAlignment = .leading,
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never {
        fatalError("VStack does not have a body")
    }
}

extension VStack: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        // Get child views and identify spacers for flexible layout
        let childOutputs = getChildOutputsWithFlexibleSpacers(size: size, visibleLength: visibleLength)

        // Calculate max width for alignment
        let maxWidth = childOutputs.flatMap { $0 }.map { visibleLength($0) }.max() ?? 0

        var result: [String] = []
        for (index, childLines) in childOutputs.enumerated() {
            // Add spacing between children (not before first)
            if index > 0 && spacing > 0 {
                for _ in 0..<spacing {
                    result.append("")
                }
            }

            // Apply alignment to each line
            for line in childLines {
                let lineWidth = visibleLength(line)
                let paddingNeeded = maxWidth - lineWidth

                switch alignment {
                case .leading:
                    result.append(line)
                case .center:
                    let leftPad = paddingNeeded / 2
                    result.append(String(repeating: " ", count: leftPad) + line)
                case .trailing:
                    result.append(String(repeating: " ", count: paddingNeeded) + line)
                }
            }
        }

        return result
    }

    private func getChildOutputsWithFlexibleSpacers(size: Size, visibleLength: (String) -> Int) -> [[String]] {
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
        var totalFixedHeight = 0
        var spacerMinHeights: [Int] = []

        for (childIndex, child) in children.enumerated() {
            if let spacer = child as? Spacer {
                spacerIndices.append(childIndex)
                spacerMinHeights.append(spacer.minLength ?? 0)
                fixedOutputs.append(nil)
            } else if let view = child as? any View {
                let output = RenderEngine.render(AnyView(view), size: size)
                totalFixedHeight += output.count
                fixedOutputs.append(output)
            } else {
                fixedOutputs.append([])
            }
        }

        // Calculate spacing height
        let spacingHeight = spacing * max(0, children.count - 1)
        totalFixedHeight += spacingHeight

        // Calculate space for spacers
        let totalMinSpacerHeight = spacerMinHeights.reduce(0, +)
        let availableForSpacers = max(totalMinSpacerHeight, size.height - totalFixedHeight)
        let spacerCount = spacerIndices.count

        // Distribute space among spacers
        var spacePerSpacer: [Int] = []
        if spacerCount > 0 {
            let baseSpace = availableForSpacers / spacerCount
            var remainder = availableForSpacers % spacerCount

            for minHeight in spacerMinHeights {
                var space = max(minHeight, baseSpace)
                if remainder > 0 {
                    space += 1
                    remainder -= 1
                }
                spacePerSpacer.append(space)
            }
        }

        // Second pass: build outputs with spacer heights
        var outputs: [[String]] = []
        var spacerIndex = 0
        for fixedOutput in fixedOutputs {
            if let output = fixedOutput {
                outputs.append(output)
            } else {
                // This is a spacer
                let height = spacerIndex < spacePerSpacer.count ? spacePerSpacer[spacerIndex] : 1
                outputs.append(Array(repeating: "", count: height))
                spacerIndex += 1
            }
        }

        return outputs
    }
}
