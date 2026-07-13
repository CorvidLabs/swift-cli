---
spec: terminal-graphics.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `Tests/TerminalGraphicsTests/TerminalGraphicsTests.swift` | REQ-terminal-graphics-001, REQ-terminal-graphics-002, REQ-terminal-graphics-003, REQ-terminal-graphics-004 | Configuration defaults, iTerm2 metadata/rendering, Kitty chunking, protocol selection, and image size. |

## Manual Testing

Protocol payloads should be visually checked in a supporting iTerm2, Kitty, or Sixel terminal before behavioral
encoder changes; governance-only changes require native and hosted verification.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Payload exceeds Kitty chunk size | Ordered continuation chunks are emitted. |
| No image protocol is supported | Automatic rendering reports unsupported output. |
| Optional metadata is absent | Its protocol field is omitted. |
