import Testing
@testable import ANSI

@Suite("ANSI Escape Codes")
struct ANSITests {
    @Test("CSI cursor up generates correct sequence")
    func cursorUp() {
        #expect(ANSI.Cursor.up(5) == "\u{1B}[5A")
        #expect(ANSI.Cursor.up() == "\u{1B}[1A")
    }

    @Test("CSI cursor position generates correct sequence")
    func cursorPosition() {
        #expect(ANSI.Cursor.position(row: 10, column: 20) == "\u{1B}[10;20H")
    }

    @Test("SGR foreground colors generate correct sequences")
    func foregroundColors() {
        #expect(ANSI.Style.foreground(ANSI.Color.red) == "\u{1B}[31m")
        #expect(ANSI.Style.foreground(ANSI.Color.brightBlue) == "\u{1B}[94m")
    }

    @Test("SGR 256 color generates correct sequence")
    func color256() {
        #expect(ANSI.Style.foreground(ANSI.Color256(100)) == "\u{1B}[38;5;100m")
    }

    @Test("SGR true color generates correct sequence")
    func trueColor() {
        #expect(ANSI.Style.foreground(r: 255, g: 128, b: 64) == "\u{1B}[38;2;255;128;64m")
    }

    @Test("Style modifiers generate correct sequences")
    func styles() {
        #expect(ANSI.Style.bold == "\u{1B}[1m")
        #expect(ANSI.Style.italic == "\u{1B}[3m")
        #expect(ANSI.Style.underline == "\u{1B}[4m")
        #expect(ANSI.Style.reset == "\u{1B}[0m")
    }

    @Test("Erase sequences generate correct codes")
    func erase() {
        #expect(ANSI.Erase.screen == "\u{1B}[2J")
        #expect(ANSI.Erase.line == "\u{1B}[2K")
    }

    @Test("TrueColor hex initialization works correctly")
    func trueColorHex() {
        let color = ANSI.TrueColor(hex: 0xFF8040)
        #expect(color.red == 255)
        #expect(color.green == 128)
        #expect(color.blue == 64)
    }

    @Test("Color256 cube calculation is correct")
    func color256Cube() {
        let color = ANSI.Color256.cube(r: 5, g: 3, b: 1)
        // 16 + 36*5 + 6*3 + 1 = 16 + 180 + 18 + 1 = 215
        #expect(color.index == 215)
    }
}
