## MODIFIED

### REQUIREMENT REQ-ansi-001

ANSI sequence builders SHALL return standards-shaped escape strings without performing terminal I/O.

Acceptance Criteria
- Cursor, erase, screen, report, hyperlink, and SGR helpers return their documented introducer and final byte.
- Calling a builder has no stream or global-state side effect.
