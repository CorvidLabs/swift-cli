---
spec: terminal-layout.spec.md
---

## Key Decisions

- Render structured values to terminal text without owning input or a persistent screen.
- Measure visible cells independently of ANSI control bytes.
- Keep boxes, panels, tables, dividers, and trees independently composable.

## Files to Read First

- `Sources/TerminalLayout/Renderable.swift`
- `Sources/TerminalLayout/Box.swift`
- `Sources/TerminalLayout/Table.swift`
- `Sources/TerminalLayout/Tree.swift`

## Current Status

Layout behavior is stable and covered by TerminalLayoutTests; implementation is unchanged.
