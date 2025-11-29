import ANSI
import Foundation
import TerminalCore
import TerminalStyle

/// Terminal extensions for input handling.
extension Terminal {
    /// Read a single key with timeout (requires raw mode).
    /// Returns nil if no input is received within the timeout period.
    /// Uses poll(2) for sub-millisecond latency on local terminals.
    public func readKeyWithTimeout(milliseconds: Int) async throws -> KeyCode? {
        // Use poll(2) to wait for input - returns immediately when data arrives
        guard waitForInput(timeoutMs: milliseconds) else {
            return nil // Timeout - no input
        }

        // Input is available - read it
        guard let firstByte = try readByte() else {
            return nil
        }

        var bytes: [UInt8] = [firstByte]

        // Check for escape sequence
        if firstByte == 0x1B {
            // For local terminals, escape sequence bytes arrive together.
            // Read all immediately available bytes without waiting.
            while hasInput() {
                if let nextByte = try readByte() {
                    bytes.append(nextByte)
                    if isCompleteSequence(bytes) || bytes.count > 16 {
                        break
                    }
                } else {
                    break
                }
            }

            // If we only got ESC and no more bytes are immediately available,
            // wait briefly for potential sequence bytes (1ms max for local)
            if bytes.count == 1 && waitForInput(timeoutMs: 1) {
                while hasInput() {
                    if let nextByte = try readByte() {
                        bytes.append(nextByte)
                        if isCompleteSequence(bytes) || bytes.count > 16 {
                            break
                        }
                    } else {
                        break
                    }
                }
            }
        }

        let reader = InputReader()
        if let event = reader.parse(bytes), case .key(let code, _) = event {
            return code
        }

        return .unknown(bytes.map { String(format: "%02X", $0) }.joined(separator: " "))
    }

    /// Read a single key (requires raw mode).
    /// Uses poll(2) for instant response on local terminals.
    public func readKey() async throws -> KeyCode {
        // Wait for input using poll(2) - blocks until input arrives
        while !waitForInput(timeoutMs: 100) {
            // Yield to allow task cancellation
            await Task.yield()
        }

        guard let firstByte = try readByte() else {
            throw TerminalError.inputError("No input available")
        }

        var bytes: [UInt8] = [firstByte]

        // Check for escape sequence
        if firstByte == 0x1B {
            // For local terminals, read all immediately available bytes
            while hasInput() {
                if let nextByte = try readByte() {
                    bytes.append(nextByte)
                    if isCompleteSequence(bytes) || bytes.count > 16 {
                        break
                    }
                } else {
                    break
                }
            }

            // Brief wait for potential sequence bytes if we only got ESC
            if bytes.count == 1 && waitForInput(timeoutMs: 1) {
                while hasInput() {
                    if let nextByte = try readByte() {
                        bytes.append(nextByte)
                        if isCompleteSequence(bytes) || bytes.count > 16 {
                            break
                        }
                    } else {
                        break
                    }
                }
            }
        }

        let reader = InputReader()
        if let event = reader.parse(bytes), case .key(let code, _) = event {
            return code
        }

        return .unknown(bytes.map { String(format: "%02X", $0) }.joined(separator: " "))
    }

    /// Read an input event (requires raw mode).
    /// Uses poll(2) for instant response on local terminals.
    public func readEvent() async throws -> InputEvent {
        // Wait for input using poll(2) - blocks until input arrives
        while !waitForInput(timeoutMs: 100) {
            await Task.yield()
        }

        guard let firstByte = try readByte() else {
            throw TerminalError.inputError("No input available")
        }

        var bytes: [UInt8] = [firstByte]

        // Check for escape sequence
        if firstByte == 0x1B {
            // For local terminals, read all immediately available bytes
            while hasInput() {
                if let nextByte = try readByte() {
                    bytes.append(nextByte)
                    if isCompleteSequence(bytes) || bytes.count > 16 {
                        break
                    }
                } else {
                    break
                }
            }

            // Brief wait for potential sequence bytes if we only got ESC
            if bytes.count == 1 && waitForInput(timeoutMs: 1) {
                while hasInput() {
                    if let nextByte = try readByte() {
                        bytes.append(nextByte)
                        if isCompleteSequence(bytes) || bytes.count > 16 {
                            break
                        }
                    } else {
                        break
                    }
                }
            }
        }

        let reader = InputReader()
        return reader.parse(bytes) ?? .key(.unknown(""), .none)
    }

