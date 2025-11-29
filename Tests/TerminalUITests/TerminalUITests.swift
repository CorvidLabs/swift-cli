import Testing
@testable import TerminalUI
import ANSI
import TerminalLayout

// MARK: - Test Helpers

/// Strip ANSI escape codes from a string for content comparison
func stripANSI(_ string: String) -> String {
    var result = string
    // Strip CSI sequences (e.g., \e[31m, \e[0m)
    while let range = result.range(of: "\u{1B}\\[[0-9;]*[a-zA-Z]", options: .regularExpression) {
        result.removeSubrange(range)
    }
    // Strip OSC sequences (hyperlinks)
    while let range = result.range(of: "\u{1B}\\][^\u{07}]*\u{07}", options: .regularExpression) {
        result.removeSubrange(range)
    }
    return result
}

/// Render a view and return stripped lines (ANSI codes removed)
func renderStripped<V: View>(_ view: V, width: Int = 80, height: Int = 24) -> [String] {
    let lines = RenderEngine.render(view, size: Size(width: width, height: height))
    return lines.map { stripANSI($0) }
}

/// Render a view and join lines into a single string
func renderJoined<V: View>(_ view: V, width: Int = 80, height: Int = 24) -> String {
    renderStripped(view, width: width, height: height).joined(separator: "\n")
}

// MARK: - Basic View Tests

@Suite("TerminalUI")
struct TerminalUITests {
    @Test("Text view stores content")
    func textView() {
        let text = Text("Hello")
        #expect(text.content == "Hello")
    }

    @Test("Text view applies styles")
    func textViewStyles() {
        let text = Text("Test").bold().italic().foregroundColor(.red)
        #expect(text.styles.contains(.bold))
        #expect(text.styles.contains(.italic))
        #expect(text.foreground == .red)
    }

    @Test("Text converts to StyledText")
    func textToStyledText() {
        let text = Text("Hello").bold().foregroundColor(.blue)
        let styled = text.toStyledText()
        #expect(styled.plainText == "Hello")
        #expect(styled.styles.contains(.bold))
        #expect(styled.foreground == .blue)
    }

    @Test("Size struct stores dimensions")
    func sizeStruct() {
        let size = Size(width: 80, height: 24)
        #expect(size.width == 80)
        #expect(size.height == 24)
    }

    @Test("Position struct stores coordinates")
    func positionStruct() {
        let pos = Position(x: 10, y: 20)
        #expect(pos.x == 10)
        #expect(pos.y == 20)
    }

    @Test("EmptyView exists")
    func emptyView() {
        let empty = EmptyView()
        _ = empty // Just verify it can be created
    }

    @Test("Spacer has minLength")
    func spacer() {
        let spacer = Spacer(minLength: 5)
        #expect(spacer.minLength == 5)

        let defaultSpacer = Spacer()
        #expect(defaultSpacer.minLength == nil)
    }

    @Test("EdgeInsets stores padding values")
    func edgeInsets() {
        let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        #expect(insets.top == 1)
        #expect(insets.leading == 2)
        #expect(insets.bottom == 3)
        #expect(insets.trailing == 4)
    }

    @Test("RenderEngine renders Text")
    func renderEngineText() {
        let text = Text("Hello")
        let lines = RenderEngine.render(text, size: Size(width: 80, height: 24))
        #expect(lines.count == 1)
        #expect(lines[0].contains("Hello"))
    }
}

// MARK: - VStack Tests

@Suite("VStack")
struct VStackTests {
    @Test("VStack stores alignment and spacing")
    func vstackProperties() {
        let stack = VStack(alignment: .center, spacing: 5) {
            Text("Test")
        }
        #expect(stack.alignment == .center)
        #expect(stack.spacing == 5)
    }

    @Test("VStack defaults to leading alignment and zero spacing")
    func vstackDefaults() {
        let stack = VStack {
            Text("Test")
        }
        #expect(stack.alignment == .leading)
        #expect(stack.spacing == 0)
    }

    @Test("VStack renders children vertically")
    func vstackRendering() {
        let view = VStack {
            Text("Line 1")
            Text("Line 2")
            Text("Line 3")
        }
        let lines = renderStripped(view)
        #expect(lines.count == 3)
        #expect(lines[0] == "Line 1")
        #expect(lines[1] == "Line 2")
        #expect(lines[2] == "Line 3")
    }

