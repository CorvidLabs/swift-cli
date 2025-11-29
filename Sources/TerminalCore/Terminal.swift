import ANSI
import Dispatch

#if canImport(Darwin)
import Darwin
#elseif os(Linux)
import Glibc
#endif

/// The central actor for terminal operations.
///
/// `Terminal` provides thread-safe access to terminal capabilities including
/// output, input handling, cursor control, and capability detection.
///
/// ## Usage
///
/// ```swift
/// let terminal = Terminal.shared
/// await terminal.write("Hello, World!\n")
///
/// // Enable raw mode for key-by-key input
/// try await terminal.enableRawMode()
/// defer { Task { try? await terminal.disableRawMode() } }
/// ```
public actor Terminal {
    /// The shared terminal instance for standard I/O.
    public static let shared = Terminal()

    /// Terminal capabilities detected at initialization.
    public let capabilities: TerminalCapabilities

    /// Configuration for this terminal instance.
    public let configuration: TerminalConfiguration

    /// Current terminal size.
    public private(set) var size: TerminalSize

    /// Whether the terminal is currently in raw mode.
    public private(set) var isRawMode: Bool = false

    /// Input file descriptor (stdin)
    private let inputFD: Int32

    /// Output file descriptor (stdout)
    private let outputFD: Int32

    /// Error file descriptor (stderr)
    private let errorFD: Int32

    /// Saved terminal settings for restoration
    #if canImport(Darwin) || os(Linux)
    private var savedTermios: termios?
    #endif

    /// Output buffer for batching writes (array-based for O(1) append)
    private var outputBufferChunks: [String] = []

    /// Whether output buffering is enabled
    private var isBuffering: Bool = false

    /// Signal source for SIGWINCH (terminal resize)
    private var resizeSignalSource: DispatchSourceSignal?

    /// Whether a resize event has occurred
    public private(set) var resizeOccurred: Bool = false

    // MARK: - Initialization

    /// Create a new terminal instance with default configuration.
    public init() {
        self.inputFD = STDIN_FILENO
        self.outputFD = STDOUT_FILENO
        self.errorFD = STDERR_FILENO
        self.configuration = .default
        self.capabilities = TerminalCapabilities.detect()
        self.size = TerminalSize.detect(fd: outputFD)
    }

    /// Create a terminal instance with custom configuration.
    public init(configuration: TerminalConfiguration) {
        self.inputFD = STDIN_FILENO
        self.outputFD = STDOUT_FILENO
        self.errorFD = STDERR_FILENO
        self.configuration = configuration
        self.capabilities = TerminalCapabilities.detect()
        self.size = TerminalSize.detect(fd: outputFD)
    }

    /// Create a terminal instance with custom file descriptors.
    public init(input: Int32, output: Int32, error: Int32, configuration: TerminalConfiguration = .default) {
        self.inputFD = input
        self.outputFD = output
        self.errorFD = error
        self.configuration = configuration
        self.capabilities = TerminalCapabilities.detect()
        self.size = TerminalSize.detect(fd: output)
    }

    // MARK: - Output

    /// Write a string to the terminal.
    public func write(_ string: String) {
        if isBuffering {
            outputBufferChunks.append(string)
        } else {
            writeToFD(string)
        }
    }

    /// Write a string followed by a newline.
    public func writeLine(_ string: String = "") {
        write(string + "\n")
    }

    /// Write to stderr.
    public func writeError(_ string: String) {
        let data = Array(string.utf8)
        _ = data.withUnsafeBytes { buffer in
            #if canImport(Darwin)
            Darwin.write(errorFD, buffer.baseAddress, buffer.count)
            #elseif os(Linux)
            Glibc.write(errorFD, buffer.baseAddress, buffer.count)
            #endif
        }
    }

    /// Flush any buffered output.
    public func flush() {
        if !outputBufferChunks.isEmpty {
            writeToFD(outputBufferChunks.joined())
            outputBufferChunks.removeAll(keepingCapacity: true)
        }
    }

    /// Begin buffering output (for batch updates).
    public func beginBuffering() {
        isBuffering = true
        // Send synchronized update start if supported
        if capabilities.supportsSynchronizedOutput {
            writeToFD(ANSI.Report.beginSynchronizedUpdate)
        }
    }

    /// End buffering and flush all output.
    public func endBuffering() {
        flush()
        isBuffering = false
        // Send synchronized update end if supported
        if capabilities.supportsSynchronizedOutput {
            writeToFD(ANSI.Report.endSynchronizedUpdate)
        }
    }

    /// Execute a block with buffered output.
    public func buffered(_ block: () -> Void) {
        beginBuffering()
        block()
        endBuffering()
    }

    private func writeToFD(_ string: String) {
        let data = Array(string.utf8)
        _ = data.withUnsafeBytes { buffer in
            #if canImport(Darwin)
            Darwin.write(outputFD, buffer.baseAddress, buffer.count)
            #elseif os(Linux)
            Glibc.write(outputFD, buffer.baseAddress, buffer.count)
            #endif
        }
    }

    // MARK: - Terminal Size

    /// Refresh the terminal size.
    @discardableResult
    public func refreshSize() -> TerminalSize {
        size = TerminalSize.detect(fd: outputFD)
        return size
    }

    // MARK: - Cursor Control

    /// Move cursor to position (1-based row and column).
    public func moveCursor(row: Int, column: Int) {
        write(ANSI.Cursor.position(row: row, column: column))
    }

    /// Move cursor to home position (1, 1).
    public func moveCursorHome() {
        write(ANSI.Cursor.home)
    }

    /// Hide the cursor.
    public func hideCursor() {
        write(ANSI.Cursor.hide)
    }

    /// Show the cursor.
    public func showCursor() {
        write(ANSI.Cursor.show)
    }

    /// Save cursor position.
    public func saveCursor() {
        write(ANSI.Cursor.save)
    }

    /// Restore cursor position.
    public func restoreCursor() {
        write(ANSI.Cursor.restore)
    }

    // MARK: - Screen Control

    /// Clear the entire screen.
    public func clearScreen() {
        write(ANSI.Erase.screen)
        moveCursorHome()
    }

    /// Clear from cursor to end of screen.
    public func clearToEndOfScreen() {
        write(ANSI.Erase.screenFromCursor)
    }

    /// Clear the current line.
    public func clearLine() {
        write(ANSI.Erase.line)
    }

    /// Clear from cursor to end of line.
    public func clearToEndOfLine() {
        write(ANSI.Erase.lineFromCursor)
    }

    /// Enter alternate screen buffer.
    public func enterAlternateScreen() {
        write(ANSI.Screen.enterAlternate)
    }

    /// Exit alternate screen buffer.
    public func exitAlternateScreen() {
        write(ANSI.Screen.exitAlternate)
    }

    /// Set terminal window title.
    public func setTitle(_ title: String) {
        write(ANSI.Screen.title(title))
    }

    // MARK: - Raw Mode

    #if canImport(Darwin) || os(Linux)
    /// Enable raw mode for character-by-character input.
    ///
    /// In raw mode:
    /// - Input is not line-buffered
    /// - Echo is disabled
    /// - Ctrl+C doesn't generate SIGINT
    /// - Special processing of input is disabled
    ///
    /// Call `disableRawMode()` to restore normal terminal behavior.
    public func enableRawMode() throws {
        guard !isRawMode else { return }

        var raw = termios()
        guard tcgetattr(inputFD, &raw) == 0 else {
            throw TerminalError.rawModeFailure("Failed to get terminal attributes")
        }

        // Save original settings
        savedTermios = raw

        // Input modes: disable break, CR to NL, parity check, strip, and XON/XOFF
        #if canImport(Darwin)
        raw.c_iflag &= ~UInt(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
        // Output modes: keep OPOST enabled for proper newline handling (\n -> \r\n)
        // Control modes: set 8-bit chars
        raw.c_cflag |= UInt(CS8)
        // Local modes: disable echo, canonical mode, extended input, and signals
        raw.c_lflag &= ~UInt(ECHO | ICANON | IEXTEN | ISIG)
        // Control characters - access c_cc tuple elements safely
        withUnsafeMutableBytes(of: &raw.c_cc) { ptr in
            ptr[Int(VMIN)] = 0   // Return after 0 bytes
            ptr[Int(VTIME)] = 1  // 100ms timeout
        }
        #else
        raw.c_iflag &= ~UInt32(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
        // Output modes: keep OPOST enabled for proper newline handling (\n -> \r\n)
        raw.c_cflag |= UInt32(CS8)
        raw.c_lflag &= ~UInt32(ECHO | ICANON | IEXTEN | ISIG)
        raw.c_cc.6 = 0   // VMIN
        raw.c_cc.5 = 1   // VTIME
        #endif

        guard tcsetattr(inputFD, TCSAFLUSH, &raw) == 0 else {
            throw TerminalError.rawModeFailure("Failed to set terminal attributes")
        }

        isRawMode = true
    }

    /// Disable raw mode and restore original terminal settings.
    public func disableRawMode() throws {
        guard isRawMode, var original = savedTermios else { return }

        guard tcsetattr(inputFD, TCSAFLUSH, &original) == 0 else {
            throw TerminalError.rawModeFailure("Failed to restore terminal attributes")
        }

        isRawMode = false
        savedTermios = nil
    }
    #endif

    // MARK: - Input

    /// Wait for input to be available using poll(2).
    /// Returns true if input is available, false on timeout.
    /// This is much faster than polling with sleep loops.
    public func waitForInput(timeoutMs: Int) -> Bool {
        var pfd = pollfd(fd: inputFD, events: Int16(POLLIN), revents: 0)
        let result = poll(&pfd, 1, Int32(timeoutMs))
        return result > 0 && (pfd.revents & Int16(POLLIN)) != 0
    }

    /// Check if input is immediately available (non-blocking).
    public func hasInput() -> Bool {
        waitForInput(timeoutMs: 0)
    }

    /// Read a single byte from input (requires raw mode).
    public func readByte() throws -> UInt8? {
        var byte: UInt8 = 0
        #if canImport(Darwin)
        let result = Darwin.read(inputFD, &byte, 1)
        #elseif os(Linux)
        let result = Glibc.read(inputFD, &byte, 1)
        #endif
        if result == 0 {
            return nil  // EOF
        } else if result < 0 {
            if errno == EAGAIN || errno == EWOULDBLOCK {
                return nil  // No data available
            }
            throw TerminalError.inputError("Read failed: \(String(cString: strerror(errno)))")
        }
        return byte
    }

    /// Read bytes from input with timeout (requires raw mode).
    public func readBytes(count: Int, timeout: Int = 100) throws -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(count)

        for _ in 0..<count {
            if let byte = try readByte() {
                bytes.append(byte)
            } else {
                break
            }
        }

        return bytes
    }

    // MARK: - Mouse

    /// Enable mouse tracking.
    public func enableMouse(mode: ANSI.Screen.MouseMode = .normal) {
        write(ANSI.Screen.enableMouse(mode))
        write(ANSI.Screen.enableSGRMouse)
    }

    /// Disable mouse tracking.
    public func disableMouse() {
        write(ANSI.Screen.disableMouse)
        write(ANSI.Screen.disableSGRMouse)
    }

    // MARK: - Cleanup

    /// Reset terminal to a clean state.
    public func reset() {
        // Show cursor
        showCursor()

        // Reset colors and styles
        write(ANSI.Style.reset)

        // Disable mouse if enabled
        disableMouse()

        // Exit alternate screen if in it
        exitAlternateScreen()

        // Disable raw mode if enabled
        #if canImport(Darwin) || os(Linux)
        try? disableRawMode()
        #endif

        // Stop resize monitoring
        stopResizeMonitoring()

        flush()
    }

    // MARK: - Resize Monitoring

    /// Start monitoring for terminal resize events (SIGWINCH).
    public func startResizeMonitoring() {
        guard resizeSignalSource == nil else { return }

        #if canImport(Darwin) || os(Linux)
        // Ignore default SIGWINCH handling
        signal(SIGWINCH, SIG_IGN)

        // Create dispatch source for SIGWINCH
        let source = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
        source.setEventHandler {
            // Set a flag that can be checked in the event loop
            // We can't safely call actor methods from here, so we just
            // trigger the flag synchronously. The event loop will check it.
            Task { @MainActor in
                await Terminal.shared.handleResize()
            }
        }
        source.resume()
        resizeSignalSource = source
        #endif
    }

    /// Stop monitoring for terminal resize events.
    public func stopResizeMonitoring() {
        resizeSignalSource?.cancel()
        resizeSignalSource = nil
    }

    /// Handle a resize event.
    private func handleResize() {
        size = TerminalSize.detect(fd: outputFD)
        resizeOccurred = true
    }

    /// Check and clear the resize flag.
    /// Returns true if a resize occurred since last check.
    public func checkResize() -> Bool {
        let didResize = resizeOccurred
        resizeOccurred = false
        return didResize
    }
}
