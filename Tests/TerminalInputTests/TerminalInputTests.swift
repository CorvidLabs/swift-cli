import Testing
@testable import TerminalInput

@Suite("TerminalInput")
struct TerminalInputTests {
    @Test("KeyCode character equality")
    func keyCodeCharacter() {
        let key = KeyCode.character("a")
        #expect(key.character == "a")
        #expect(key.isPrintable)
    }

    @Test("KeyCode special keys")
    func keyCodeSpecial() {
        #expect(KeyCode.enter.isEnter)
        #expect(KeyCode.escape.isEscape)
        #expect(KeyCode.backspace.isBackspace)
        #expect(KeyCode.tab.isTab)
    }

    @Test("KeyCode control combinations")
    func keyCodeControl() {
        let ctrlC = KeyCode.ctrl("c")
        #expect(ctrlC.isControl)
        #expect(ctrlC.isInterrupt)

        let ctrlD = KeyCode.ctrl("d")
        #expect(ctrlD.isEOF)
    }

    @Test("KeyCode descriptions are readable")
    func keyCodeDescription() {
        #expect(KeyCode.enter.description == "Enter")
        #expect(KeyCode.arrow(.up).description == "↑")
        #expect(KeyCode.function(1).description == "F1")
        #expect(KeyCode.ctrl("c").description == "Ctrl+C")
    }

    @Test("Modifiers can be combined")
    func modifiersCombine() {
        let mods: Modifiers = [.shift, .control]
        #expect(mods.contains(.shift))
        #expect(mods.contains(.control))
        #expect(!mods.contains(.alt))
    }

    @Test("InputReader parses single character")
    func inputReaderSingle() {
        let reader = InputReader()
        let event = reader.parse([0x61]) // 'a'
        if case .key(let code, _) = event {
            #expect(code == .character("a"))
        } else {
            Issue.record("Expected key event")
        }
    }

    @Test("InputReader parses escape")
    func inputReaderEscape() {
        let reader = InputReader()
        let event = reader.parse([0x1B])
        if case .key(let code, _) = event {
            #expect(code == .escape)
        } else {
            Issue.record("Expected escape key")
        }
    }

    @Test("InputReader parses arrow keys")
    func inputReaderArrows() {
        let reader = InputReader()

        // Up arrow: ESC [ A
        let up = reader.parse([0x1B, 0x5B, 0x41])
        if case .key(let code, _) = up {
            #expect(code == .arrow(.up))
        } else {
            Issue.record("Expected up arrow")
        }
    }

    @Test("MouseEvent stores correct data")
    func mouseEvent() {
        let event = MouseEvent(
            action: .press,
            button: .left,
            column: 10,
            row: 20,
            modifiers: .shift
        )
        #expect(event.action == .press)
        #expect(event.button == .left)
        #expect(event.column == 10)
        #expect(event.row == 20)
        #expect(event.modifiers.contains(.shift))
    }
}