    @Test("VStack with spacing adds empty lines")
    func vstackSpacing() {
        let view = VStack(spacing: 1) {
            Text("A")
            Text("B")
        }
        let lines = renderStripped(view)
        #expect(lines.count == 3)
        #expect(lines[0] == "A")
        #expect(lines[1] == "")
        #expect(lines[2] == "B")
    }

    @Test("VStack center alignment")
    func vstackCenterAlignment() {
        let view = VStack(alignment: .center) {
            Text("Short")
            Text("Longer text")
        }
        let lines = renderStripped(view)
        #expect(lines.count == 2)
        // "Short" should be centered relative to "Longer text"
        #expect(lines[0].hasPrefix("   "))  // 3 spaces for centering
        #expect(lines[0].contains("Short"))
    }

    @Test("VStack trailing alignment")
    func vstackTrailingAlignment() {
        let view = VStack(alignment: .trailing) {
            Text("A")
            Text("BB")
        }
        let lines = renderStripped(view)
        #expect(lines.count == 2)
        // "A" should have more leading space than "BB"
        #expect(lines[0].hasPrefix(" "))
        #expect(!lines[1].hasPrefix(" "))
    }
}

// MARK: - HStack Tests

@Suite("HStack")
struct HStackTests {
    @Test("HStack stores alignment and spacing")
    func hstackProperties() {
        let stack = HStack(alignment: .top, spacing: 3) {
            Text("A")
        }
        #expect(stack.alignment == .top)
        #expect(stack.spacing == 3)
    }

    @Test("HStack defaults to center alignment and zero spacing")
    func hstackDefaults() {
        let stack = HStack {
            Text("Test")
        }
        #expect(stack.alignment == .center)
        #expect(stack.spacing == 0)
    }

    @Test("HStack renders children horizontally")
    func hstackRendering() {
        let view = HStack {
            Text("A")
            Text("B")
            Text("C")
        }
        let lines = renderStripped(view)
        #expect(lines.count == 1)
        #expect(lines[0] == "ABC")
    }

    @Test("HStack with spacing adds spaces between children")
    func hstackSpacing() {
        let view = HStack(spacing: 2) {
            Text("A")
            Text("B")
        }
        let lines = renderStripped(view)
        #expect(lines.count == 1)
        #expect(lines[0] == "A  B")
    }
}

// MARK: - ForEach Tests

@Suite("ForEach")
struct ForEachTests {
    @Test("ForEach renders array elements")
    func forEachArray() {
        let items = ["One", "Two", "Three"]
        let view = ForEach(items) { item in
            Text(item)
        }
        let lines = renderStripped(view)
        #expect(lines.count == 3)
        #expect(lines[0] == "One")
        #expect(lines[1] == "Two")
        #expect(lines[2] == "Three")
    }

    @Test("ForEach renders range")
    func forEachRange() {
        let view = ForEach(0..<3) { index in
            Text("Item \(index)")
        }
        let lines = renderStripped(view)
        #expect(lines.count == 3)
        #expect(lines[0] == "Item 0")
        #expect(lines[1] == "Item 1")
        #expect(lines[2] == "Item 2")
    }

    @Test("ForEach with empty collection renders nothing")
    func forEachEmpty() {
        let items: [String] = []
        let view = ForEach(items) { item in
            Text(item)
        }
        let lines = renderStripped(view)
        #expect(lines.isEmpty)
    }
}

// MARK: - Padding Tests

@Suite("Padding")
struct PaddingTests {
    @Test("Padding modifier creates PaddedView")
    func paddingModifier() {
        let padded = Text("Test").padding(2)
        #expect(padded.padding == EdgeInsets(2))
    }

    @Test("Horizontal padding adds spaces")
    func horizontalPadding() {
        let view = Text("X").padding(horizontal: 2, vertical: 0)
        let lines = renderStripped(view)
        #expect(lines.count == 1)
        #expect(lines[0].hasPrefix("  "))  // 2 spaces before
        #expect(lines[0].hasSuffix("  "))  // 2 spaces after
        #expect(lines[0].contains("X"))
    }

    @Test("Vertical padding adds empty lines")
    func verticalPadding() {
        let view = Text("X").padding(horizontal: 0, vertical: 1)
        let lines = renderStripped(view)
        #expect(lines.count == 3)
        #expect(lines[0] == " ")  // Empty line with content width
        #expect(lines[1] == "X")
        #expect(lines[2] == " ")  // Empty line with content width
    }

    @Test("All-around padding")
    func allPadding() {
        let view = Text("X").padding(1)
        let lines = renderStripped(view)
        #expect(lines.count == 3)
        #expect(lines[1].contains("X"))
        #expect(lines[1].hasPrefix(" "))
        #expect(lines[1].hasSuffix(" "))
    }
}

