## MODIFIED

### REQUIREMENT REQ-terminal-input-001

Input parsing SHALL convert complete printable, control, navigation, function, modifier, and mouse sequences into
their semantic event values.

Acceptance Criteria
- Printable Unicode produces character key events.
- Recognized escape and mouse reports preserve key/button, action, coordinates, and modifiers.