    private func isCompleteSequence(_ bytes: [UInt8]) -> Bool {
        guard bytes.count >= 2 else { return false }

        // CSI sequence: ESC [ <params> <final>
        // Need at least 3 bytes: ESC, [, and final byte
        if bytes[1] == 0x5B {
            guard bytes.count >= 3 else { return false }
            if let last = bytes.last {
                return last >= 0x40 && last <= 0x7E
            }
        }

        if bytes[1] == 0x4F && bytes.count >= 3 {
            return true
        }

        if bytes.count == 2 {
            return true
        }

        return false
    }

    /// Read a line of input (basic, without history).
    public func readLine(prompt: String = "") async throws -> String {
        write(prompt)

        var buffer: [Character] = []

        while true {
            let key = try await readKey()

            switch key {
            case .enter:
                write("\n")
                return String(buffer)

            case .character(let char):
                buffer.append(char)
                write(String(char))

            case .backspace:
                if !buffer.isEmpty {
                    buffer.removeLast()
                    write("\u{08} \u{08}") // Backspace, space, backspace
                }

            case .ctrl(let c) where c == "c" || c == "C":
                write("^C\n")
                throw TerminalError.cancelled

            case .ctrl(let c) where c == "d" || c == "D":
                if buffer.isEmpty {
                    throw TerminalError.cancelled
                }

            default:
                break
            }
        }
    }

    /// Read a password (hidden input).
    public func readPassword(prompt: String = "Password: ") async throws -> String {
        write(prompt)

        var buffer: [Character] = []

        while true {
            let key = try await readKey()

            switch key {
            case .enter:
                write("\n")
                return String(buffer)

            case .character(let char):
                buffer.append(char)
                // Don't echo the character

            case .backspace:
                if !buffer.isEmpty {
                    buffer.removeLast()
                }

            case .ctrl(let c) where c == "c" || c == "C":
                write("\n")
                throw TerminalError.cancelled

            default:
                break
            }
        }
    }

    /// Read a password with masked display.
    public func readPasswordMasked(prompt: String = "Password: ", mask: Character = "*") async throws -> String {
        write(prompt)

        var buffer: [Character] = []

        while true {
            let key = try await readKey()

            switch key {
            case .enter:
                write("\n")
                return String(buffer)

            case .character(let char):
                buffer.append(char)
                write(String(mask))

            case .backspace:
                if !buffer.isEmpty {
                    buffer.removeLast()
                    write("\u{08} \u{08}")
                }

            case .ctrl(let c) where c == "c" || c == "C":
                write("\n")
                throw TerminalError.cancelled

            default:
                break
            }
        }
    }

    /// Wait for any key press.
    public func waitForKey(message: String = "Press any key to continue...") async throws -> KeyCode {
        write(message)
        let key = try await readKey()
        write("\n")
        return key
    }

    /// Query current cursor position.
    /// Returns (row, column) with 1-based indexing.
    public func queryCursorPosition() async throws -> (row: Int, column: Int) {
        // Send cursor position query
        write(ANSI.Report.cursorPosition)

        // Read response: ESC [ row ; col R
        var bytes: [UInt8] = []
        let maxBytes = 20
        let maxRetries = 50

        var retries = 0
        while bytes.last != 0x52 && retries < maxRetries { // 'R'
            if let byte = try readByte() {
                bytes.append(byte)
                if bytes.count > maxBytes {
                    throw TerminalError.inputError("Cursor position response too long")
                }
                retries = 0
            } else {
                retries += 1
                try await Task.sleep(nanoseconds: 5_000_000) // 5ms
            }
        }

        // Parse response: ESC [ row ; col R
        guard bytes.count >= 6,
              bytes[0] == 0x1B,
              bytes[1] == 0x5B,
              bytes.last == 0x52 else {
            throw TerminalError.inputError("Invalid cursor position response")
        }

        let content = bytes.dropFirst(2).dropLast() // Remove ESC [ and R
        guard let string = String(bytes: Array(content), encoding: .ascii) else {
            throw TerminalError.inputError("Invalid cursor position response encoding")
        }

        let parts = string.split(separator: ";")
        guard parts.count == 2,
              let row = Int(parts[0]),
              let col = Int(parts[1]) else {
            throw TerminalError.inputError("Invalid cursor position format")
        }

        return (row, col)
    }
}
