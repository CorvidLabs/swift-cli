---
spec: ansi.spec.md
---

# Requirements

### REQ-ansi-001

ANSI sequence builders SHALL return standards-shaped escape strings without performing terminal I/O.

Acceptance Criteria
- Cursor, erase, screen, report, hyperlink, and SGR helpers return their documented introducer and final byte.
- Calling a builder has no stream or global-state side effect.

### REQ-ansi-002

Color APIs SHALL encode named, indexed, RGB, hexadecimal, and color-cube values for foreground and background use.

Acceptance Criteria

- Named and indexed colors produce their corresponding SGR parameters.
- Valid six-digit hexadecimal RGB text round-trips to the same channel values; invalid text returns `nil`.

### REQ-ansi-003

Style APIs SHALL compose attributes in caller order and provide an explicit reset sequence.

Acceptance Criteria

- Bold, dim, italic, underline, blink, inverse, hidden, and strikethrough are representable.
- Combined styles preserve all requested parameters in order.

### REQ-ansi-004

Box-drawing APIs SHALL expose stable Unicode glyph sets for supported line and corner styles.

Acceptance Criteria

- Each style supplies horizontal, vertical, corner, and junction glyphs.
- Existing glyph values remain compatible with layout rendering.

## Constraints

- The module has no package dependency and performs no capability detection.
- Generated sequences remain portable strings even when a terminal elects not to interpret them.

## Out of Scope

- Terminal stream access, capability policy, layout, input, and declarative UI.
