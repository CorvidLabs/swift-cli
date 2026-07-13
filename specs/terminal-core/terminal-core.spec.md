---
module: terminal-core
version: 2
status: stable
files:
  - Sources/TerminalCore/Logger.swift
  - Sources/TerminalCore/Terminal.swift
  - Sources/TerminalCore/TerminalCapabilities.swift
  - Sources/TerminalCore/TerminalConfiguration.swift
  - Sources/TerminalCore/TerminalError.swift
  - Sources/TerminalCore/TerminalSize.swift


db_tables: []
depends_on:
  - specs/ansi/ansi.spec.md
---

# Terminal Core

## Purpose

`TerminalCore` owns terminal streams, raw-mode lifecycle, size and capability discovery, configuration, logging, and
the shared error model. It is the only package layer that performs low-level terminal I/O.

## Public API

The inventory includes `Terminal`, configuration and size values, capability and color-depth reporting, logger
configuration, raw-mode and alternate-screen control, writing/flushing, and portable terminal errors.

### Exported Functions

| Symbol |
|--------|
| `debugLog` |
| `Terminal` |
| `shared` |
| `capabilities` |
| `configuration` |
| `write` |
| `writeLine` |
| `writeError` |
| `flush` |
| `beginBuffering` |
| `endBuffering` |
| `buffered` |
| `refreshSize` |
| `moveCursor` |
| `moveCursorHome` |
| `hideCursor` |
| `showCursor` |
| `saveCursor` |
| `restoreCursor` |
| `clearScreen` |
| `clearToEndOfScreen` |
| `clearLine` |
| `clearToEndOfLine` |
| `enterAlternateScreen` |
| `exitAlternateScreen` |
| `setTitle` |
| `enableRawMode` |
| `disableRawMode` |
| `waitForInput` |
| `hasInput` |
| `readByte` |
| `readBytes` |
| `enableMouse` |
| `disableMouse` |
| `reset` |
| `startResizeMonitoring` |
| `stopResizeMonitoring` |
| `checkResize` |
| `init` |
| `TerminalCapabilities` |
| `colorDepth` |
| `supportsUnicode` |
| `supportsMouse` |
| `supportsAlternateScreen` |
| `supportsHyperlinks` |
| `supportsSynchronizedOutput` |
| `supportsTrueColor` |
| `imageProtocol` |
| `terminalProgram` |
| `terminalVersion` |
| `isTTY` |
| `isCI` |
| `ColorDepth` |
| `ImageProtocol` |
| `detect` |
| `none` |
| `basic` |
| `palette256` |
| `trueColor` |
| `iterm2` |
| `kitty` |
| `sixel` |
| `TerminalConfiguration` |
| `colorMode` |
| `forceColor` |
| `useUnicode` |
| `useAlternateScreen` |
| `fullscreen` |
| `minimal` |
| `ColorMode` |
| `auto` |
| `TerminalError` |
| `errorDescription` |
| `rawModeFailure` |
| `sizeDetectionFailure` |
| `inputError` |
| `outputError` |
| `unsupportedCapability` |
| `imageEncodingError` |
| `invalidEscapeSequence` |
| `timeout` |
| `platformUnavailable` |
| `notATTY` |
| `cancelled` |
| `TerminalSize` |
| `columns` |
| `rows` |
| `pixelWidth` |
| `pixelHeight` |
| `width` |
| `height` |
| `area` |
### Exported Types

| Type | Description |
|------|-------------|

## Invariants

1. Terminal configuration defaults are deterministic and can be replaced explicitly by callers.
2. Entered raw mode and alternate-screen state can be restored on every supported platform.
3. Capability queries report conservative values when the environment cannot prove support.
4. Output methods preserve byte order and expose write or flush failures as `TerminalError`.

## Behavioral Examples

- Constructing a terminal with default configuration produces the documented input, output, color, and logging policy.
- Reading terminal size returns detected columns and rows, or the module's safe fallback when discovery is unavailable.
- Entering raw mode disables canonical input until restoration is requested or the owning terminal is torn down.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Standard streams are not terminals | Capability and size discovery return conservative results or a typed error. |
| Raw-mode setup or restoration fails | A `TerminalError` describing the system operation is returned. |
| Write or flush fails | The I/O failure is surfaced instead of being treated as success. |

## Dependencies

Consumes ANSI plus Swift system facilities and Atomics. Every input, style, layout, component, graphics, and UI
module consumes TerminalCore.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured existing terminal runtime behavior for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