// MARK: - Border Tests

@Suite("Border")
struct BorderTests {
    @Test("Border modifier creates BorderedView")
    func borderModifier() {
        let bordered = Text("Test").border(.rounded)
        #expect(bordered.style.topLeft == BoxStyle.rounded.topLeft)
    }

    @Test("Border renders with box characters")
    func borderRendering() {
        let view = Text("Hi").border(.rounded)
        let lines = renderStripped(view)
        #expect(lines.count == 3)
        // Top border
        #expect(lines[0].contains("╭"))
        #expect(lines[0].contains("╮"))
        // Content
        #expect(lines[1].contains("Hi"))
        #expect(lines[1].contains("│"))
        // Bottom border
        #expect(lines[2].contains("╰"))
        #expect(lines[2].contains("╯"))
    }

    @Test("Border with title")
    func borderWithTitle() {
        let view = Text("Content").border(.single, title: "Title")
        let lines = renderStripped(view)
        #expect(lines[0].contains("Title"))
    }

    @Test("ASCII border style")
    func asciiBorder() {
        let view = Text("Test").border(.ascii)
        let lines = renderStripped(view)
        #expect(lines[0].contains("+"))
        #expect(lines[0].contains("-"))
        #expect(lines[1].contains("|"))
    }

    @Test("Border title width calculation handles ANSI codes")
    func borderTitleWithANSI() {
        // Title with ANSI codes should count only visible chars ("Red" = 3 chars, not 14)
        let titleWithANSI = "\u{1B}[31mRed\u{1B}[0m"
        let view = Text("Content").border(.rounded, title: titleWithANSI)
        let lines = RenderEngine.render(view, size: Size(width: 80, height: 24))

        // The top border should be properly aligned
        // Title " Red " = 5 visible chars (with spaces)
        let topLine = stripANSI(lines[0])
        #expect(topLine.contains("Red"))
        // Verify the border is properly formed with corners
        #expect(topLine.hasPrefix("╭"))
        #expect(topLine.hasSuffix("╮"))
    }

    @Test("Border with empty content renders minimal box")
    func borderEmptyContent() {
        let view = VStack {
            EmptyView()
        }.border(.rounded)
        let lines = renderStripped(view)
        // Should have top border, at least one content line, and bottom border
        #expect(lines.count >= 2)
        #expect(lines[0].contains("╭"))
        #expect(lines.last?.contains("╰") == true)
    }

    @Test("Nested borders render correctly")
    func nestedBorders() {
        let view = Text("Inner").border(.single).border(.double)
        let lines = renderStripped(view)
        // Outer border (double)
        #expect(lines[0].contains("╔"))
        #expect(lines[0].contains("╗"))
        // Inner border (single) should be inside
        #expect(lines[1].contains("┌"))
        #expect(lines[1].contains("┐"))
        // Bottom borders
        #expect(lines.last?.contains("╚") == true)
    }

    @Test("Border color is applied correctly")
    func borderColor() {
        let view = Text("Test").border(.rounded, color: .red)
        let lines = RenderEngine.render(view, size: Size(width: 80, height: 24))
        // The raw output should contain ANSI color codes
        #expect(lines[0].contains("\u{1B}[31m"))  // Red color code
    }
}

// MARK: - Nested Container Tests

@Suite("Nested Containers")
struct NestedContainerTests {
    @Test("VStack containing HStack")
    func vstackContainingHstack() {
        let view = VStack {
            HStack {
                Text("Left")
                Text("Right")
            }
            Text("Bottom")
        }
        let lines = renderStripped(view)
        #expect(lines.count == 2)
        #expect(lines[0].contains("Left"))
        #expect(lines[0].contains("Right"))
        #expect(lines[1] == "Bottom")
    }

    @Test("HStack containing VStack")
    func hstackContainingVstack() {
        let view = HStack {
            VStack {
                Text("A")
                Text("B")
            }
            Text("C")
        }
        let lines = renderStripped(view)
        // Should have 2 rows (from VStack)
        #expect(lines.count == 2)
        #expect(lines[0].contains("A"))
        #expect(lines[0].contains("C"))
        #expect(lines[1].contains("B"))
    }

