import ANSI
import Foundation
import TerminalCore  // Also provides debugLog()
import TerminalStyle
import TerminalInput

/// Protocol for terminal applications.
public protocol App: Sendable {
    /// The type of view representing the body of this app.
    associatedtype Body: View

    /// The content and behavior of the app.
    @ViewBuilder var body: Body { get }

    /// Called when the app starts.
    func onAppear() async

    /// Called periodically at the update interval.
    func onUpdate() async

    /// Called when a key is pressed.
    func onKeyPress(_ key: KeyCode) async -> Bool

    /// Called when the terminal is resized.
    func onResize(size: TerminalSize) async

    /// The interval between automatic updates (in seconds). Set to 0 to disable.
    var updateInterval: TimeInterval { get }

    /// Create an instance of the app.
    init()
}

extension App {
    /// Default implementation - do nothing on appear.
    public func onAppear() async {}

    /// Default implementation - do nothing on update.
    public func onUpdate() async {}

    /// Default implementation - return false to not handle.
    public func onKeyPress(_ key: KeyCode) async -> Bool {
        false
    }

    /// Default implementation - do nothing on resize.
    public func onResize(size: TerminalSize) async {}

    /// Default update interval - 1 second. Set to 0 to disable updates.
    public var updateInterval: TimeInterval { 1.0 }
}

/// Run a terminal app.
public func runApp<A: App>(_ app: A) async throws {
    debugLog("runApp: Starting \(type(of: app))")
    let terminal = Terminal.shared
    let renderer = DifferentialRenderer(terminal: terminal)

    // Setup
    debugLog("runApp: Entering alternate screen")
    await terminal.enterAlternateScreen()
    debugLog("runApp: Hiding cursor")
    await terminal.hideCursor()
    debugLog("runApp: Enabling raw mode")
    try await terminal.enableRawMode()
    debugLog("runApp: Starting resize monitoring")
    await terminal.startResizeMonitoring()

    // Initial render (force refresh size for first render)
    debugLog("runApp: Initial render")
    let initialSize = await terminal.refreshSize()
    await renderer.render(app.body, size: Size(width: initialSize.columns, height: initialSize.rows))
    debugLog("runApp: Initial render complete")

    // Notify app started
    debugLog("runApp: Calling onAppear")
    await app.onAppear()
    debugLog("runApp: onAppear complete, entering event loop")

    // Track last update time
    var lastUpdate = Date()
    var loopCount = 0

    // Event loop with short poll timeout for responsiveness
    while true {
        loopCount += 1
        debugLog("eventLoop[\(loopCount)]: waiting for input (16ms timeout)")

        // Always use short timeout for responsive input (16ms ≈ 60fps)
        if let key = try await terminal.readKeyWithTimeout(milliseconds: 16) {
            debugLog("eventLoop[\(loopCount)]: got key \(key)")
            let handled = await app.onKeyPress(key)
            if !handled && (key.isInterrupt || key == .character("q") || key == .escape) {
                debugLog("eventLoop[\(loopCount)]: quit key detected, breaking")
                break
            }
        }

        // Check for terminal resize
        if await terminal.checkResize() {
            debugLog("eventLoop[\(loopCount)]: resize detected")
            let newSize = await terminal.size
            await app.onResize(size: newSize)
            await renderer.invalidate()
        }

        // Check if it's time for a periodic update
        if app.updateInterval > 0 {
            let timeSinceUpdate = Date().timeIntervalSince(lastUpdate)
            if timeSinceUpdate >= app.updateInterval {
                debugLog("eventLoop[\(loopCount)]: TIMER FIRED - calling onUpdate")
                await app.onUpdate()
                lastUpdate = Date()
            }
        }

        // Always render - DifferentialRenderer handles diffing so unchanged frames are cheap
        let size = await terminal.size
        await renderer.render(app.body, size: Size(width: size.columns, height: size.rows))
    }

    // Cleanup (awaited to ensure terminal is restored before exit)
    debugLog("runApp: Cleaning up")
    await terminal.stopResizeMonitoring()
    try? await terminal.disableRawMode()
    await terminal.showCursor()
    await terminal.exitAlternateScreen()
    debugLog("runApp: Cleanup complete")
}

