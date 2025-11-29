/// Result builder for composing views.
@resultBuilder
public struct ViewBuilder {
    /// Build a single view.
    public static func buildBlock<V: View>(_ content: V) -> V {
        content
    }

    /// Build multiple views into a TupleView.
    public static func buildBlock<V0: View, V1: View>(_ v0: V0, _ v1: V1) -> TupleView<(V0, V1)> {
        TupleView((v0, v1))
    }

    public static func buildBlock<V0: View, V1: View, V2: View>(_ v0: V0, _ v1: V1, _ v2: V2) -> TupleView<(V0, V1, V2)> {
        TupleView((v0, v1, v2))
    }

    public static func buildBlock<V0: View, V1: View, V2: View, V3: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3) -> TupleView<(V0, V1, V2, V3)> {
        TupleView((v0, v1, v2, v3))
    }

    public static func buildBlock<V0: View, V1: View, V2: View, V3: View, V4: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4) -> TupleView<(V0, V1, V2, V3, V4)> {
        TupleView((v0, v1, v2, v3, v4))
    }

    /// Build optional content.
    public static func buildOptional<V: View>(_ component: V?) -> OptionalView<V> {
        OptionalView(component)
    }

    /// Build first branch of conditional.
    public static func buildEither<First: View, Second: View>(first component: First) -> ConditionalView<First, Second> {
        .first(component)
    }

    /// Build second branch of conditional.
    public static func buildEither<First: View, Second: View>(second component: Second) -> ConditionalView<First, Second> {
        .second(component)
    }

    /// Build expression.
    public static func buildExpression<V: View>(_ expression: V) -> V {
        expression
    }

    /// Build expression from string.
    public static func buildExpression(_ expression: String) -> Text {
        Text(expression)
    }
}

/// A view that holds a tuple of views.
public struct TupleView<T: Sendable>: View, Sendable {
    public let value: T

    public init(_ value: T) {
        self.value = value
    }

    public var body: Never {
        fatalError("TupleView does not have a body")
    }
}

extension TupleView: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        var lines: [String] = []
        let mirror = Mirror(reflecting: value)
        for child in mirror.children {
            if let view = child.value as? any View {
                lines.append(contentsOf: RenderEngine.render(AnyView(view), size: size))
            }
        }
        return lines
    }
}

/// A view that may or may not be present.
public struct OptionalView<Content: View>: View, Sendable {
    public let content: Content?

    public init(_ content: Content?) {
        self.content = content
    }

    public var body: some View {
        if let content = content {
            content
        } else {
            EmptyView()
        }
    }
}

/// A view that shows one of two possible views.
public enum ConditionalView<First: View, Second: View>: View, Sendable {
    case first(First)
    case second(Second)

    public var body: Never {
        fatalError("ConditionalView is rendered directly")
    }
}

extension ConditionalView: DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String] {
        switch self {
        case .first(let view):
            return RenderEngine.render(AnyView(view), size: size)
        case .second(let view):
            return RenderEngine.render(AnyView(view), size: size)
        }
    }
}
