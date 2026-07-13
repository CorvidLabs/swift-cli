## MODIFIED

### REQUIREMENT REQ-terminal-graphics-001

iTerm2Image SHALL encode image data and configured metadata in one valid OSC 1337 file payload.

Acceptance Criteria
- Data is base64 encoded and terminated by the protocol delimiter.
- Name, width, height, inline, and preserve-aspect-ratio fields appear only as configured.
