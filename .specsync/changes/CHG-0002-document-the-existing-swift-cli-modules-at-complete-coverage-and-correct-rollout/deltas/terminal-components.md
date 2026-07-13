## MODIFIED

### REQUIREMENT REQ-terminal-components-001

Confirmation and text prompts SHALL honor their message, default, hint, secret, and validation configuration.

Acceptance Criteria
- Empty confirmation input uses the configured default when present.
- Secret input does not echo plain text and invalid input is requested again.
