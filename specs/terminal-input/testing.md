---
spec: terminal-input.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `Tests/TerminalInputTests/TerminalInputTests.swift` | REQ-terminal-input-001, REQ-terminal-input-002, REQ-terminal-input-003, REQ-terminal-input-004 | Key codes and descriptions, modifiers, printable/control/escape/arrow parsing, mouse values, and line-editor configuration. |

## Manual Testing

Raw keyboard, mouse tracking, history, cancellation, and secret echo behavior should be exercised on a real TTY before
behavioral changes; governance-only changes use native and hosted verification.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Escape sequence arrives in fragments | Reader waits for a complete interpretation. |
| Secret input is edited | Plain-text characters are not echoed. |
| End of stream occurs | The reader terminates through its declared API. |