    @Test("Bordered VStack")
    func borderedVStack() {
        let view = VStack {
            Text("Line 1")
            Text("Line 2")
        }.border(.rounded)
        let lines = renderStripped(view)
        // Border adds 2 lines (top + bottom)
        #expect(lines.count == 4)
        #expect(lines[0].contains("╭"))
        #expect(lines[1].contains("Line 1"))
        #expect(lines[2].contains("Line 2"))
        #expect(lines[3].contains("╰"))
    }
}

// MARK: - Snapshot Tests

@Suite("Snapshot Tests")
struct SnapshotTests {
    @Test("Simple VStack snapshot")
    func simpleVStackSnapshot() {
        let view = VStack {
            Text("Header")
            Text("Body")
            Text("Footer")
        }
        let output = renderJoined(view)
        let expected = """
            Header
            Body
            Footer
            """
        #expect(output == expected)
    }

    @Test("HStack with spacing snapshot")
    func hstackSpacingSnapshot() {
        let view = HStack(spacing: 1) {
            Text("A")
            Text("B")
            Text("C")
        }
        let output = renderJoined(view)
        #expect(output == "A B C")
    }

    @Test("ForEach in VStack snapshot")
    func forEachInVStackSnapshot() {
        let items = ["Apple", "Banana", "Cherry"]
        let view = VStack {
            ForEach(items) { item in
                Text("- \(item)")
            }
        }
        let output = renderJoined(view)
        let expected = """
            - Apple
            - Banana
            - Cherry
            """
        #expect(output == expected)
    }
}

// MARK: - Integration Tests

@Suite("Integration Tests")
struct IntegrationTests {
    @Test("Demo TUI App renders correctly")
    func demoTUIApp() {
        // Simulate the DemoTUIApp structure
        let view = VStack {
            Text("  TerminalUI Demo  ").bold()
            Text("  A SwiftUI-like framework  ").dim()
            HStack {
                Text("Red")
                Text("Green")
                Text("Blue")
            }
            Text("  Press 'q' to exit  ").dim()
        }.border(.rounded)

        let lines = renderStripped(view)

        // Should have border (top + 4 content lines + bottom = 6 lines)
        #expect(lines.count == 6)

        // Check top border
        #expect(lines[0].contains("╭"))
        #expect(lines[0].contains("╮"))

        // Check content lines
        #expect(lines[1].contains("TerminalUI Demo"))
        #expect(lines[2].contains("SwiftUI-like framework"))
        #expect(lines[3].contains("Red"))
        #expect(lines[3].contains("Green"))
        #expect(lines[3].contains("Blue"))
        #expect(lines[4].contains("Press 'q' to exit"))

        // Check bottom border
        #expect(lines[5].contains("╰"))
        #expect(lines[5].contains("╯"))
    }
}

// MARK: - Edge Case Tests

@Suite("Edge Cases")
struct EdgeCaseTests {
    @Test("Empty VStack renders nothing")
    func emptyVStack() {
        let view = VStack {
            EmptyView()
        }
        let lines = renderStripped(view)
        #expect(lines.isEmpty)
    }

    @Test("Deeply nested views render correctly")
    func deeplyNested() {
        let view = VStack {
            VStack {
                VStack {
                    Text("Deep")
                }
            }
        }
        let lines = renderStripped(view)
        #expect(lines.count == 1)
        #expect(lines[0] == "Deep")
    }

    @Test("Unicode text renders correctly")
    func unicodeText() {
        let view = Text("Hello 🌍")
        let lines = renderStripped(view)
        #expect(lines[0].contains("🌍"))
    }

    @Test("ANSI codes are stripped correctly")
    func ansiStripping() {
        let input = "\u{1B}[31mRed\u{1B}[0m"
        let stripped = stripANSI(input)
        #expect(stripped == "Red")
    }
}

// MARK: - RenderBuffer Tests

@Suite("RenderBuffer")
struct RenderBufferTests {
    @Test("RenderBuffer diff finds changed lines")
    func bufferDiff() {
        let size = Size(width: 80, height: 24)
        let buffer1 = RenderBuffer(lines: ["A", "B", "C"], size: size)
        let buffer2 = RenderBuffer(lines: ["A", "X", "C"], size: size)
        let diff = buffer2.diff(against: buffer1)

        #expect(diff.changedLines == [1])
        #expect(!diff.isFullRepaint)
        #expect(diff.hasChanges)
    }

    @Test("RenderBuffer diff with no changes")
    func bufferDiffNoChanges() {
        let size = Size(width: 80, height: 24)
        let buffer1 = RenderBuffer(lines: ["A", "B", "C"], size: size)
        let buffer2 = RenderBuffer(lines: ["A", "B", "C"], size: size)
        let diff = buffer2.diff(against: buffer1)

        #expect(diff.changedLines.isEmpty)
        #expect(!diff.hasChanges)
    }

