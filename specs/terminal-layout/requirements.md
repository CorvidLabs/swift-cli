---
spec: terminal-layout.spec.md
---

# Requirements

### REQ-terminal-layout-001

Box and Panel SHALL render configured border style, title, padding, alignment, and content within the resolved width.

Acceptance Criteria
- Every rendered border line uses matching corners, edges, and junctions.
- ANSI control bytes do not increase visible width.

### REQ-terminal-layout-002

Table SHALL resolve stable column widths and align headers and cells according to column configuration.

Acceptance Criteria

- Rows use a consistent column layout within one table.
- Missing cells render empty and constrained content follows the existing truncation or wrapping policy.

### REQ-terminal-layout-003

Divider SHALL fill available width while placing an optional title according to its alignment.

Acceptance Criteria

- Untitled dividers contain only the selected line glyph.
- A title and its spacing do not exceed the resolved width.

### REQ-terminal-layout-004

Tree SHALL render recursive nodes with connectors that distinguish intermediate and final children.

Acceptance Criteria

- Source child order is preserved.
- Nested continuation guides remain aligned with their ancestors.

## Constraints

- Visible-width calculations account for ANSI styling.

## Out of Scope

- Terminal input, persistent screen diffing, and application event loops.
