import ANSI
import TerminalCore
import TerminalStyle
import TerminalInput

/// A confirmation prompt.
public struct Confirm: Sendable {
    /// The question to ask.
    public let message: String

    /// Default value.
    public let defaultValue: Bool?

    /// Hint text.
    public let hint: String?

    /// Terminal reference.
    private let terminal: Terminal

    /// Create a confirmation prompt.
    public init(
        _ message: String,
        default defaultValue: Bool? = nil,
        hint: String? = nil,
        terminal: Terminal = .shared
    ) {
        self.message = message
        self.defaultValue = defaultValue
        self.hint = hint
        self.terminal = terminal
    }

    /// Run the prompt and get the result.
    public func run() async throws -> Bool {
        let hintText: String
        if let hint = hint {
            hintText = hint
        } else if let def = defaultValue {
            hintText = def ? "(Y/n)" : "(y/N)"
        } else {
            hintText = "(y/n)"
        }

        await terminal.write("? ".cyan.render() + message + " " + hintText.dim.render() + " ")

        try await terminal.enableRawMode()
        defer { Task { try? await terminal.disableRawMode() } }

        while true {
            let key = try await terminal.readKey()

            switch key {
            case .character("y"), .character("Y"):
                await terminal.writeLine("Yes".green.render())
                return true

            case .character("n"), .character("N"):
                await terminal.writeLine("No".red.render())
                return false

            case .enter:
                if let def = defaultValue {
                    await terminal.writeLine(def ? "Yes".green.render() : "No".red.render())
                    return def
                }

            case .ctrl(let c) where c == "c" || c == "C":
                await terminal.write("\n")
                throw TerminalError.cancelled

            default:
                break
            }
        }
    }
}

// MARK: - Convenience

extension Terminal {
    /// Ask for confirmation.
    public func confirm(_ message: String, default defaultValue: Bool? = nil) async throws -> Bool {
        try await Confirm(message, default: defaultValue, terminal: self).run()
    }
}
