# ``TerminalLayout``

Boxes, tables, grids, panels, and tree views for structured terminal output.

## Overview

TerminalLayout provides components for creating structured, bordered output in the terminal. Build tables, panels, tree views, and decorated boxes with various border styles.

```swift
import TerminalLayout

// Simple box
let box = Box("Hello, World!", style: .rounded)
await terminal.render(box)

// Table
let table = Table(
    headers: ["Name", "Age"],
    rows: [
        ["Alice", "30"],
        ["Bob", "25"]
    ]
)
await terminal.render(table)

// Tree view
let tree = Tree("Root") {
    Tree("Child 1")
    Tree("Child 2") {
        Tree("Grandchild")
    }
}
await terminal.render(tree)
```

## Topics

### Boxes and Panels

- ``Box``
- ``Panel``
- ``BoxStyle``

### Tables

- ``Table``

### Tree Views

- ``Tree``

### Dividers

- ``TerminalLayout/Divider``

### Rendering Protocol

- ``Renderable``
