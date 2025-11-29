import Foundation

/// OSC 8 Hyperlink support
extension ANSI {
    /// Hyperlink (OSC 8) sequences
    public enum Hyperlink: Sendable {
        /// Create a hyperlink
        /// - Parameters:
        ///   - url: The URL to link to
        ///   - text: The visible text
        ///   - id: Optional ID for grouping multiple links
        /// - Returns: The complete hyperlink sequence with text
        public static func link(url: String, text: String, id: String? = nil) -> String {
            let params = id.map { "id=\($0)" } ?? ""
            return "\(ANSI.OSC)8;\(params);\(url)\(ANSI.BEL)\(text)\(ANSI.OSC)8;;\(ANSI.BEL)"
        }

        /// Create a hyperlink using URL type
        @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
        public static func link(url: URL, text: String, id: String? = nil) -> String {
            link(url: url.absoluteString, text: text, id: id)
        }

        /// Start a hyperlink (use with `end` to wrap content)
        public static func start(url: String, id: String? = nil) -> String {
            let params = id.map { "id=\($0)" } ?? ""
            return "\(ANSI.OSC)8;\(params);\(url)\(ANSI.BEL)"
        }

        /// End a hyperlink
        public static let end: String = "\(ANSI.OSC)8;;\(ANSI.BEL)"

        /// Create a file:// hyperlink
        public static func file(path: String, text: String, id: String? = nil) -> String {
            let urlString = "file://\(path)"
            return link(url: urlString, text: text, id: id)
        }
    }
}
