import ANSI
import TerminalCore

#if canImport(Darwin)
import Darwin
#elseif os(Linux)
import Glibc
#endif

/// Parses terminal input into structured events.
public struct InputReader: Sendable {
    /// Create an input reader.
    public init() {}

    /// Parse a sequence of bytes into an input event.
    public func parse(_ bytes: [UInt8]) -> InputEvent? {
        guard !bytes.isEmpty else { return nil }

        // Single byte
        if bytes.count == 1 {
            return parseSingleByte(bytes[0])
        }

        // Escape sequence
        if bytes[0] == 0x1B {
            return parseEscapeSequence(bytes)
        }

        // UTF-8 character
        if let string = String(bytes: bytes, encoding: .utf8), let char = string.first {
            return .key(.character(char), .none)
        }

        return nil
    }

    private func parseSingleByte(_ byte: UInt8) -> InputEvent {
        switch byte {
        case 0x00:
            return .key(.ctrl(" "), .control)
        case 0x09:
            return .key(.tab, .none)
        case 0x0A, 0x0D:
            return .key(.enter, .none)
        case 0x01...0x1A:
            // Ctrl+A through Ctrl+Z (excluding Tab and Enter handled above)
            let char = Character(UnicodeScalar(byte + 0x60))
            return .key(.ctrl(char), .control)
        case 0x1B:
            return .key(.escape, .none)
        case 0x7F:
            return .key(.backspace, .none)
        case 0x20...0x7E:
            return .key(.character(Character(UnicodeScalar(byte))), .none)
        default:
            return .key(.unknown(String(format: "0x%02X", byte)), .none)
        }
    }

    private func parseEscapeSequence(_ bytes: [UInt8]) -> InputEvent? {
        guard bytes.count >= 2 else {
            return .key(.escape, .none)
        }

        // CSI sequences (ESC [)
        if bytes[1] == 0x5B { // '['
            return parseCSISequence(Array(bytes.dropFirst(2)))
        }

        // SS3 sequences (ESC O) - function keys
        if bytes[1] == 0x4F { // 'O'
            return parseSS3Sequence(Array(bytes.dropFirst(2)))
        }

        // Alt+key (ESC followed by character)
        if bytes.count == 2 {
            let char = Character(UnicodeScalar(bytes[1]))
            return .key(.alt(char), .alt)
        }

        return .key(.unknown(bytes.map { String(format: "%02X", $0) }.joined(separator: " ")), .none)
    }

    private func parseCSISequence(_ bytes: [UInt8]) -> InputEvent? {
        guard !bytes.isEmpty else { return nil }

        let lastByte = bytes.last!

        // Arrow keys
        switch lastByte {
        case 0x41: // 'A'
            return .key(.arrow(.up), parseModifiers(bytes))
        case 0x42: // 'B'
            return .key(.arrow(.down), parseModifiers(bytes))
        case 0x43: // 'C'
            return .key(.arrow(.right), parseModifiers(bytes))
        case 0x44: // 'D'
            return .key(.arrow(.left), parseModifiers(bytes))
        case 0x48: // 'H'
            return .key(.home, parseModifiers(bytes))
        case 0x46: // 'F'
            return .key(.end, parseModifiers(bytes))
        default:
            break
        }

        // Tilde sequences (Home, End, Insert, Delete, PageUp, PageDown)
        if lastByte == 0x7E { // '~'
            let numBytes = bytes.dropLast()
            if let numStr = String(bytes: Array(numBytes), encoding: .ascii),
               let parts = numStr.split(separator: ";").first,
               let num = Int(parts) {
                return parseTildeSequence(num, parseModifiers(bytes))
            }
        }

        // Mouse sequences (SGR format: CSI < ... M or m)
        if bytes.first == 0x3C { // '<'
            return parseMouseSGR(Array(bytes.dropFirst()))
        }

        // Focus events
        if bytes.count == 1 {
            switch bytes[0] {
            case 0x49: // 'I'
                return .focusGained
            case 0x4F: // 'O'
                return .focusLost
            default:
                break
            }
        }

        return .key(.unknown("CSI " + bytes.map { String(format: "%02X", $0) }.joined(separator: " ")), .none)
    }

