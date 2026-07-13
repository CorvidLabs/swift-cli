---
spec: terminal-core.spec.md
---

## Key Decisions

- Centralize low-level streams, raw mode, capabilities, size, configuration, and errors in TerminalCore.
- Use conservative fallbacks when terminal discovery is unavailable.
- Preserve platform-specific implementations behind one public contract.

## Files to Read First

- `Sources/TerminalCore/Terminal.swift`
- `Sources/TerminalCore/TerminalCapabilities.swift`
- `Sources/TerminalCore/TerminalConfiguration.swift`
- `Sources/TerminalCore/TerminalError.swift`

## Current Status

The runtime behavior is stable and protected by TerminalCoreTests; this change adds governance only.
