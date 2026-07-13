---
change: CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout
artifact: testing
---

# Testing

## Native Evidence

- `Tests/ANSITests/ANSITests.swift`: REQ-ansi-001 through REQ-ansi-004.
- Complete package build/test graph: REQ-cli-001 and REQ-cli-002.
- `Tests/TerminalComponentsTests/TerminalComponentsTests.swift`: REQ-terminal-components-001 through
  REQ-terminal-components-004.
- `Tests/TerminalCoreTests/TerminalCoreTests.swift`: REQ-terminal-core-001 through REQ-terminal-core-004.
- `Tests/TerminalGraphicsTests/TerminalGraphicsTests.swift`: REQ-terminal-graphics-001 through
  REQ-terminal-graphics-004.
- `Tests/TerminalInputTests/TerminalInputTests.swift`: REQ-terminal-input-001 through REQ-terminal-input-004.
- `Tests/TerminalLayoutTests/TerminalLayoutTests.swift`: REQ-terminal-layout-001 through REQ-terminal-layout-004.
- `Tests/TerminalStyleTests/TerminalStyleTests.swift`: REQ-terminal-style-001 through REQ-terminal-style-004.
- `Tests/TerminalUITests/TerminalUITests.swift`: REQ-terminal-ui-001 through REQ-terminal-ui-005.

## Verification Commands

- `specsync check --strict --require-coverage 100 --force`
- `specsync agents status`
- `swift test`
- `fledge trust doctor`
- `fledge trust verify`

Results are recorded by the lifecycle verification command after definition approval and implementation start.
