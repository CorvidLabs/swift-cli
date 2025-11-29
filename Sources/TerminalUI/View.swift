import ANSI
import TerminalCore
import TerminalStyle

/// Internal protocol for views that render themselves directly.
internal protocol DirectRenderable {
    func _directRender(size: Size, visibleLength: (String) -> Int) -> [String]
}

/// A type that represents a terminal UI view.
public protocol View: Sendable {
    /// The type of view representing the body of this view.
    associatedtype Body: View

    /// The content and behavior of the view.
    @ViewBuilder var body: Body { get }
}

/// A type-erased view.
public struct AnyView: View, Sendable {
    private let _render: @Sendable (Size) -> [String]

    public init<V: View>(_ view: V) {
        self._render = { size in
            RenderEngine.render(view, size: size)
        }
    }

    public var body: Never {
        fatalError("AnyView does not have a body")
    }

    func renderLines(size: Size) -> [String] {
        _render(size)
    }
}

/// Never type extension for View.
extension Never: View {
    public var body: Never {
        fatalError("Never has no body")
    }
}

/// Size for rendering.
public struct Size: Sendable, Equatable {
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    public static let zero = Size(width: 0, height: 0)
}

/// Position in terminal.
public struct Position: Sendable, Equatable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public static let zero = Position(x: 0, y: 0)
}
