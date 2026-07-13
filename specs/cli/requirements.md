---
spec: cli.spec.md
---

# Requirements

### REQ-cli-001

The CLI product SHALL re-export all eight constituent Swift CLI library modules.

Acceptance Criteria
- A client importing `CLI` can reference ANSI, TerminalCore, TerminalStyle, TerminalInput, TerminalLayout,
  TerminalComponents, TerminalGraphics, and TerminalUI public APIs.
- The umbrella source adds no wrapper behavior or mutable state.

### REQ-cli-002

The umbrella SHALL preserve each constituent module's platform availability and error behavior.

Acceptance Criteria

- Importing CLI does not weaken or replace a lower-level module contract.
- Compilation succeeds on the platforms declared by `Package.swift` when the selected lower-level API is available.

## Constraints

- `Sources/CLI/SwiftCLI.swift` remains an exported-import surface only.

## Out of Scope

- Independent runtime behavior, configuration, I/O, or error types.
