/// An empty view that displays nothing.
public struct EmptyView: View, Sendable {
    public init() {}

    public var body: Never {
        fatalError("EmptyView does not have a body")
    }
}

/// A spacer that expands to fill available space.
public struct Spacer: View, Sendable {
    public let minLength: Int?

    public init(minLength: Int? = nil) {
        self.minLength = minLength
    }

    public var body: Never {
        fatalError("Spacer does not have a body")
    }
}

/// A view that takes up a fixed amount of space.
public struct Divider: View, Sendable {
    public init() {}

    public var body: some View {
        Text("─────────────────────────────────────────")
    }
}
