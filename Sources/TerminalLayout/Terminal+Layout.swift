import TerminalCore

/// Terminal extensions for rendering layouts.
extension Terminal {
    /// Render a renderable element.
    public func render(_ renderable: any Renderable, width: Int? = nil) {
        let w = width ?? size.columns
        writeLine(renderable.render(width: w))
    }

    /// Render a box.
    public func render(_ box: Box, width: Int? = nil) {
        render(box as any Renderable, width: width)
    }

    /// Render a table.
    public func render(_ table: Table, width: Int? = nil) {
        render(table as any Renderable, width: width)
    }

    /// Render a panel.
    public func render(_ panel: Panel, width: Int? = nil) {
        render(panel as any Renderable, width: width)
    }

    /// Render a tree.
    public func render<T>(_ tree: Tree<T>, width: Int? = nil) {
        render(tree as any Renderable, width: width)
    }

    /// Render a divider.
    public func render(_ divider: Divider, width: Int? = nil) {
        render(divider as any Renderable, width: width)
    }

    /// Render a divider with just a title.
    public func divider(_ title: String? = nil) {
        let div = Divider(title: title)
        render(div)
    }
}