    @Test("RenderBuffer diff forces full repaint on size change")
    func bufferDiffSizeChange() {
        let buffer1 = RenderBuffer(lines: ["A", "B"], size: Size(width: 80, height: 24))
        let buffer2 = RenderBuffer(lines: ["A", "B"], size: Size(width: 100, height: 24))
        let diff = buffer2.diff(against: buffer1)

        #expect(diff.isFullRepaint)
        #expect(diff.changedLines.count == 2)  // All lines marked changed
    }

    @Test("RenderBuffer diff with nil previous")
    func bufferDiffNilPrevious() {
        let buffer = RenderBuffer(lines: ["A", "B", "C"], size: Size(width: 80, height: 24))
        let diff = buffer.diff(against: nil)

        #expect(diff.isFullRepaint)
        #expect(diff.changedLines.count == 3)
    }

    @Test("RenderedLine equality uses hash for fast comparison")
    func renderedLineEquality() {
        let line1 = RenderedLine("Hello World")
        let line2 = RenderedLine("Hello World")
        let line3 = RenderedLine("Goodbye")

        #expect(line1 == line2)
        #expect(line1 != line3)
    }
}

// MARK: - SpinnerView Tests

@Suite("SpinnerView")
struct SpinnerViewTests {
    @Test("SpinnerView includes message")
    func spinnerMessage() {
        let view = SpinnerView(style: .dots, message: "Loading")
        let lines = renderStripped(view)
        #expect(lines.count >= 1)
        #expect(lines[0].contains("Loading"))
    }

    @Test("SpinnerView renders frame when active")
    func spinnerActiveFrame() {
        let view = SpinnerView(style: .dots, message: "", isActive: true)
        let lines = renderStripped(view)
        #expect(lines.count == 1)
        // Should contain one of the dot frames
        let dotFrames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        let containsFrame = dotFrames.contains { lines[0].contains($0) }
        #expect(containsFrame)
    }

    @Test("SpinnerView inactive shows space")
    func spinnerInactive() {
        let view = SpinnerView(style: .dots, message: "", isActive: false)
        let lines = renderStripped(view)
        #expect(lines.count == 1)
        #expect(lines[0] == " ")
    }

    @Test("SpinnerView inactive with message")
    func spinnerInactiveWithMessage() {
        let view = SpinnerView(style: .dots, message: "Done", isActive: false)
        let lines = renderStripped(view)
        #expect(lines[0].contains("Done"))
    }

    @Test("SpinnerView different styles have different frames")
    func spinnerStyles() {
        let dotsView = SpinnerView(style: .dots)
        let lineView = SpinnerView(style: .line)
        let arrowView = SpinnerView(style: .arrow)

        // Just verify they render without error
        let dotsLines = renderStripped(dotsView)
        let lineLines = renderStripped(lineView)
        let arrowLines = renderStripped(arrowView)

        #expect(!dotsLines.isEmpty)
        #expect(!lineLines.isEmpty)
        #expect(!arrowLines.isEmpty)
    }
}

// MARK: - RenderEngine Tests

@Suite("RenderEngine")
struct RenderEngineTests {
    @Test("visibleLength excludes ANSI escape sequences")
    func visibleLengthANSI() {
        let plainText = "Hello"
        let coloredText = "\u{1B}[31mHello\u{1B}[0m"  // Red "Hello"
        let boldText = "\u{1B}[1mHello\u{1B}[0m"      // Bold "Hello"

        #expect(RenderEngine.visibleLength(plainText) == 5)
        #expect(RenderEngine.visibleLength(coloredText) == 5)
        #expect(RenderEngine.visibleLength(boldText) == 5)
    }

    @Test("visibleLength handles complex ANSI sequences")
    func visibleLengthComplexANSI() {
        // Multiple style codes
        let multiStyle = "\u{1B}[1;31;4mStyled\u{1B}[0m"  // Bold, red, underline
        #expect(RenderEngine.visibleLength(multiStyle) == 6)
    }

    @Test("visibleLength handles empty string")
    func visibleLengthEmpty() {
        #expect(RenderEngine.visibleLength("") == 0)
    }

    @Test("visibleLength handles only ANSI codes")
    func visibleLengthOnlyANSI() {
        let onlyCodes = "\u{1B}[31m\u{1B}[0m"
        #expect(RenderEngine.visibleLength(onlyCodes) == 0)
    }
}
