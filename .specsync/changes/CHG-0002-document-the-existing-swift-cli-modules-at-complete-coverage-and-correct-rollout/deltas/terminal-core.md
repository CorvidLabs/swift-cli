## MODIFIED

### REQUIREMENT REQ-terminal-core-001

Terminal SHALL perform ordered writes and flushing through its configured output stream and surface failures.

Acceptance Criteria
- Written bytes retain caller order.
- Write and flush errors become typed terminal failures rather than success.
