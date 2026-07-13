---
spec: terminal-input.spec.md
---

# Requirements

### REQ-terminal-input-001

Input parsing SHALL convert complete printable, control, navigation, function, modifier, and mouse sequences into
their semantic event values.

Acceptance Criteria
- Printable Unicode produces character key events.
- Recognized escape and mouse reports preserve key/button, action, coordinates, and modifiers.

### REQ-terminal-input-002

InputReader SHALL buffer incomplete sequences and publish complete events in stream order.

Acceptance Criteria

- A partial escape sequence is not emitted as a completed different key prematurely.
- End-of-input and read failures terminate through the declared API rather than crashing.

### REQ-terminal-input-003

LineEditor SHALL support insertion, deletion, movement, history, submission, cancellation, validation, and secret mode.

Acceptance Criteria

- Editing operations update the logical buffer and cursor consistently.
- Secret mode never echoes the submitted plain-text value.

### REQ-terminal-input-004

Terminal input conveniences SHALL manage mouse tracking and raw input through TerminalCore's lifecycle.

Acceptance Criteria

- Enabling and disabling mouse tracking emit matching control sequences.
- Terminal state is restored after line, password, key, and event operations finish or fail.

## Constraints

- Parsing remains byte-order deterministic and portable across declared platforms.

## Out of Scope

- Prompt presentation, layout, image protocols, and application view reconciliation.
