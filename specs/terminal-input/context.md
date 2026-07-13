---
spec: terminal-input.spec.md
---

## Key Decisions

- Separate byte parsing and line editing from TerminalCore stream ownership.
- Represent keyboard, modifiers, mouse input, and higher-level events as sendable values.
- Buffer partial escape sequences until they can be interpreted safely.

## Files to Read First

- `Sources/TerminalInput/InputReader.swift`
- `Sources/TerminalInput/KeyCode.swift`
- `Sources/TerminalInput/LineEditor.swift`
- `Sources/TerminalInput/MouseEvent.swift`

## Current Status

Input behavior is stable and covered by TerminalInputTests; implementation remains untouched.
