---
module: terminal-components
version: 2
status: stable
files:
  - Sources/TerminalComponents/Confirm.swift
  - Sources/TerminalComponents/Input.swift
  - Sources/TerminalComponents/MultiSelect.swift
  - Sources/TerminalComponents/ProgressBar.swift
  - Sources/TerminalComponents/Select.swift
  - Sources/TerminalComponents/Spinner.swift


db_tables: []
depends_on:
  - specs/ansi/ansi.spec.md
  - specs/terminal-core/terminal-core.spec.md
  - specs/terminal-input/terminal-input.spec.md
  - specs/terminal-style/terminal-style.spec.md
---

# Terminal Components

## Purpose

`TerminalComponents` supplies synchronous interactive building blocks: confirmation and text prompts, single- and
multi-selection, progress bars, and spinners. Components compose terminal I/O, styled rendering, and input parsing
while keeping configuration in explicit value types.

## Public API

The complete inventory covers prompt configuration and execution, selectable options and selection bounds, progress
styles and lifecycle, and spinner frames, status transitions, and convenience presets.

### Exported Functions

| Symbol |
|--------|
| `Confirm` |
| `message` |
| `defaultValue` |
| `hint` |
| `run` |
| `confirm` |
| `init` |
| `Input` |
| `placeholder` |
| `isSecret` |
| `validate` |
| `input` |
| `secret` |
| `MultiSelect` |
| `options` |
| `defaultSelected` |
| `minSelections` |
| `maxSelections` |
| `Option` |
| `label` |
| `value` |
| `description` |
| `multiSelect` |
| `ProgressBar` |
| `total` |
| `style` |
| `width` |
| `showPercentage` |
| `showValue` |
| `Style` |
| `filled` |
| `empty` |
| `leftCap` |
| `rightCap` |
| `filledColor` |
| `emptyColor` |
| `blocks` |
| `shades` |
| `classic` |
| `dots` |
| `arrows` |
| `squares` |
| `update` |
| `increment` |
| `start` |
| `finish` |
| `withProgress` |
| `Select` |
| `defaultIndex` |
| `select` |
| `Spinner` |
| `interval` |
| `frames` |
| `line` |
| `growingDots` |
| `circle` |
| `arc` |
| `box` |
| `arrow` |
| `bounce` |
| `clock` |
| `simple` |
| `dots2` |
| `hamburger` |
| `earth` |
| `moon` |
| `success` |
| `fail` |
| `warn` |
| `info` |
| `stop` |
| `withSpinner` |
### Exported Types

| Type | Description |
|------|-------------|

## Invariants

1. Prompt defaults and selection bounds are honored without silently changing caller-provided options.
2. Secret input does not echo plain text through the component API.
3. Progress values remain bounded by their configured total and finish renders the completed state.
4. Starting and stopping a spinner restores a usable terminal line and status helpers render their declared outcome.

## Behavioral Examples

- A confirmation prompt accepts its configured default when the user submits an empty response.
- A progress bar with a preset style renders its caps, filled and empty cells, and optional value/percentage labels.
- A spinner cycles through its configured frames until stopped, then writes the requested success, failure, warning,
  or information status.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Prompt input fails validation | The component reports the validation message and requests input again. |
| Selection count is outside configured bounds | Multi-select remains active until a permitted count is submitted. |
| Terminal input or output fails | The underlying terminal error is propagated. |

## Dependencies

Consumes ANSI, TerminalCore, TerminalInput, and TerminalStyle. It is re-exported by CLI and used by command-line
applications needing ready-made interactions.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured existing interactive component behavior for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
