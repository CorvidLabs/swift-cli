import Foundation

/// A spinner view that displays an animated loading indicator.
/// Frame is computed from the current timestamp for smooth 80ms animation.
public struct SpinnerView: View, Sendable {
    public let style: SpinnerStyle
    public let message: String
    public let isActive: Bool

    public enum SpinnerStyle: Sendable {
        case dots
        case line
        case bounce
        case arrow
        case pulse

        var frames: [String] {
            switch self {
            case .dots:
                return ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
            case .line:
                return ["|", "/", "-", "\\"]
            case .bounce:
                return ["⠁", "⠂", "⠄", "⠂"]
            case .arrow:
                return ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"]
            case .pulse:
                return ["◐", "◓", "◑", "◒"]
            }
        }

        var interval: TimeInterval {
            switch self {
            case .dots, .bounce, .pulse: return 0.08
            case .line, .arrow: return 0.1
            }
        }
    }

    public init(style: SpinnerStyle = .dots, message: String = "", isActive: Bool = true) {
        self.style = style
        self.message = message
        self.isActive = isActive
    }

    public var body: some View {
        if isActive {
            let frameIndex = currentFrameIndex
            let frame = style.frames[frameIndex]
            if message.isEmpty {
                Text(frame).cyan
            } else {
                Text("\(frame) \(message)").cyan
            }
        } else {
            if message.isEmpty {
                Text(" ")
            } else {
                Text("  \(message)")
            }
        }
    }

    private var currentFrameIndex: Int {
        let now = Date().timeIntervalSince1970
        return Int(now / style.interval) % style.frames.count
    }
}
