---
module: terminal-layout
version: 2
status: stable
files:
  - Sources/TerminalLayout/Box.swift
  - Sources/TerminalLayout/BoxStyle.swift
  - Sources/TerminalLayout/Divider.swift
  - Sources/TerminalLayout/Panel.swift
  - Sources/TerminalLayout/Renderable.swift
  - Sources/TerminalLayout/Table.swift
  - Sources/TerminalLayout/Terminal+Layout.swift
  - Sources/TerminalLayout/Tree.swift


db_tables: []
depends_on:
  - specs/ansi/ansi.spec.md
  - specs/terminal-core/terminal-core.spec.md
  - specs/terminal-style/terminal-style.spec.md
---

# Terminal Layout

## Purpose

`TerminalLayout` renders structured terminal content as boxes, panels, tables, dividers, and trees. Its renderable
values calculate borders, padding, alignment, width, and styled text without owning input or persistent screen state.

## Public API

The inventory covers the `Renderable` contract, border styles, boxes and panels, table columns/rows/alignment,
dividers, trees, and Terminal convenience rendering methods.

### Exported Functions

| Symbol |
|--------|
| `Box` |
| `content` |
| `style` |
| `padding` |
| `title` |
| `titleAlignment` |
| `borderColor` |
| `Padding` |
| `top` |
| `bottom` |
| `left` |
| `right` |
| `none` |
| `small` |
| `medium` |
| `large` |
| `Alignment` |
| `render` |
| `simple` |
| `rounded` |
| `double` |
| `heavy` |
| `init` |
| `center` |
| `BoxStyle` |
| `topLeft` |
| `topRight` |
| `bottomLeft` |
| `bottomRight` |
| `horizontal` |
| `vertical` |
| `verticalLeft` |
| `verticalRight` |
| `horizontalUp` |
| `horizontalDown` |
| `cross` |
| `single` |
| `ascii` |
| `Divider` |
| `character` |
| `color` |
| `dashed` |
| `dotted` |
| `Panel` |
| `PanelContentBuilder` |
| `buildBlock` |
| `buildExpression` |
| `buildOptional` |
| `buildEither` |
| `buildArray` |
| `Renderable` |
| `RenderContext` |
| `width` |
| `height` |
| `supportsUnicode` |
| `colorMode` |
| `from` |
| `Table` |
| `columns` |
| `showHeader` |
| `showRowSeparators` |
| `headerStyle` |
| `Column` |
| `header` |
| `alignment` |
| `Width` |
| `HeaderStyle` |
| `addRow` |
| `auto` |
| `fixed` |
| `min` |
| `max` |
| `percentage` |
| `plain` |
| `bold` |
| `underline` |
| `reversed` |
| `divider` |
| `TreeConnectorStyle` |
| `branch` |
| `lastBranch` |
| `space` |
| `unicode` |
| `minimal` |
| `Tree` |
| `root` |
| `connectorStyle` |
| `Node` |
| `value` |
| `label` |
| `children` |
| `treeNode` |
### Exported Types

| Type | Description |
|------|-------------|

## Invariants

1. Rendered line width respects the configured width after accounting for border and padding cells.
2. Table rows use a consistent column layout and each column's configured alignment.
3. Tree connectors reflect whether a node is the final child and preserve recursive hierarchy.
4. ANSI styling does not count toward visible layout width.

## Behavioral Examples

- A titled box renders the selected border style, title, padding, and content inside a consistent rectangle.
- A table computes column widths from headers, cells, constraints, and terminal width, then aligns each cell.
- A tree renders branch and last-child connectors for every nested node.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Content exceeds a constrained width | The renderer wraps or truncates according to the component's declared policy. |
| A table row has fewer cells than columns | Missing cells render as empty content without shifting later columns. |
| Terminal output fails | TerminalCore's error is propagated by convenience methods. |

## Dependencies

Consumes ANSI, TerminalCore, and TerminalStyle. TerminalUI, CLI, and applications consume the rendered structures.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured existing terminal layout behavior for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
