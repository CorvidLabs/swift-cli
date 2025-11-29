/// A structure that computes views on demand from a collection.
public struct ForEach<Data: RandomAccessCollection & Sendable, Content: View>: View, Sendable where Data.Element: Sendable {
    public let data: Data
    public let content: @Sendable (Data.Element) -> Content

    public init(_ data: Data, @ViewBuilder content: @escaping @Sendable (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    public var body: Never {
        fatalError("ForEach does not have a body")
    }
}

extension ForEach where Data == Range<Int> {
    /// Create a ForEach from a range.
    public init(_ data: Range<Int>, @ViewBuilder content: @escaping @Sendable (Int) -> Content) {
        self.data = data
        self.content = content
    }
}

extension ForEach: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        var lines: [String] = []
        for element in data {
            let view = content(element)
            lines.append(contentsOf: RenderEngine.render(AnyView(view), size: size))
        }
        return lines
    }
}
