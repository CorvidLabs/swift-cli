import ANSI
import TerminalCore
import TerminalStyle
import TerminalInput

/// A text input prompt.
public struct Input: Sendable {
    /// The question to ask.
    public let message: String

    /// Default value.
    public let defaultValue: String?

    /// Placeholder text.
    public let placeholder: String?

    /// Whether to mask input (for passwords).
    public let isSecret: Bool

    /// Validation function.
    public let validate: (@Sendable (String) -> String?)?

    /// Terminal reference.
    private let terminal: Terminal

    /// Create an input prompt.
    public init(
        _ message: String,
        default defaultValue: String? = nil,
        placeholder: String? = nil,
        secret: Bool = false,
        validate: (@Sendable (String) -> String?)? = nil,
        terminal: Terminal = .shared
    ) {
        self.message = message
        self.defaultValue = defaultValue
        self.placeholder = placeholder
        self.isSecret = secret
        self.validate = validate
        self.terminal = terminal
    }

    /// Run the prompt and get the input.
    public func run() async throws -> String {
        var buffer: [Character] = []
        var errorMessage: String?

        try await terminal.enableRawMode()
        defer { Task { try? await terminal.disableRawMode() } }

        await render(buffer: buffer, error: errorMessage, firstRender: true)

        while true {
            let key = try await terminal.readKey()

            switch key {
            case .character(let char):
                buffer.append(char)
                errorMessage = nil
                await render(buffer: buffer, error: errorMessage)

            case .backspace:
                if !buffer.isEmpty {
                    buffer.removeLast()
                    errorMessage = nil
                    await render(buffer: buffer, error: errorMessage)
                }

            case .enter:
                var value = String(buffer)
                if value.isEmpty, let def = defaultValue {
                    value = def
                }

                if let validate = validate {
                    if let error = validate(value) {
                        errorMessage = error
                        await render(buffer: buffer, error: errorMessage)
                        continue
                    }
                }

                await finalize(value: value)
                return value

            case .ctrl(let c) where c == "c" || c == "C":
                await terminal.write("\n")
                throw TerminalError.cancelled

            case .ctrl(let c) where c == "u" || c == "U":
                buffer = []
                errorMessage = nil
                await render(buffer: buffer, error: errorMessage)

            default:
                break
            }
        }
    }

    private func render(buffer: [Character], error: String?, firstRender: Bool = false) async {
        if !firstRender {
            await terminal.write(ANSI.Cursor.up(error != nil ? 2 : 1))
        }

        await terminal.write("\r" + ANSI.Erase.lineFromCursor)

        var line = "? ".cyan.render() + message + " "

        let value = String(buffer)
        if value.isEmpty {
            if let def = defaultValue {
                line += "(\(def))".dim.render() + " "
            } else if let ph = placeholder {
                line += ph.dim.render()
            }
        } else if isSecret {
            line += String(repeating: "*", count: buffer.count)
        } else {
            line += value
        }

        await terminal.writeLine(line)

        // Error message
        await terminal.write(ANSI.Erase.lineFromCursor)
        if let error = error {
            await terminal.writeLine("  " + "✗ ".red.render() + error.red.render())
        }
    }

    private func finalize(value: String) async {
        await terminal.write(ANSI.Cursor.up(1))
        await terminal.write("\r" + ANSI.Erase.lineFromCursor)

        let displayValue = isSecret ? "********" : value
        await terminal.writeLine("? ".cyan.render() + message + " " + displayValue.cyan.render())
    }
}

// MARK: - Convenience

extension Terminal {
    /// Run an input prompt.
    public func input(_ message: String, default defaultValue: String? = nil) async throws -> String {
        try await Input(message, default: defaultValue, terminal: self).run()
    }

    /// Run a secret input prompt.
    public func secret(_ message: String) async throws -> String {
        try await Input(message, secret: true, terminal: self).run()
    }
}
