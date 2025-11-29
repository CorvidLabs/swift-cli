import Testing
@testable import TerminalCore

@Suite("TerminalCore")
struct TerminalCoreTests {
    @Test("TerminalSize has correct defaults")
    func terminalSizeDefaults() {
        let size = TerminalSize.default
        #expect(size.columns == 80)
        #expect(size.rows == 24)
    }

    @Test("TerminalSize properties work correctly")
    func terminalSizeProperties() {
        let size = TerminalSize(columns: 100, rows: 50)
        #expect(size.width == 100)
        #expect(size.height == 50)
        #expect(size.area == 5000)
    }

    @Test("TerminalConfiguration has sensible defaults")
    func configurationDefaults() {
        let config = TerminalConfiguration.default
        #expect(config.colorMode == .auto)
        #expect(config.forceColor == false)
        #expect(config.useUnicode == true)
    }

    @Test("TerminalError descriptions are meaningful")
    func errorDescriptions() {
        let error = TerminalError.rawModeFailure("test error")
        #expect(error.errorDescription?.contains("test error") == true)

        let timeout = TerminalError.timeout
        #expect(timeout.errorDescription?.contains("timed out") == true)
    }

    @Test("TerminalCapabilities detects color depth")
    func capabilitiesColorDepth() {
        // This test verifies the capability detection runs without crashing
        let caps = TerminalCapabilities.detect()
        #expect(caps.colorDepth.rawValue >= 0)
    }
}
