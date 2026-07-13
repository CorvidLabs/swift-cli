---
spec: terminal-layout.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `Tests/TerminalLayoutTests/TerminalLayoutTests.swift` | REQ-terminal-layout-001, REQ-terminal-layout-002, REQ-terminal-layout-003, REQ-terminal-layout-004 | Boxes and titles, border styles, tables, dividers, tree connectors, alignment, and visible rendering. |

## Manual Testing

Run native tests and compare representative rendered layouts in a terminal before behavioral formatting changes.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| ANSI-styled content is measured | Escape bytes do not increase visible width. |
| Row has fewer cells than columns | Missing cells render empty without shifting columns. |
| Nested final tree child | Last-child connector is used at the correct depth. |
