#if canImport(Darwin)
import Darwin
#elseif os(Linux)
import Glibc
#endif

/// Terminal dimensions.
public struct TerminalSize: Sendable, Equatable {
    /// Number of columns (width in characters).
    public let columns: Int

    /// Number of rows (height in characters).
    public let rows: Int

    /// Pixel width (if available).
    public let pixelWidth: Int?

    /// Pixel height (if available).
    public let pixelHeight: Int?

    /// Default terminal size (80x24).
    public static let `default` = TerminalSize(columns: 80, rows: 24)

    /// Create a terminal size.
    public init(columns: Int, rows: Int, pixelWidth: Int? = nil, pixelHeight: Int? = nil) {
        self.columns = max(1, columns)
        self.rows = max(1, rows)
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }

    /// Detect terminal size from file descriptor.
    public static func detect(fd: Int32 = STDOUT_FILENO) -> TerminalSize {
        #if canImport(Darwin) || os(Linux)
        var ws = winsize()
        if ioctl(fd, TIOCGWINSZ, &ws) == 0 {
            return TerminalSize(
                columns: Int(ws.ws_col),
                rows: Int(ws.ws_row),
                pixelWidth: ws.ws_xpixel > 0 ? Int(ws.ws_xpixel) : nil,
                pixelHeight: ws.ws_ypixel > 0 ? Int(ws.ws_ypixel) : nil
            )
        }
        #endif

        // Try environment variables as fallback
        let env = ProcessInfo.processInfo.environment
        let columns = env["COLUMNS"].flatMap(Int.init) ?? 80
        let rows = env["LINES"].flatMap(Int.init) ?? 24

        return TerminalSize(columns: columns, rows: rows)
    }

    /// Width in characters.
    public var width: Int { columns }

    /// Height in characters.
    public var height: Int { rows }

    /// Total character cells.
    public var area: Int { columns * rows }
}

import Foundation
