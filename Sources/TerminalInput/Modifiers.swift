/// Keyboard modifiers.
public struct Modifiers: OptionSet, Sendable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Shift key.
    public static let shift = Modifiers(rawValue: 1 << 0)

    /// Alt/Option key.
    public static let alt = Modifiers(rawValue: 1 << 1)

    /// Control key.
    public static let control = Modifiers(rawValue: 1 << 2)

    /// Meta/Command key.
    public static let meta = Modifiers(rawValue: 1 << 3)

    /// No modifiers.
    public static let none: Modifiers = []

    /// All modifiers.
    public static let all: Modifiers = [.shift, .alt, .control, .meta]
}

extension Modifiers: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        if contains(.meta) { parts.append("Meta") }
        if contains(.control) { parts.append("Ctrl") }
        if contains(.alt) { parts.append("Alt") }
        if contains(.shift) { parts.append("Shift") }
        return parts.isEmpty ? "None" : parts.joined(separator: "+")
    }
}
