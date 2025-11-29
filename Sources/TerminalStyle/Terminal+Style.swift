import ANSI
import TerminalCore

/// Terminal extensions for styled output.
extension Terminal {
    /// Write styled text to the terminal.
    public func write(_ styledText: StyledText) {
        write(styledText.render())
    }

    /// Write styled text followed by a newline.
    public func writeLine(_ styledText: StyledText) {
        writeLine(styledText.render())
    }

    /// Write styled text built with a result builder.
    public func write(@StyledText.Builder _ builder: () -> StyledText) {
        write(builder())
    }

    /// Write styled text followed by a newline, built with a result builder.
    public func writeLine(@StyledText.Builder _ builder: () -> StyledText) {
        writeLine(builder())
    }

    /// Print success message.
    public func success(_ message: String) {
        writeLine(StyledText {
            ANSI.Box.Symbol.checkmark.styled.green
            " ".styled
            message.styled
        })
    }

    /// Print error message.
    public func error(_ message: String) {
        writeLine(StyledText {
            ANSI.Box.Symbol.cross.styled.red
            " ".styled
            message.red
        })
    }

    /// Print warning message.
    public func warning(_ message: String) {
        writeLine(StyledText {
            ANSI.Box.Symbol.warning.styled.yellow
            " ".styled
            message.yellow
        })
    }

    /// Print info message.
    public func info(_ message: String) {
        writeLine(StyledText {
            ANSI.Box.Symbol.info.styled.cyan
            " ".styled
            message.styled
        })
    }
}

// MARK: - Character to Styled Text

extension Character {
    /// Convert character to styled text.
    public var styled: StyledText {
        StyledText(String(self))
    }
}
