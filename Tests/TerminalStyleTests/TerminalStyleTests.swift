import Testing
@testable import TerminalStyle
import ANSI

@Suite("TerminalStyle")
struct TerminalStyleTests {
    @Test("StyledText renders with color")
    func styledTextColor() {
        let styled = StyledText("Hello").foreground(.red)
        let rendered = styled.render()
        #expect(rendered.contains("\u{1B}[31m"))
        #expect(rendered.contains("Hello"))
        #expect(rendered.contains("\u{1B}[0m"))
    }

    @Test("StyledText chains styles correctly")
    func styledTextChaining() {
        let styled = StyledText("Test").bold.underline.foreground(.blue)
        #expect(styled.styles.contains(.bold))
        #expect(styled.styles.contains(.underline))
        #expect(styled.foreground == .blue)
    }

    @Test("String extensions create StyledText")
    func stringExtensions() {
        let styled = "Hello".red.bold
        #expect(styled.foreground == .red)
        #expect(styled.styles.contains(.bold))
        #expect(styled.plainText == "Hello")
    }

    @Test("StyledText plainText strips formatting")
    func plainText() {
        let styled = "Test".red.bold.underline
        #expect(styled.plainText == "Test")
        #expect(styled.length == 4)
    }

    @Test("StyledText concatenation works")
    func concatenation() {
        let combined = "Hello ".green + "World".blue
        #expect(combined.plainText == "Hello World")
    }

    @Test("Theme has correct preset colors")
    func themeColors() {
        let theme = Theme.default
        #expect(theme.success == .green)
        #expect(theme.error == .red)
        #expect(theme.warning == .yellow)
    }

    @Test("Gradient interpolates colors correctly")
    func gradientInterpolation() {
        let gradient = Gradient(
            from: ANSI.TrueColor(r: 0, g: 0, b: 0),
            to: ANSI.TrueColor(r: 100, g: 100, b: 100)
        )

        let mid = gradient.color(at: 0.5)
        #expect(mid.red == 50)
        #expect(mid.green == 50)
        #expect(mid.blue == 50)
    }
}
