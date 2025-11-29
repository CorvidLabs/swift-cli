/// Mouse event types.
public struct MouseEvent: Sendable, Equatable {
    /// The type of mouse action.
    public let action: Action

    /// Mouse button involved.
    public let button: Button

    /// Column position (1-based).
    public let column: Int

    /// Row position (1-based).
    public let row: Int

    /// Keyboard modifiers held during the event.
    public let modifiers: Modifiers

    /// Mouse actions.
    public enum Action: Sendable, Equatable {
        case press
        case release
        case drag
        case move
        case scrollUp
        case scrollDown
    }

    /// Mouse buttons.
    public enum Button: Sendable, Equatable {
        case left
        case middle
        case right
        case none
        case scrollUp
        case scrollDown
    }

    /// Create a mouse event.
    public init(
        action: Action,
        button: Button,
        column: Int,
        row: Int,
        modifiers: Modifiers = .none
    ) {
        self.action = action
        self.button = button
        self.column = column
        self.row = row
        self.modifiers = modifiers
    }
}

extension MouseEvent: CustomStringConvertible {
    public var description: String {
        "Mouse(\(action) \(button) at \(column),\(row))"
    }
}
