import ANSI

/// Text gradient effects.
public struct Gradient: Sendable {
    /// Start color.
    public let start: ANSI.TrueColor

    /// End color.
    public let end: ANSI.TrueColor

    /// Create a gradient between two colors.
    public init(from start: ANSI.TrueColor, to end: ANSI.TrueColor) {
        self.start = start
        self.end = end
    }

    /// Interpolate a color at position t (0.0 to 1.0).
    public func color(at t: Double) -> ANSI.TrueColor {
        let t = max(0, min(1, t))
        let r = UInt8(Double(start.red) + (Double(end.red) - Double(start.red)) * t)
        let g = UInt8(Double(start.green) + (Double(end.green) - Double(start.green)) * t)
        let b = UInt8(Double(start.blue) + (Double(end.blue) - Double(start.blue)) * t)
        return ANSI.TrueColor(r: r, g: g, b: b)
    }

    /// Apply gradient to text (each character gets a color).
    public func apply(to text: String) -> String {
        let chars = Array(text)
        guard chars.count > 1 else {
            return ANSI.Style.foreground(start) + text + ANSI.Style.reset
        }

        var result = ""
        for (index, char) in chars.enumerated() {
            let t = Double(index) / Double(chars.count - 1)
            let color = color(at: t)
            result += ANSI.Style.foreground(color)
            result += String(char)
        }
        result += ANSI.Style.reset

        return result
    }

    // MARK: - Preset Gradients

    /// Rainbow gradient.
    public static let rainbow = Gradient(
        from: ANSI.TrueColor(r: 255, g: 0, b: 0),
        to: ANSI.TrueColor(r: 128, g: 0, b: 255)
    )

    /// Sunset gradient.
    public static let sunset = Gradient(
        from: ANSI.TrueColor(r: 255, g: 100, b: 50),
        to: ANSI.TrueColor(r: 180, g: 50, b: 150)
    )

    /// Ocean gradient.
    public static let ocean = Gradient(
        from: ANSI.TrueColor(r: 0, g: 150, b: 255),
        to: ANSI.TrueColor(r: 0, g: 50, b: 150)
    )

    /// Forest gradient.
    public static let forest = Gradient(
        from: ANSI.TrueColor(r: 50, g: 200, b: 50),
        to: ANSI.TrueColor(r: 0, g: 100, b: 50)
    )

    /// Fire gradient.
    public static let fire = Gradient(
        from: ANSI.TrueColor(r: 255, g: 255, b: 0),
        to: ANSI.TrueColor(r: 255, g: 0, b: 0)
    )

    /// Ice gradient.
    public static let ice = Gradient(
        from: ANSI.TrueColor(r: 200, g: 240, b: 255),
        to: ANSI.TrueColor(r: 50, g: 100, b: 200)
    )
}

/// Multi-stop gradient.
public struct MultiGradient: Sendable {
    /// Color stops.
    public let stops: [(position: Double, color: ANSI.TrueColor)]

    /// Create a multi-stop gradient.
    public init(stops: [(position: Double, color: ANSI.TrueColor)]) {
        self.stops = stops.sorted { $0.position < $1.position }
    }

    /// Create from an array of colors (evenly distributed).
    public init(colors: [ANSI.TrueColor]) {
        guard colors.count > 1 else {
            self.stops = colors.isEmpty ? [] : [(0, colors[0])]
            return
        }

        var stops: [(position: Double, color: ANSI.TrueColor)] = []
        for (index, color) in colors.enumerated() {
            let position = Double(index) / Double(colors.count - 1)
            stops.append((position, color))
        }
        self.stops = stops
    }

    /// Interpolate a color at position t (0.0 to 1.0).
    public func color(at t: Double) -> ANSI.TrueColor {
        let t = max(0, min(1, t))

        guard stops.count > 1 else {
            return stops.first?.color ?? ANSI.TrueColor.white
        }

        // Find the two stops we're between
        var lowerIndex = 0
        for i in 0..<stops.count {
            if stops[i].position <= t {
                lowerIndex = i
            }
        }

        let upperIndex = min(lowerIndex + 1, stops.count - 1)

        if lowerIndex == upperIndex {
            return stops[lowerIndex].color
        }

        let lower = stops[lowerIndex]
        let upper = stops[upperIndex]
        let localT = (t - lower.position) / (upper.position - lower.position)

        let r = UInt8(Double(lower.color.red) + (Double(upper.color.red) - Double(lower.color.red)) * localT)
        let g = UInt8(Double(lower.color.green) + (Double(upper.color.green) - Double(lower.color.green)) * localT)
        let b = UInt8(Double(lower.color.blue) + (Double(upper.color.blue) - Double(lower.color.blue)) * localT)

        return ANSI.TrueColor(r: r, g: g, b: b)
    }

    /// Apply gradient to text.
    public func apply(to text: String) -> String {
        let chars = Array(text)
        guard chars.count > 1 else {
            let color = color(at: 0.5)
            return ANSI.Style.foreground(color) + text + ANSI.Style.reset
        }

        var result = ""
        for (index, char) in chars.enumerated() {
            let t = Double(index) / Double(chars.count - 1)
            let color = color(at: t)
            result += ANSI.Style.foreground(color)
            result += String(char)
        }
        result += ANSI.Style.reset

        return result
    }

    // MARK: - Preset Multi-Gradients

    /// Full rainbow.
    public static let rainbow = MultiGradient(colors: [
        ANSI.TrueColor(r: 255, g: 0, b: 0),     // Red
        ANSI.TrueColor(r: 255, g: 127, b: 0),   // Orange
        ANSI.TrueColor(r: 255, g: 255, b: 0),   // Yellow
        ANSI.TrueColor(r: 0, g: 255, b: 0),     // Green
        ANSI.TrueColor(r: 0, g: 0, b: 255),     // Blue
        ANSI.TrueColor(r: 75, g: 0, b: 130),    // Indigo
        ANSI.TrueColor(r: 148, g: 0, b: 211)    // Violet
    ])

    /// Pastel rainbow.
    public static let pastel = MultiGradient(colors: [
        ANSI.TrueColor(r: 255, g: 179, b: 186), // Pink
        ANSI.TrueColor(r: 255, g: 223, b: 186), // Peach
        ANSI.TrueColor(r: 255, g: 255, b: 186), // Yellow
        ANSI.TrueColor(r: 186, g: 255, b: 201), // Mint
        ANSI.TrueColor(r: 186, g: 225, b: 255)  // Sky
    ])
}

// MARK: - String Extensions

extension String {
    /// Apply a gradient to the text.
    public func gradient(_ gradient: Gradient) -> String {
        gradient.apply(to: self)
    }

    /// Apply a multi-gradient to the text.
    public func gradient(_ gradient: MultiGradient) -> String {
        gradient.apply(to: self)
    }

    /// Apply rainbow gradient.
    public var rainbow: String {
        MultiGradient.rainbow.apply(to: self)
    }
}
