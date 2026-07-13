---
spec: terminal-style.spec.md
---

# Requirements

### REQ-terminal-style-001

StyledText SHALL preserve plain content while composing foreground, background, and text attributes immutably.

Acceptance Criteria
- Chained modifiers do not mutate a previously created value.
- Plain output equals the caller's original visible characters.

### REQ-terminal-style-002

StyledText rendering SHALL emit configured ANSI prefixes and a reset when styling is enabled.

Acceptance Criteria

- Combined styles preserve caller order.
- Disabled color policy produces readable plain text.

### REQ-terminal-style-003

Concatenation and String conveniences SHALL preserve segment order and independent styling.

Acceptance Criteria

- Plain concatenation equals the concatenated source strings.
- Rendered concatenation retains each segment's configured attributes.

### REQ-terminal-style-004

Theme and Gradient SHALL provide deterministic semantic styles and interpolated colors.

Acceptance Criteria

- Theme role values match the selected built-in or caller-provided palette.
- Gradient endpoints equal the configured endpoint colors for nonempty output.

## Constraints

- Visible content remains separable from ANSI control bytes.

## Out of Scope

- Terminal capability detection and layout geometry.
