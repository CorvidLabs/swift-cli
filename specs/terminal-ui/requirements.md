---
spec: terminal-ui.spec.md
---

# Requirements

### REQ-terminal-ui-001

View and ViewBuilder SHALL produce deterministic view trees from supported declarations and conditionals.

Acceptance Criteria
- Empty, single, optional, conditional, tuple, and collection content use their declared builder behavior.
- `ForEach` preserves source order and stable identity.

### REQ-terminal-ui-002

Stack, padding, and border views SHALL resolve children within available width and height without out-of-bounds writes.

Acceptance Criteria

- VStack, HStack, and ZStack honor axis, spacing, alignment, and child order.
- Padding and borders reduce child space and remain within the parent bounds.

### REQ-terminal-ui-003

RenderBuffer and RenderEngine SHALL preserve styled cells and produce the complete visible frame.

Acceptance Criteria

- Reads and writes outside allocated bounds are handled safely.
- Identical state and dimensions produce identical buffers.

### REQ-terminal-ui-004

DifferentialRenderer SHALL emit only changed regions while preserving the same visible result as a full render.

Acceptance Criteria

- Equal previous and next buffers emit no changed cell content.
- Changed spans position the cursor and render all changed cells in order.

### REQ-terminal-ui-005

App SHALL coordinate terminal setup, event processing, rendering, metrics, and restoration.

Acceptance Criteria

- Progress and spinner views render their current values deterministically.
- Normal exit, cancellation, and errors all attempt to restore terminal state.

## Constraints

- Rendering is bounded by current terminal metrics and follows declared platform availability.

## Out of Scope

- Persistent GUI windows, network state, and application-specific business logic.
