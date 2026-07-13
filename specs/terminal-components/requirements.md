---
spec: terminal-components.spec.md
---

# Requirements

### REQ-terminal-components-001

Confirmation and text prompts SHALL honor their message, default, hint, secret, and validation configuration.

Acceptance Criteria
- Empty confirmation input uses the configured default when present.
- Secret input does not echo plain text and invalid input is requested again.

### REQ-terminal-components-002

Single- and multi-selection SHALL preserve option order and enforce defaults and selection bounds.

Acceptance Criteria

- Navigation and submission return the selected option values.
- Multi-select cannot complete below its minimum or above its maximum selection count.

### REQ-terminal-components-003

ProgressBar SHALL render its configured style and bounded progress state.

Acceptance Criteria

- Presets provide stable caps, filled/empty cells, colors, and width behavior.
- Update, increment, and finish never render progress beyond the configured total.

### REQ-terminal-components-004

Spinner SHALL animate configured frames and restore a complete status line when stopped.

Acceptance Criteria

- Preset frame sequences and intervals remain stable.
- Success, failure, warning, and information helpers render the corresponding terminal status.

## Constraints

- Components use TerminalCore I/O and TerminalInput parsing rather than opening independent streams.

## Out of Scope

- General-purpose declarative UI layout and application lifecycle.
