---
spec: terminal-ui.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `Tests/TerminalUITests/TerminalUITests.swift` | REQ-terminal-ui-001, REQ-terminal-ui-002, REQ-terminal-ui-003, REQ-terminal-ui-004, REQ-terminal-ui-005 | ViewBuilder, Text, stacks, ForEach, padding, borders, nested and snapshot rendering, buffers, diffs, spinners, progress, and visible length. |

## Manual Testing

Application-loop input, resize, cancellation, and terminal restoration should be exercised on a real TTY before
behavioral changes; snapshots plus hosted platform checks protect this governance migration.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Available size is zero | Rendering is empty and remains in bounds. |
| Previous and next buffers are equal | Differential renderer emits no changed content. |
| App exits through an error | Terminal restoration is still attempted. |
