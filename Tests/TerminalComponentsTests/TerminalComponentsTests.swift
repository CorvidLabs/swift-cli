import Testing
@testable import TerminalComponents

@Suite("TerminalComponents")
struct TerminalComponentsTests {
    @Test("ProgressBar.Style presets exist")
    func progressBarStyles() {
        let blocks = ProgressBar.Style.blocks
        #expect(blocks.filled == "█")
        #expect(blocks.empty == "░")

        let classic = ProgressBar.Style.classic
        #expect(classic.filled == "=")
        #expect(classic.empty == "-")
    }

    @Test("Spinner.Style presets have frames")
    func spinnerStyles() {
        #expect(!Spinner.Style.dots.frames.isEmpty)
        #expect(!Spinner.Style.line.frames.isEmpty)
        #expect(!Spinner.Style.circle.frames.isEmpty)
        #expect(!Spinner.Style.arc.frames.isEmpty)
    }

    @Test("Spinner.Style dots has correct frames")
    func spinnerDotsFrames() {
        let dots = Spinner.Style.dots
        #expect(dots.frames.count == 10)
        #expect(dots.frames.first == "⠋")
    }
}
