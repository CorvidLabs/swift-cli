---
spec: terminal-graphics.spec.md
---

## Key Decisions

- Expose protocol-specific renderers and an automatic TerminalImage selector.
- Treat caller data as already-decoded image bytes and own only terminal encoding/framing.

## Files to Read First

- `Sources/TerminalGraphics/ImageProtocol.swift`
- `Sources/TerminalGraphics/ITerm2Image.swift`
- `Sources/TerminalGraphics/KittyImage.swift`
- `Sources/TerminalGraphics/TerminalImage.swift`

## Current Status

Existing encoders are stable and covered by TerminalGraphicsTests; implementation is unchanged.
