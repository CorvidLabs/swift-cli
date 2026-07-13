---
module: terminal-input
version: 2
status: stable
files:
  - Sources/TerminalInput/InputEvent.swift
  - Sources/TerminalInput/InputReader.swift
  - Sources/TerminalInput/KeyCode.swift
  - Sources/TerminalInput/LineEditor.swift
  - Sources/TerminalInput/Modifiers.swift
  - Sources/TerminalInput/MouseEvent.swift
  - Sources/TerminalInput/Terminal+Input.swift


db_tables: []
depends_on:
  - specs/ansi/ansi.spec.md
  - specs/terminal-core/terminal-core.spec.md
  - specs/terminal-style/terminal-style.spec.md
---

# Terminal Input

## Purpose

`TerminalInput` converts terminal bytes into keyboard and mouse events, exposes async event reading through
`InputReader`, and provides editable line input. It owns escape-sequence parsing and modifier decoding while
TerminalCore owns the underlying stream and raw-mode lifecycle.

## Public API

The inventory covers key codes and modifier sets, input and mouse event values, parsers and readers, line-editor
configuration and editing, and Terminal convenience methods for keys, events, lines, passwords, and mouse tracking.

### Exported Functions

| Symbol |
|--------|
| `InputEvent` |
| `isKey` |
| `isMouse` |
| `keyCode` |
| `mouseEvent` |
| `isQuit` |
| `key` |
| `mouse` |
| `resize` |
| `focusGained` |
| `focusLost` |
| `pasteStart` |
| `pasteEnd` |
| `paste` |
| `InputReader` |
| `parse` |
| `init` |
| `KeyCode` |
| `Arrow` |
| `isControl` |
| `isPrintable` |
| `character` |
| `isEnter` |
| `isEscape` |
| `isBackspace` |
| `isTab` |
| `isInterrupt` |
| `isEOF` |
| `description` |
| `function` |
| `arrow` |
| `enter` |
| `tab` |
| `backspace` |
| `delete` |
| `escape` |
| `home` |
| `end` |
| `pageUp` |
| `pageDown` |
| `insert` |
| `ctrl` |
| `alt` |
| `unknown` |
| `up` |
| `down` |
| `left` |
| `right` |
| `LineEditor` |
| `prompt` |
| `maxHistorySize` |
| `readLine` |
| `getHistory` |
| `setHistory` |
| `clearHistory` |
| `Modifiers` |
| `rawValue` |
| `shift` |
| `control` |
| `meta` |
| `none` |
| `all` |
| `MouseEvent` |
| `action` |
| `button` |
| `column` |
| `row` |
| `modifiers` |
| `Action` |
| `Button` |
| `press` |
| `release` |
| `drag` |
| `move` |
| `scrollUp` |
| `scrollDown` |
| `middle` |
| `readKeyWithTimeout` |
| `readKey` |
| `readEvent` |
| `readPassword` |
| `readPasswordMasked` |
| `waitForKey` |
| `queryCursorPosition` |
### Exported Types

| Type | Description |
|------|-------------|

## Invariants

1. A complete recognized byte sequence produces exactly one semantic input event.
2. Printable Unicode, control keys, navigation keys, function keys, modifiers, and mouse reports retain their identity.
3. Partial escape sequences are buffered until complete or resolved by the reader's timing policy.
4. Secret line input does not echo the caller's plain-text characters.

## Behavioral Examples

- A printable scalar becomes a character key event; arrow escape sequences become their navigation key codes.
- A mouse report becomes a mouse event containing button, action, coordinates, and modifiers.
- The line editor applies insertion, deletion, cursor movement, history, and submission to its current buffer.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Input reaches end of stream | The reader terminates or returns the declared end-of-input error. |
| Escape bytes are malformed or unsupported | The parser preserves a safe unknown/escape interpretation without crashing. |
| Line validation fails | The editor reports the message and does not return an invalid line. |

## Dependencies

Consumes ANSI, TerminalCore, and TerminalStyle. TerminalComponents and TerminalUI consume its event and editing APIs.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured existing terminal input behavior for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