    private func parseSS3Sequence(_ bytes: [UInt8]) -> InputEvent? {
        guard let byte = bytes.first else { return nil }

        switch byte {
        case 0x50: return .key(.function(1), .none)
        case 0x51: return .key(.function(2), .none)
        case 0x52: return .key(.function(3), .none)
        case 0x53: return .key(.function(4), .none)
        case 0x41: return .key(.arrow(.up), .none)
        case 0x42: return .key(.arrow(.down), .none)
        case 0x43: return .key(.arrow(.right), .none)
        case 0x44: return .key(.arrow(.left), .none)
        case 0x48: return .key(.home, .none)
        case 0x46: return .key(.end, .none)
        default:
            return .key(.unknown("SS3 " + String(format: "%02X", byte)), .none)
        }
    }

    private func parseTildeSequence(_ num: Int, _ modifiers: Modifiers) -> InputEvent {
        switch num {
        case 1: return .key(.home, modifiers)
        case 2: return .key(.insert, modifiers)
        case 3: return .key(.delete, modifiers)
        case 4: return .key(.end, modifiers)
        case 5: return .key(.pageUp, modifiers)
        case 6: return .key(.pageDown, modifiers)
        case 11: return .key(.function(1), modifiers)
        case 12: return .key(.function(2), modifiers)
        case 13: return .key(.function(3), modifiers)
        case 14: return .key(.function(4), modifiers)
        case 15: return .key(.function(5), modifiers)
        case 17: return .key(.function(6), modifiers)
        case 18: return .key(.function(7), modifiers)
        case 19: return .key(.function(8), modifiers)
        case 20: return .key(.function(9), modifiers)
        case 21: return .key(.function(10), modifiers)
        case 23: return .key(.function(11), modifiers)
        case 24: return .key(.function(12), modifiers)
        default:
            return .key(.unknown("~\(num)"), modifiers)
        }
    }

    private func parseModifiers(_ bytes: [UInt8]) -> Modifiers {
        // Look for modifier parameter (e.g., "1;2" where 2 is the modifier)
        guard let string = String(bytes: bytes, encoding: .ascii) else {
            return .none
        }

        let parts = string.split(separator: ";")
        guard parts.count >= 2, let modNum = Int(parts[1].filter(\.isNumber)) else {
            return .none
        }

        // Modifier encoding: 1 + (shift ? 1 : 0) + (alt ? 2 : 0) + (ctrl ? 4 : 0) + (meta ? 8 : 0)
        let value = modNum - 1
        var modifiers: Modifiers = .none
        if value & 1 != 0 { modifiers.insert(.shift) }
        if value & 2 != 0 { modifiers.insert(.alt) }
        if value & 4 != 0 { modifiers.insert(.control) }
        if value & 8 != 0 { modifiers.insert(.meta) }

        return modifiers
    }

    private func parseMouseSGR(_ bytes: [UInt8]) -> InputEvent? {
        guard let string = String(bytes: bytes, encoding: .ascii) else {
            return nil
        }

        let isRelease = string.hasSuffix("m")
        let numString = string.dropLast() // Remove 'M' or 'm'
        let parts = numString.split(separator: ";")

        guard parts.count == 3,
              let buttonCode = Int(parts[0]),
              let column = Int(parts[1]),
              let row = Int(parts[2]) else {
            return nil
        }

        let button: MouseEvent.Button
        let action: MouseEvent.Action

        switch buttonCode & 0x03 {
        case 0: button = .left
        case 1: button = .middle
        case 2: button = .right
        case 3: button = .none
        default: button = .none
        }

        if buttonCode & 64 != 0 {
            // Scroll
            if buttonCode & 1 != 0 {
                return .mouse(MouseEvent(action: .scrollDown, button: .scrollDown, column: column, row: row))
            } else {
                return .mouse(MouseEvent(action: .scrollUp, button: .scrollUp, column: column, row: row))
            }
        } else if buttonCode & 32 != 0 {
            action = .drag
        } else if isRelease {
            action = .release
        } else {
            action = .press
        }

        var modifiers: Modifiers = .none
        if buttonCode & 4 != 0 { modifiers.insert(.shift) }
        if buttonCode & 8 != 0 { modifiers.insert(.alt) }
        if buttonCode & 16 != 0 { modifiers.insert(.control) }

        return .mouse(MouseEvent(action: action, button: button, column: column, row: row, modifiers: modifiers))
    }
}
