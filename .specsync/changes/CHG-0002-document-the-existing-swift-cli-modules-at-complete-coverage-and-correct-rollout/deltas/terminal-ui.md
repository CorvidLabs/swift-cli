## MODIFIED

### REQUIREMENT REQ-terminal-ui-001

View and ViewBuilder SHALL produce deterministic view trees from supported declarations and conditionals.

Acceptance Criteria
- Empty, single, optional, conditional, tuple, and collection content use their declared builder behavior.
- `ForEach` preserves source order and stable identity.
