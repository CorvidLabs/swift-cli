---
spec: terminal-components.spec.md
---

## Key Decisions

- Build components from TerminalCore, TerminalInput, and TerminalStyle rather than opening separate streams.
- Keep prompt, selection, progress, and spinner configuration explicit and reusable.

## Files to Read First

- `Sources/TerminalComponents/Confirm.swift`
- `Sources/TerminalComponents/ProgressBar.swift`
- `Sources/TerminalComponents/Spinner.swift`

## Current Status

Existing component behavior is stable and tested; this governance change modifies no component implementation.
