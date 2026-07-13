---
module: terminal-style
version: 2
status: stable
files:
  - Sources/TerminalStyle/Gradient.swift
  - Sources/TerminalStyle/String+Style.swift
  - Sources/TerminalStyle/StyledText.swift
  - Sources/TerminalStyle/Terminal+Style.swift
  - Sources/TerminalStyle/Theme.swift


db_tables: []
depends_on:
  - specs/ansi/ansi.spec.md
  - specs/terminal-core/terminal-core.spec.md
---

# Terminal Style

## Purpose

`TerminalStyle` provides immutable, chainable styled text, string conveniences, themes, and gradients. It translates
semantic colors and attributes into ANSI output while retaining plain content and visible-width behavior.

## Public API

The inventory covers `StyledText` construction, composition and rendering, foreground/background and attribute
modifiers, String conveniences, theme palettes, gradient interpolation, and Terminal styled-output helpers.

### Exported Functions

| Symbol |
|--------|
| `Gradient` |
| `start` |
| `end` |
| `color` |
| `apply` |
| `rainbow` |
| `sunset` |
| `ocean` |
| `forest` |
| `fire` |
| `ice` |
| `MultiGradient` |
| `stops` |
| `pastel` |
| `gradient` |
| `init` |
| `bold` |
| `dim` |
| `italic` |
| `underline` |
| `blink` |
| `reverse` |
| `hidden` |
| `strikethrough` |
| `black` |
| `red` |
| `green` |
| `yellow` |
| `blue` |
| `magenta` |
| `cyan` |
| `white` |
| `gray` |
| `grey` |
| `brightBlack` |
| `brightRed` |
| `brightGreen` |
| `brightYellow` |
| `brightBlue` |
| `brightMagenta` |
| `brightCyan` |
| `brightWhite` |
| `onBlack` |
| `onRed` |
| `onGreen` |
| `onYellow` |
| `onBlue` |
| `onMagenta` |
| `onCyan` |
| `onWhite` |
| `foreground` |
| `background` |
| `rgb` |
| `hex` |
| `onRGB` |
| `onHex` |
| `link` |
| `styled` |
| `StyledText` |
| `content` |
| `styles` |
| `url` |
| `children` |
| `TextStyle` |
| `Builder` |
| `buildBlock` |
| `buildExpression` |
| `buildOptional` |
| `buildEither` |
| `buildArray` |
| `style` |
| `render` |
| `description` |
| `plainText` |
| `length` |
| `+` |
| `write` |
| `writeLine` |
| `success` |
| `error` |
| `warning` |
| `info` |
| `Theme` |
| `primary` |
| `secondary` |
| `muted` |
| `highlight` |
| `panelBackground` |
| `border` |
| `minimal` |
| `vibrant` |
### Exported Types

| Type | Description |
|------|-------------|

## Invariants

1. Chaining style modifiers retains the underlying plain string.
2. Rendering applies configured ANSI prefixes and a reset without changing visible text.
3. Concatenation preserves each segment's style and caller order.
4. Gradient interpolation produces the requested number of color positions with stable endpoints.

## Behavioral Examples

- Styling a string red and bold renders both attributes around the original text and resets afterward.
- Concatenating differently styled segments preserves their independent renderings and plain combined value.
- A theme maps semantic roles such as primary, success, warning, and error to its configured styles.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Color output is disabled by terminal policy | Styled output degrades to plain text. |
| A gradient receives insufficient positions or colors | The API returns its documented empty or endpoint-safe result. |
| Terminal output fails | TerminalCore's error is propagated. |

## Dependencies

Consumes ANSI and TerminalCore. Input, layout, components, TerminalUI, and CLI consume its styled-text model.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured existing styling behavior for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
