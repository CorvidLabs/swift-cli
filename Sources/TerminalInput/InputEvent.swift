import TerminalCore

/// Terminal input events.
public enum InputEvent: Sendable {
    /// Keyboard input.
    case key(KeyCode, Modifiers)

    /// Mouse input.
    case mouse(MouseEvent)

    /// Terminal was resized.
    case resize(TerminalSize)

    /// Focus gained.
    case focusGained

    /// Focus lost.
    case focusLost

    /// Paste started (bracketed paste mode).
    case pasteStart

    /// Paste ended.
    case pasteEnd

    /// Paste content.
    case paste(String)
}

// MARK: - Convenience

extension InputEvent {
    /// Check if this is a key event.
    public var isKey: Bool {
        if case .key = self { return true }
        return false
    }

    /// Check if this is a mouse event.
    public var isMouse: Bool {
        if case .mouse = self { return true }
        return false
    }

    /// Get the key code if this is a key event.
    public var keyCode: KeyCode? {
        if case .key(let code, _) = self { return code }
        return nil
    }

    /// Get the mouse event if this is a mouse event.
    public var mouseEvent: MouseEvent? {
        if case .mouse(let event) = self { return event }
        return nil
    }

    /// Check if this event should quit the application.
    public var isQuit: Bool {
        switch self {
        case .key(let code, _):
            return code.isInterrupt || code.isEOF || code == .character("q")
        default:
            return false
        }
    }
}
