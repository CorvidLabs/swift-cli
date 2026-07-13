---
spec: ansi.spec.md
---

## Key Decisions

- Keep escape generation pure and dependency-free.
- Represent sequences and glyphs as composable Swift values rather than performing I/O.
- Leave capability policy and stream ownership to TerminalCore.

## Files to Read First

- `Sources/ANSI/ANSI.swift`
- `Sources/ANSI/Color.swift`
- `Sources/ANSI/Cursor.swift`
- `Sources/ANSI/Style.swift`

## Current Status

Existing behavior is stable and covered by `Tests/ANSITests/ANSITests.swift`; this governance change does not modify it.
