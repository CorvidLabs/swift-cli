import Foundation

/// Simple file logger for debugging crashes.
/// Logs are written synchronously to ensure they persist before crashes.
/// No initialization required - just call `debugLog("message")` anywhere.
public func debugLog(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
    let logDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".swift-cli/logs")
    let logFile = logDir.appendingPathComponent("debug.log")

    // Create directory if needed
    try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)

    let timestamp = ISO8601DateFormatter().string(from: Date())
    let fileName = (file as NSString).lastPathComponent
    let entry = "[\(timestamp)] [\(fileName):\(line)] \(function): \(message)\n"

    if let data = entry.data(using: .utf8) {
        if let handle = try? FileHandle(forWritingTo: logFile) {
            handle.seekToEndOfFile()
            handle.write(data)
            try? handle.synchronize()  // Force flush to disk - survives crashes
            try? handle.close()
        } else {
            try? data.write(to: logFile)
        }
    }
}
