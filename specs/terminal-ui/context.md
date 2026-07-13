---
spec: terminal-ui.spec.md
---

## Key Decisions

- Model terminal interfaces as declarative View values built with ViewBuilder.
- Render into bounded buffers before performing full or differential terminal output.
- Keep terminal setup, input, render scheduling, and restoration in App.

## Files to Read First

- `Sources/TerminalUI/View.swift`
- `Sources/TerminalUI/ViewBuilder.swift`
- `Sources/TerminalUI/RenderBuffer.swift`
- `Sources/TerminalUI/RenderEngine.swift`
- `Sources/TerminalUI/App.swift`

## Current Status

The view and rendering model is stable and covered by TerminalUITests; product behavior is unchanged.
