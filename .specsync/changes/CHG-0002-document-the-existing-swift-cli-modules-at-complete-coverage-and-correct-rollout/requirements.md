---
change: CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout
artifact: requirements
---

# Requirements

## MODIFIED

### REQUIREMENT REQ-ansi-001
ANSI sequence builders SHALL return standards-shaped escape strings without performing terminal I/O.

Acceptance Criteria
- Cursor, erase, screen, report, hyperlink, and SGR helpers return their documented introducer and final byte.
- Calling a builder has no stream or global-state side effect.

### REQUIREMENT REQ-cli-001
The CLI product SHALL re-export all eight constituent Swift CLI library modules.

Acceptance Criteria
- A client importing `CLI` can reference ANSI, TerminalCore, TerminalStyle, TerminalInput, TerminalLayout,
  TerminalComponents, TerminalGraphics, and TerminalUI public APIs.
- The umbrella source adds no wrapper behavior or mutable state.

### REQUIREMENT REQ-terminal-components-001
Confirmation and text prompts SHALL honor their message, default, hint, secret, and validation configuration.

Acceptance Criteria
- Empty confirmation input uses the configured default when present.
- Secret input does not echo plain text and invalid input is requested again.

### REQUIREMENT REQ-terminal-core-001
Terminal SHALL perform ordered writes and flushing through its configured output stream and surface failures.

Acceptance Criteria
- Written bytes retain caller order.
- Write and flush errors become typed terminal failures rather than success.

### REQUIREMENT REQ-terminal-graphics-001
iTerm2Image SHALL encode image data and configured metadata in one valid OSC 1337 file payload.

Acceptance Criteria
- Data is base64 encoded and terminated by the protocol delimiter.
- Name, width, height, inline, and preserve-aspect-ratio fields appear only as configured.

### REQUIREMENT REQ-terminal-input-001
Input parsing SHALL convert complete printable, control, navigation, function, modifier, and mouse sequences into
their semantic event values.

Acceptance Criteria
- Printable Unicode produces character key events.
- Recognized escape and mouse reports preserve key/button, action, coordinates, and modifiers.

### REQUIREMENT REQ-terminal-layout-001
Box and Panel SHALL render configured border style, title, padding, alignment, and content within the resolved width.

Acceptance Criteria
- Every rendered border line uses matching corners, edges, and junctions.
- ANSI control bytes do not increase visible width.

### REQUIREMENT REQ-terminal-style-001
StyledText SHALL preserve plain content while composing foreground, background, and text attributes immutably.

Acceptance Criteria
- Chained modifiers do not mutate a previously created value.
- Plain output equals the caller's original visible characters.

### REQUIREMENT REQ-terminal-ui-001
View and ViewBuilder SHALL produce deterministic view trees from supported declarations and conditionals.

Acceptance Criteria
- Empty, single, optional, conditional, tuple, and collection content use their declared builder behavior.
- `ForEach` preserves source order and stable identity.
