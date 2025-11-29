import ANSI
import TerminalStyle

/// A horizontal divider line.
public struct Divider: Renderable, Sendable {
    /// Character to use for the divider.
    public let character: Character

    /// Title in the middle of the divider.
    public let title: String?

    /// Title alignment.
    public let titleAlignment: Box.Alignment

    /// Color of the divider.
    public let color: ANSI.Color?

    /// Create a divider.
    public init(
        character: Character = "─",
        title: String? = nil,
        titleAlignment: Box.Alignment = .center,
        color: ANSI.Color? = nil
    ) {
        self.character = character
        self.title = title
        self.titleAlignment = titleAlignment
        self.color = color
    }

    /// Render the divider.
    public func render(width: Int? = nil) -> String {
        let totalWidth = width ?? 80

        var result: String

        if let title = title {
            let titleStr = " \(title) "
            let remainingWidth = totalWidth - titleStr.count

            switch titleAlignment {
            case .left:
                result = titleStr + String(repeating: character, count: max(0, remainingWidth))
            case .center:
                let leftPad = remainingWidth / 2
                let rightPad = remainingWidth - leftPad
                result = String(repeating: character, count: max(0, leftPad)) + titleStr + String(repeating: character, count: max(0, rightPad))
            case .right:
                result = String(repeating: character, count: max(0, remainingWidth)) + titleStr
            }
        } else {
            result = String(repeating: character, count: totalWidth)
        }

        if let color = color {
            return ANSI.Style.foreground(color) + result + ANSI.Style.reset
        }

        return result
    }

    // MARK: - Preset Dividers

    /// Single line divider.
    public static let single = Divider(character: "─")

    /// Double line divider.
    public static let double = Divider(character: "═")

    /// Heavy line divider.
    public static let heavy = Divider(character: "━")

    /// Dashed divider.
    public static let dashed = Divider(character: "╌")

    /// Dotted divider.
    public static let dotted = Divider(character: "·")

    /// ASCII divider.
    public static let ascii = Divider(character: "-")
}
