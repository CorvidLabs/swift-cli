## MODIFIED

### REQUIREMENT REQ-cli-001

The CLI product SHALL re-export all eight constituent Swift CLI library modules.

Acceptance Criteria
- A client importing `CLI` can reference ANSI, TerminalCore, TerminalStyle, TerminalInput, TerminalLayout,
  TerminalComponents, TerminalGraphics, and TerminalUI public APIs.
- The umbrella source adds no wrapper behavior or mutable state.
