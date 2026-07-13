## MODIFIED

### REQUIREMENT REQ-terminal-style-001

StyledText SHALL preserve plain content while composing foreground, background, and text attributes immutably.

Acceptance Criteria
- Chained modifiers do not mutate a previously created value.
- Plain output equals the caller's original visible characters.
