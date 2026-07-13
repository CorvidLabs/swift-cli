---
spec: terminal-core.spec.md
---

# Requirements

### REQ-terminal-core-001

Terminal SHALL perform ordered writes and flushing through its configured output stream and surface failures.

Acceptance Criteria
- Written bytes retain caller order.
- Write and flush errors become typed terminal failures rather than success.

### REQ-terminal-core-002

Terminal raw-mode and alternate-screen operations SHALL be reversible on every supported platform.

Acceptance Criteria

- A successful enter operation has a matching restore operation.
- Teardown attempts restoration after normal use and error paths.

### REQ-terminal-core-003

Size and capability discovery SHALL return detected values or documented conservative fallbacks.

Acceptance Criteria

- TerminalSize reports columns and rows with stable defaults when discovery is unavailable.
- Color depth and feature flags do not assert unsupported capabilities without evidence.

### REQ-terminal-core-004

TerminalConfiguration, Logger, and TerminalError SHALL expose deterministic caller-visible values.

Acceptance Criteria

- Default configuration properties match their documented defaults.
- Every public terminal error has a useful localized description.

## Constraints

- Platform branches remain available for declared Apple, Linux, and Windows targets.
- Shared concurrent state uses the package's existing atomic synchronization.

## Out of Scope

- Event parsing, styled text, layout, components, images, and view composition.
