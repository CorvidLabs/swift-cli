/// Terminal query and report sequences
extension ANSI {
    /// Device status and capability query sequences
    public enum Report: Sendable {
        // MARK: - Device Status

        /// Request cursor position report (response: ESC[row;colR)
        public static let cursorPosition: String = "\(ANSI.CSI)6n"

        /// Request device status (response: ESC[0n if OK)
        public static let deviceStatus: String = "\(ANSI.CSI)5n"

        /// Request terminal identification
        public static let terminalId: String = "\(ANSI.CSI)0c"

        /// Request secondary device attributes
        public static let secondaryDeviceAttributes: String = "\(ANSI.CSI)>0c"

        /// Request tertiary device attributes
        public static let tertiaryDeviceAttributes: String = "\(ANSI.CSI)=0c"

        // MARK: - Terminal Size

        /// Save cursor, move to bottom-right, request position, restore
        /// This is a common technique to determine terminal size
        public static let querySize: String =
            "\(ANSI.Cursor.save)\(ANSI.CSI)9999;9999H\(ANSI.CSI)6n\(ANSI.Cursor.restore)"

        // MARK: - Color Queries

        /// Query foreground color
        public static let queryForeground: String = "\(ANSI.OSC)10;?\(ANSI.BEL)"

        /// Query background color
        public static let queryBackground: String = "\(ANSI.OSC)11;?\(ANSI.BEL)"

        /// Query cursor color
        public static let queryCursorColor: String = "\(ANSI.OSC)12;?\(ANSI.BEL)"

        // MARK: - Synchronized Output

        /// Begin synchronized update (batch rendering)
        public static let beginSynchronizedUpdate: String = "\(ANSI.CSI)?2026h"

        /// End synchronized update
        public static let endSynchronizedUpdate: String = "\(ANSI.CSI)?2026l"
    }
}
