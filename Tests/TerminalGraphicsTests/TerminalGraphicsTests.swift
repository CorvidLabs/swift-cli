import Testing
@testable import TerminalGraphics
import Foundation

@Suite("TerminalGraphics")
struct TerminalGraphicsTests {
    @Test("ImageConfig has sensible defaults")
    func imageConfigDefaults() {
        let config = ImageConfig.default
        #expect(config.preserveAspectRatio == true)
        #expect(config.inline == true)
    }

    @Test("ITerm2Image renders base64 data")
    func iterm2ImageRender() {
        let data = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header
        let image = ITerm2Image(data: data)
        let rendered = image.render()

        #expect(rendered.contains("\u{1B}]1337"))
        #expect(rendered.contains("inline=1"))
        #expect(rendered.contains("\u{07}"))
    }

    @Test("ITerm2Image includes name when provided")
    func iterm2ImageWithName() {
        let data = Data([0x00])
        let image = ITerm2Image(data: data, name: "test.png")
        let rendered = image.render()

        #expect(rendered.contains("name="))
    }

    @Test("KittyImage renders chunked data")
    func kittyImageRender() {
        let data = Data([0x89, 0x50, 0x4E, 0x47])
        let image = KittyImage(data: data, format: .png)
        let rendered = image.render()

        #expect(rendered.contains("\u{1B}_G"))
        #expect(rendered.contains("a=T"))
        #expect(rendered.contains("f=100"))
    }

    @Test("ImageSize cases exist")
    func imageSizeCases() {
        let auto = ImageSize.auto
        let cells = ImageSize.cells(10)
        let percent = ImageSize.percent(50)
        let pixels = ImageSize.pixels(100)

        // Just verify they compile and can be created
        _ = auto
        _ = cells
        _ = percent
        _ = pixels
    }
}
