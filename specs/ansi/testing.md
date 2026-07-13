---
spec: ansi.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `Tests/ANSITests/ANSITests.swift` | REQ-ansi-001, REQ-ansi-002, REQ-ansi-003, REQ-ansi-004 | Cursor and erase sequences, named/indexed/true color, hex and cube conversion, styles, resets, and glyph values. |

## Manual Testing

No interactive flow is required; compare generated strings and run `swift test` from a clean checkout.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Invalid six-digit hexadecimal text | Failable initializer returns `nil`. |
| Indexed color boundary | Values encode the selected palette index. |
| Multiple style attributes | Parameters retain caller order and reset is available. |
