import Foundation

/// Errors that can occur during terminal operations.
public enum TerminalError: Error, Sendable {
    /// Failed to enable or disable raw mode.
    case rawModeFailure(String)

    /// Terminal size could not be determined.
    case sizeDetectionFailure

    /// Input operation failed.
    case inputError(String)

    /// Output operation failed.
    case outputError(String)

    /// The requested capability is not supported.
    case unsupportedCapability(String)

    /// Image encoding failed.
    case imageEncodingError(String)

    /// Invalid escape sequence received.
    case invalidEscapeSequence(String)

    /// Operation timed out.
    case timeout

    /// Platform does not support this operation.
    case platformUnavailable

    /// Terminal is not a TTY.
    case notATTY

    /// Operation was cancelled.
    case cancelled
}

extension TerminalError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .rawModeFailure(let message):
            return "Failed to change terminal mode: \(message)"
        case .sizeDetectionFailure:
            return "Could not determine terminal size"
        case .inputError(let message):
            return "Input error: \(message)"
        case .outputError(let message):
            return "Output error: \(message)"
        case .unsupportedCapability(let capability):
            return "Unsupported capability: \(capability)"
        case .imageEncodingError(let message):
            return "Image encoding error: \(message)"
        case .invalidEscapeSequence(let sequence):
            return "Invalid escape sequence: \(sequence)"
        case .timeout:
            return "Operation timed out"
        case .platformUnavailable:
            return "This operation is not available on this platform"
        case .notATTY:
            return "Terminal is not a TTY"
        case .cancelled:
            return "Operation was cancelled"
        }
    }
}
