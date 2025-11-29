import ANSI

/// Style for box borders.
public struct BoxStyle: Sendable {
    public let topLeft: Character
    public let topRight: Character
    public let bottomLeft: Character
    public let bottomRight: Character
    public let horizontal: Character
    public let vertical: Character
    public let verticalLeft: Character
    public let verticalRight: Character
    public let horizontalUp: Character
    public let horizontalDown: Character
    public let cross: Character

    public init(
        topLeft: Character,
        topRight: Character,
        bottomLeft: Character,
        bottomRight: Character,
        horizontal: Character,
        vertical: Character,
        verticalLeft: Character,
        verticalRight: Character,
        horizontalUp: Character,
        horizontalDown: Character,
        cross: Character
    ) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.horizontal = horizontal
        self.vertical = vertical
        self.verticalLeft = verticalLeft
        self.verticalRight = verticalRight
        self.horizontalUp = horizontalUp
        self.horizontalDown = horizontalDown
        self.cross = cross
    }

    // MARK: - Preset Styles

    /// Single line border.
    public static let single = BoxStyle(
        topLeft: ANSI.Box.Single.topLeft,
        topRight: ANSI.Box.Single.topRight,
        bottomLeft: ANSI.Box.Single.bottomLeft,
        bottomRight: ANSI.Box.Single.bottomRight,
        horizontal: ANSI.Box.Single.horizontal,
        vertical: ANSI.Box.Single.vertical,
        verticalLeft: ANSI.Box.Single.verticalLeft,
        verticalRight: ANSI.Box.Single.verticalRight,
        horizontalUp: ANSI.Box.Single.horizontalUp,
        horizontalDown: ANSI.Box.Single.horizontalDown,
        cross: ANSI.Box.Single.cross
    )

    /// Double line border.
    public static let double = BoxStyle(
        topLeft: ANSI.Box.Double.topLeft,
        topRight: ANSI.Box.Double.topRight,
        bottomLeft: ANSI.Box.Double.bottomLeft,
        bottomRight: ANSI.Box.Double.bottomRight,
        horizontal: ANSI.Box.Double.horizontal,
        vertical: ANSI.Box.Double.vertical,
        verticalLeft: ANSI.Box.Double.verticalLeft,
        verticalRight: ANSI.Box.Double.verticalRight,
        horizontalUp: ANSI.Box.Double.horizontalUp,
        horizontalDown: ANSI.Box.Double.horizontalDown,
        cross: ANSI.Box.Double.cross
    )

    /// Rounded corners.
    public static let rounded = BoxStyle(
        topLeft: ANSI.Box.Rounded.topLeft,
        topRight: ANSI.Box.Rounded.topRight,
        bottomLeft: ANSI.Box.Rounded.bottomLeft,
        bottomRight: ANSI.Box.Rounded.bottomRight,
        horizontal: ANSI.Box.Rounded.horizontal,
        vertical: ANSI.Box.Rounded.vertical,
        verticalLeft: ANSI.Box.Rounded.verticalLeft,
        verticalRight: ANSI.Box.Rounded.verticalRight,
        horizontalUp: ANSI.Box.Rounded.horizontalUp,
        horizontalDown: ANSI.Box.Rounded.horizontalDown,
        cross: ANSI.Box.Rounded.cross
    )

    /// Heavy/bold border.
    public static let heavy = BoxStyle(
        topLeft: ANSI.Box.Heavy.topLeft,
        topRight: ANSI.Box.Heavy.topRight,
        bottomLeft: ANSI.Box.Heavy.bottomLeft,
        bottomRight: ANSI.Box.Heavy.bottomRight,
        horizontal: ANSI.Box.Heavy.horizontal,
        vertical: ANSI.Box.Heavy.vertical,
        verticalLeft: ANSI.Box.Heavy.verticalLeft,
        verticalRight: ANSI.Box.Heavy.verticalRight,
        horizontalUp: ANSI.Box.Heavy.horizontalUp,
        horizontalDown: ANSI.Box.Heavy.horizontalDown,
        cross: ANSI.Box.Heavy.cross
    )

    /// ASCII fallback.
    public static let ascii = BoxStyle(
        topLeft: ANSI.Box.ASCII.topLeft,
        topRight: ANSI.Box.ASCII.topRight,
        bottomLeft: ANSI.Box.ASCII.bottomLeft,
        bottomRight: ANSI.Box.ASCII.bottomRight,
        horizontal: ANSI.Box.ASCII.horizontal,
        vertical: ANSI.Box.ASCII.vertical,
        verticalLeft: ANSI.Box.ASCII.verticalLeft,
        verticalRight: ANSI.Box.ASCII.verticalRight,
        horizontalUp: ANSI.Box.ASCII.horizontalUp,
        horizontalDown: ANSI.Box.ASCII.horizontalDown,
        cross: ANSI.Box.ASCII.cross
    )

    /// No border (spaces).
    public static let none = BoxStyle(
        topLeft: " ",
        topRight: " ",
        bottomLeft: " ",
        bottomRight: " ",
        horizontal: " ",
        vertical: " ",
        verticalLeft: " ",
        verticalRight: " ",
        horizontalUp: " ",
        horizontalDown: " ",
        cross: " "
    )
}
