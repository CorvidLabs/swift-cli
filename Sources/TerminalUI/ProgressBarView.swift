import Foundation

/// A progress bar view that displays completion percentage.
public struct ProgressBarView: View, Sendable {
    public let progress: Double
    public let width: Int
    public let style: ProgressStyle
    public let showPercentage: Bool

    public enum ProgressStyle: Sendable {
        case block
        case smooth
        case ascii
        case minimal

        var filled: String {
            switch self {
            case .block: return "█"
            case .smooth: return "━"
            case .ascii: return "="
            case .minimal: return "■"
            }
        }

        var empty: String {
            switch self {
            case .block: return "░"
            case .smooth: return "─"
            case .ascii: return "-"
            case .minimal: return "□"
            }
        }

        var leftCap: String {
            switch self {
            case .block, .smooth, .minimal: return ""
            case .ascii: return "["
            }
        }

        var rightCap: String {
            switch self {
            case .block, .smooth, .minimal: return ""
            case .ascii: return "]"
            }
        }
    }

    public init(
        progress: Double,
        width: Int = 20,
        style: ProgressStyle = .block,
        showPercentage: Bool = true
    ) {
        self.progress = max(0, min(1, progress))
        self.width = width
        self.style = style
        self.showPercentage = showPercentage
    }

    public var body: some View {
        let barWidth = style.leftCap.isEmpty ? width : width - 2
        let filledCount = Int(Double(barWidth) * progress)
        let emptyCount = barWidth - filledCount

        let filledPart = String(repeating: style.filled, count: filledCount)
        let emptyPart = String(repeating: style.empty, count: emptyCount)

        let bar = style.leftCap + filledPart + emptyPart + style.rightCap

        if showPercentage {
            let percent = Int(progress * 100)
            Text("\(bar) \(percent)%")
        } else {
            Text(bar)
        }
    }
}

/// A progress bar with a label.
public struct LabeledProgressBar: View, Sendable {
    public let label: String
    public let progress: Double
    public let width: Int
    public let style: ProgressBarView.ProgressStyle

    public init(
        label: String,
        progress: Double,
        width: Int = 20,
        style: ProgressBarView.ProgressStyle = .block
    ) {
        self.label = label
        self.progress = progress
        self.width = width
        self.style = style
    }

    public var body: some View {
        HStack {
            Text(label)
            ProgressBarView(progress: progress, width: width, style: style)
        }
    }
}
