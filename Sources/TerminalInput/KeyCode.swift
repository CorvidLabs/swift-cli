/// Represents a keyboard key.
public enum KeyCode: Sendable, Equatable, Hashable {
    /// Regular character input.
    case character(Character)

    /// Function keys (F1-F12).
    case function(Int)

    /// Arrow keys.
    case arrow(Arrow)

    /// Special keys.
    case enter
    case tab
    case backspace
    case delete
    case escape
    case home
    case end
    case pageUp
    case pageDown
    case insert

    /// Control key combinations.
    case ctrl(Character)

    /// Alt/Option key combinations.
    case alt(Character)

    /// Unknown escape sequence.
    case unknown(String)

    /// Arrow key directions.
    public enum Arrow: Sendable, Equatable, Hashable {
        case up
        case down
        case left
        case right
    }
}

// MARK: - Convenience

extension KeyCode {
    /// Check if this is a control character.
    public var isControl: Bool {
        if case .ctrl = self { return true }
        return false
    }

    /// Check if this is a printable character.
    public var isPrintable: Bool {
        if case .character(let c) = self {
            return !c.isNewline && c.isLetter || c.isNumber || c.isPunctuation || c.isSymbol || c == " "
        }
        return false
    }

    /// Get the character if this is a character key.
    public var character: Character? {
        if case .character(let c) = self { return c }
        return nil
    }

    /// Common key checks.
    public var isEnter: Bool { self == .enter }
    public var isEscape: Bool { self == .escape }
    public var isBackspace: Bool { self == .backspace }
    public var isTab: Bool { self == .tab }

    /// Check for Ctrl+C.
    public var isInterrupt: Bool {
        if case .ctrl(let c) = self, c == "c" || c == "C" { return true }
        return false
    }

    /// Check for Ctrl+D (EOF).
    public var isEOF: Bool {
        if case .ctrl(let c) = self, c == "d" || c == "D" { return true }
        return false
    }
}

// MARK: - CustomStringConvertible

extension KeyCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .character(let c):
            return String(c)
        case .function(let n):
            return "F\(n)"
        case .arrow(let dir):
            switch dir {
            case .up: return "↑"
            case .down: return "↓"
            case .left: return "←"
            case .right: return "→"
            }
        case .enter:
            return "Enter"
        case .tab:
            return "Tab"
        case .backspace:
            return "Backspace"
        case .delete:
            return "Delete"
        case .escape:
            return "Escape"
        case .home:
            return "Home"
        case .end:
            return "End"
        case .pageUp:
            return "PageUp"
        case .pageDown:
            return "PageDown"
        case .insert:
            return "Insert"
        case .ctrl(let c):
            return "Ctrl+\(c.uppercased())"
        case .alt(let c):
            return "Alt+\(c)"
        case .unknown(let seq):
            return "Unknown(\(seq.debugDescription))"
        }
    }
}
