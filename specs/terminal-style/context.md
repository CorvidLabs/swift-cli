---
spec: terminal-style.spec.md
---

## Key Decisions

- Keep StyledText immutable and retain its plain content separately from rendered ANSI.
- Offer semantic themes and gradients above ANSI's low-level sequence values.

## Files to Read First

- `Sources/TerminalStyle/StyledText.swift`
- `Sources/TerminalStyle/String+Style.swift`
- `Sources/TerminalStyle/Theme.swift`
- `Sources/TerminalStyle/Gradient.swift`

## Current Status

Styling behavior is stable and covered by TerminalStyleTests; product code is unchanged.
