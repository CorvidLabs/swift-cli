---
spec: terminal-core.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `Tests/TerminalCoreTests/TerminalCoreTests.swift` | REQ-terminal-core-001, REQ-terminal-core-002, REQ-terminal-core-003, REQ-terminal-core-004 | Size values and fallbacks, configuration defaults, error descriptions, capability and color-depth values. |

## Manual Testing

Raw-mode, alternate-screen, and stream restoration require the hosted platform matrix or a real TTY in addition to
deterministic unit tests.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Size discovery is unavailable | Safe documented columns and rows are returned. |
| Stream is not a TTY | Capabilities remain conservative. |
| Restoration follows an error | The terminal attempts to restore its prior mode. |
