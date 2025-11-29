import ANSI
import TerminalStyle

/// A panel with a title and content.
public struct Panel: Renderable, Sendable {
    /// Panel title.
    public let title: StyledText?

    /// Content lines.
    public let content: [StyledText]

    /// Border style.
    public let style: BoxStyle

    /// Padding.
    public let padding: Box.Padding

    /// Title alignment.
    public let titleAlignment: Box.Alignment

    /// Border color.
    public let borderColor: ANSI.Color?

    /// Create a panel.
    public init(
        title: StyledText? = nil,
        content: [StyledText],
        style: BoxStyle = .rounded,
        padding: Box.Padding = .small,
        titleAlignment: Box.Alignment = .left,
        borderColor: ANSI.Color? = nil
    ) {
        self.title = title
        self.content = content
        self.style = style
        self.padding = padding
        self.titleAlignment = titleAlignment
        self.borderColor = borderColor
    }

    /// Create a panel with a result builder.
    public init(
        title: StyledText? = nil,
        style: BoxStyle = .rounded,
        padding: Box.Padding = .small,
        titleAlignment: Box.Alignment = .left,
        borderColor: ANSI.Color? = nil,
        @PanelContentBuilder content: () -> [StyledText]
    ) {
        self.title = title
        self.content = content()
        self.style = style
        self.padding = padding
        self.titleAlignment = titleAlignment
        self.borderColor = borderColor
    }

    /// Render the panel.
    public func render(width: Int? = nil) -> String {
        let box = Box(
            lines: content.map { $0.render() },
            style: style,
            padding: padding,
            title: title?.plainText,
            titleAlignment: titleAlignment,
            borderColor: borderColor
        )
        return box.render(width: width)
    }
}

/// Result builder for panel content.
@resultBuilder
public struct PanelContentBuilder {
    public static func buildBlock(_ components: StyledText...) -> [StyledText] {
        components
    }

    public static func buildExpression(_ expression: String) -> StyledText {
        StyledText(expression)
    }

    public static func buildExpression(_ expression: StyledText) -> StyledText {
        expression
    }

    public static func buildOptional(_ component: [StyledText]?) -> [StyledText] {
        component ?? []
    }

    public static func buildEither(first component: [StyledText]) -> [StyledText] {
        component
    }

    public static func buildEither(second component: [StyledText]) -> [StyledText] {
        component
    }

    public static func buildArray(_ components: [[StyledText]]) -> [StyledText] {
        components.flatMap { $0 }
    }
}
