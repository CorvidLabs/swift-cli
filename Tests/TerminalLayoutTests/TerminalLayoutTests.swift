import Testing
@testable import TerminalLayout
import ANSI

@Suite("TerminalLayout")
struct TerminalLayoutTests {
    @Test("Box renders with content")
    func boxRender() {
        let box = Box("Hello", style: .single, padding: .none)
        let rendered = box.render()
        #expect(rendered.contains("Hello"))
        #expect(rendered.contains("┌"))
        #expect(rendered.contains("└"))
    }

    @Test("Box renders with title")
    func boxWithTitle() {
        let box = Box("Content", style: .rounded, title: "Title")
        let rendered = box.render()
        #expect(rendered.contains("Title"))
        #expect(rendered.contains("Content"))
    }

    @Test("BoxStyle presets have correct characters")
    func boxStylePresets() {
        #expect(BoxStyle.single.topLeft == "┌")
        #expect(BoxStyle.double.topLeft == "╔")
        #expect(BoxStyle.rounded.topLeft == "╭")
        #expect(BoxStyle.heavy.topLeft == "┏")
        #expect(BoxStyle.ascii.topLeft == "+")
    }

    @Test("Table renders with columns")
    func tableRender() {
        var table = Table(
            columns: [
                .init("Name"),
                .init("Age", alignment: .right)
            ]
        )
        table.addRow(["Alice", "30"])

        let rendered = table.render()
        #expect(rendered.contains("Name"))
        #expect(rendered.contains("Age"))
        #expect(rendered.contains("Alice"))
        #expect(rendered.contains("30"))
    }

    @Test("Table simple factory works")
    func tableSimple() {
        let table = Table.simple(
            headers: ["A", "B"],
            rows: [["1", "2"], ["3", "4"]]
        )
        #expect(table.columns.count == 2)
        #expect(table.rows.count == 2)
    }

    @Test("Divider renders at correct width")
    func dividerRender() {
        let divider = Divider(character: "-")
        let rendered = divider.render(width: 10)
        #expect(rendered == "----------")
    }

    @Test("Divider with title")
    func dividerWithTitle() {
        let divider = Divider(character: "─", title: "Test", titleAlignment: .center)
        let rendered = divider.render(width: 20)
        #expect(rendered.contains("Test"))
    }

    @Test("Tree renders with children")
    func treeRender() {
        let tree = Tree<String>(
            root: treeNode("root", children: [
                treeNode("child1"),
                treeNode("child2")
            ])
        )
        let rendered = tree.render()
        #expect(rendered.contains("root"))
        #expect(rendered.contains("child1"))
        #expect(rendered.contains("child2"))
        #expect(rendered.contains("├──") || rendered.contains("└──"))
    }
}
