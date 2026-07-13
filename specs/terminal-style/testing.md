---
spec: terminal-style.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `Tests/TerminalStyleTests/TerminalStyleTests.swift` | REQ-terminal-style-001, REQ-terminal-style-002, REQ-terminal-style-003, REQ-terminal-style-004 | StyledText rendering/chaining, String conveniences, plain content, concatenation, themes, and gradients. |

## Manual Testing

No separate manual flow is needed for governance; run native tests with color enabled and disabled before behavioral
rendering changes.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Styling is disabled | Plain visible text is returned. |
| Differently styled values concatenate | Segment order and independent attributes are preserved. |
| Gradient has endpoint positions | First and last colors equal configured endpoints. |
