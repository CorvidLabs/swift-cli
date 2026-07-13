---
module: ansi
version: 2
status: stable
files:
  - Sources/ANSI/ANSI.swift
  - Sources/ANSI/BoxDrawing.swift
  - Sources/ANSI/Color.swift
  - Sources/ANSI/Cursor.swift
  - Sources/ANSI/Erase.swift
  - Sources/ANSI/Hyperlink.swift
  - Sources/ANSI/Report.swift
  - Sources/ANSI/Screen.swift
  - Sources/ANSI/Style.swift

db_tables: []
depends_on: []
---

# Ansi

## Purpose

`ANSI` provides dependency-free values and escape-sequence builders for terminal color, style, cursor movement,
screen control, erasure, hyperlinks, device reports, and box-drawing characters. It generates strings and does not
perform terminal I/O.

## Public API

The inventory below is generated from every public declaration in the nine mapped Swift files. Namespace members
produce standards-compliant control strings; color values cover named, indexed, RGB, hexadecimal, and color-cube
forms; and box-drawing values provide reusable Unicode glyph sets.

### Exported Types

| Type | Kind | Description |
|------|------|-------------|

### Exported Protocols

| Protocol | Description |
|----------|-------------|
| `Report` | Document caller-visible behavior and constraints. |
| `cursorPosition` | Document caller-visible behavior and constraints. |
| `deviceStatus` | Document caller-visible behavior and constraints. |
| `terminalId` | Document caller-visible behavior and constraints. |
| `secondaryDeviceAttributes` | Document caller-visible behavior and constraints. |
| `tertiaryDeviceAttributes` | Document caller-visible behavior and constraints. |
| `querySize` | Document caller-visible behavior and constraints. |
| `queryForeground` | Document caller-visible behavior and constraints. |
| `queryBackground` | Document caller-visible behavior and constraints. |
| `queryCursorColor` | Document caller-visible behavior and constraints. |
| `beginSynchronizedUpdate` | Document caller-visible behavior and constraints. |
| `endSynchronizedUpdate` | Document caller-visible behavior and constraints. |
| `Erase` | Document caller-visible behavior and constraints. |
| `screenFromCursor` | Document caller-visible behavior and constraints. |
| `screenToCursor` | Document caller-visible behavior and constraints. |
| `screen` | Document caller-visible behavior and constraints. |
| `screenAndScrollback` | Document caller-visible behavior and constraints. |
| `lineFromCursor` | Document caller-visible behavior and constraints. |
| `lineToCursor` | Document caller-visible behavior and constraints. |
| `line` | Document caller-visible behavior and constraints. |
| `characters` | Document caller-visible behavior and constraints. |
| `insertCharacters` | Document caller-visible behavior and constraints. |
| `insertLines` | Document caller-visible behavior and constraints. |
| `deleteLines` | Document caller-visible behavior and constraints. |
| `Hyperlink` | Document caller-visible behavior and constraints. |
| `link` | Document caller-visible behavior and constraints. |
| `start` | Document caller-visible behavior and constraints. |
| `end` | Document caller-visible behavior and constraints. |
| `file` | Document caller-visible behavior and constraints. |
| `Box` | Document caller-visible behavior and constraints. |
| `Single` | Document caller-visible behavior and constraints. |
| `horizontal` | Document caller-visible behavior and constraints. |
| `vertical` | Document caller-visible behavior and constraints. |
| `topLeft` | Document caller-visible behavior and constraints. |
| `topRight` | Document caller-visible behavior and constraints. |
| `bottomLeft` | Document caller-visible behavior and constraints. |
| `bottomRight` | Document caller-visible behavior and constraints. |
| `verticalRight` | Document caller-visible behavior and constraints. |
| `verticalLeft` | Document caller-visible behavior and constraints. |
| `horizontalDown` | Document caller-visible behavior and constraints. |
| `horizontalUp` | Document caller-visible behavior and constraints. |
| `cross` | Document caller-visible behavior and constraints. |
| `Double` | Document caller-visible behavior and constraints. |
| `Rounded` | Document caller-visible behavior and constraints. |
| `Heavy` | Document caller-visible behavior and constraints. |
| `ASCII` | Document caller-visible behavior and constraints. |
| `Block` | Document caller-visible behavior and constraints. |
| `full` | Document caller-visible behavior and constraints. |
| `sevenEighths` | Document caller-visible behavior and constraints. |
| `threeQuarters` | Document caller-visible behavior and constraints. |
| `fiveEighths` | Document caller-visible behavior and constraints. |
| `half` | Document caller-visible behavior and constraints. |
| `threeEighths` | Document caller-visible behavior and constraints. |
| `quarter` | Document caller-visible behavior and constraints. |
| `eighth` | Document caller-visible behavior and constraints. |
| `lightShade` | Document caller-visible behavior and constraints. |
| `mediumShade` | Document caller-visible behavior and constraints. |
| `darkShade` | Document caller-visible behavior and constraints. |
| `upperHalf` | Document caller-visible behavior and constraints. |
| `lowerHalf` | Document caller-visible behavior and constraints. |
| `leftHalf` | Document caller-visible behavior and constraints. |
| `rightHalf` | Document caller-visible behavior and constraints. |
| `horizontalSegments` | Document caller-visible behavior and constraints. |
| `verticalSegments` | Document caller-visible behavior and constraints. |
| `Spinner` | Document caller-visible behavior and constraints. |
| `dots` | Document caller-visible behavior and constraints. |
| `growingDots` | Document caller-visible behavior and constraints. |
| `circle` | Document caller-visible behavior and constraints. |
| `arc` | Document caller-visible behavior and constraints. |
| `box` | Document caller-visible behavior and constraints. |
| `arrow` | Document caller-visible behavior and constraints. |
| `bounce` | Document caller-visible behavior and constraints. |
| `clock` | Document caller-visible behavior and constraints. |
| `Symbol` | Document caller-visible behavior and constraints. |
| `checkmark` | Document caller-visible behavior and constraints. |
| `bullet` | Document caller-visible behavior and constraints. |
| `arrowRight` | Document caller-visible behavior and constraints. |
| `arrowLeft` | Document caller-visible behavior and constraints. |
| `arrowUp` | Document caller-visible behavior and constraints. |
| `arrowDown` | Document caller-visible behavior and constraints. |
| `ellipsis` | Document caller-visible behavior and constraints. |
| `info` | Document caller-visible behavior and constraints. |
| `warning` | Document caller-visible behavior and constraints. |
| `star` | Document caller-visible behavior and constraints. |
| `starOutline` | Document caller-visible behavior and constraints. |
| `heart` | Document caller-visible behavior and constraints. |
| `diamond` | Document caller-visible behavior and constraints. |
| `circleOutline` | Document caller-visible behavior and constraints. |
| `square` | Document caller-visible behavior and constraints. |
| `squareOutline` | Document caller-visible behavior and constraints. |
| `triangleRight` | Document caller-visible behavior and constraints. |
| `triangleLeft` | Document caller-visible behavior and constraints. |
| `triangleUp` | Document caller-visible behavior and constraints. |
| `triangleDown` | Document caller-visible behavior and constraints. |
| `ANSI` | Document caller-visible behavior and constraints. |
| `escape` | Document caller-visible behavior and constraints. |
| `ESC` | Document caller-visible behavior and constraints. |
| `CSI` | Document caller-visible behavior and constraints. |
| `OSC` | Document caller-visible behavior and constraints. |
| `DCS` | Document caller-visible behavior and constraints. |
| `ST` | Document caller-visible behavior and constraints. |
| `BEL` | Document caller-visible behavior and constraints. |
| `BS` | Document caller-visible behavior and constraints. |
| `HT` | Document caller-visible behavior and constraints. |
| `LF` | Document caller-visible behavior and constraints. |
| `CR` | Document caller-visible behavior and constraints. |
| `Screen` | Document caller-visible behavior and constraints. |
| `enterAlternate` | Document caller-visible behavior and constraints. |
| `exitAlternate` | Document caller-visible behavior and constraints. |
| `enterAlternateSaveCursor` | Document caller-visible behavior and constraints. |
| `enableLineWrap` | Document caller-visible behavior and constraints. |
| `disableLineWrap` | Document caller-visible behavior and constraints. |
| `title` | Document caller-visible behavior and constraints. |
| `titleST` | Document caller-visible behavior and constraints. |
| `iconName` | Document caller-visible behavior and constraints. |
| `windowTitle` | Document caller-visible behavior and constraints. |
| `enableBracketedPaste` | Document caller-visible behavior and constraints. |
| `disableBracketedPaste` | Document caller-visible behavior and constraints. |
| `enableFocusEvents` | Document caller-visible behavior and constraints. |
| `disableFocusEvents` | Document caller-visible behavior and constraints. |
| `MouseMode` | Document caller-visible behavior and constraints. |
| `enableMouse` | Document caller-visible behavior and constraints. |
| `disableMouse` | Document caller-visible behavior and constraints. |
| `enableSGRMouse` | Document caller-visible behavior and constraints. |
| `disableSGRMouse` | Document caller-visible behavior and constraints. |
| `softReset` | Document caller-visible behavior and constraints. |
| `normal` | Document caller-visible behavior and constraints. |
| `buttonEvent` | Document caller-visible behavior and constraints. |
| `anyEvent` | Document caller-visible behavior and constraints. |
| `Style` | Document caller-visible behavior and constraints. |
| `reset` | Document caller-visible behavior and constraints. |
| `bold` | Document caller-visible behavior and constraints. |
| `dim` | Document caller-visible behavior and constraints. |
| `italic` | Document caller-visible behavior and constraints. |
| `underline` | Document caller-visible behavior and constraints. |
| `blink` | Document caller-visible behavior and constraints. |
| `rapidBlink` | Document caller-visible behavior and constraints. |
| `reverse` | Document caller-visible behavior and constraints. |
| `hidden` | Document caller-visible behavior and constraints. |
| `strikethrough` | Document caller-visible behavior and constraints. |
| `noBold` | Document caller-visible behavior and constraints. |
| `noItalic` | Document caller-visible behavior and constraints. |
| `noUnderline` | Document caller-visible behavior and constraints. |
| `noBlink` | Document caller-visible behavior and constraints. |
| `noReverse` | Document caller-visible behavior and constraints. |
| `noHidden` | Document caller-visible behavior and constraints. |
| `noStrikethrough` | Document caller-visible behavior and constraints. |
| `doubleUnderline` | Document caller-visible behavior and constraints. |
| `curlyUnderline` | Document caller-visible behavior and constraints. |
| `dottedUnderline` | Document caller-visible behavior and constraints. |
| `dashedUnderline` | Document caller-visible behavior and constraints. |
| `foreground` | Document caller-visible behavior and constraints. |
| `foregroundDefault` | Document caller-visible behavior and constraints. |
| `background` | Document caller-visible behavior and constraints. |
| `backgroundDefault` | Document caller-visible behavior and constraints. |
| `underlineColor` | Document caller-visible behavior and constraints. |
| `underlineColorDefault` | Document caller-visible behavior and constraints. |
| `combined` | Document caller-visible behavior and constraints. |
| `Cursor` | Document caller-visible behavior and constraints. |
| `up` | Document caller-visible behavior and constraints. |
| `down` | Document caller-visible behavior and constraints. |
| `forward` | Document caller-visible behavior and constraints. |
| `backward` | Document caller-visible behavior and constraints. |
| `nextLine` | Document caller-visible behavior and constraints. |
| `previousLine` | Document caller-visible behavior and constraints. |
| `column` | Document caller-visible behavior and constraints. |
| `position` | Document caller-visible behavior and constraints. |
| `moveTo` | Document caller-visible behavior and constraints. |
| `home` | Document caller-visible behavior and constraints. |
| `hide` | Document caller-visible behavior and constraints. |
| `show` | Document caller-visible behavior and constraints. |
| `save` | Document caller-visible behavior and constraints. |
| `restore` | Document caller-visible behavior and constraints. |
| `saveSCO` | Document caller-visible behavior and constraints. |
| `restoreSCO` | Document caller-visible behavior and constraints. |
| `Shape` | Document caller-visible behavior and constraints. |
| `shape` | Document caller-visible behavior and constraints. |
| `scrollUp` | Document caller-visible behavior and constraints. |
| `scrollDown` | Document caller-visible behavior and constraints. |
| `setScrollRegion` | Document caller-visible behavior and constraints. |
| `resetScrollRegion` | Document caller-visible behavior and constraints. |
| `requestPosition` | Document caller-visible behavior and constraints. |
| `blinkingBlock` | Document caller-visible behavior and constraints. |
| `steadyBlock` | Document caller-visible behavior and constraints. |
| `blinkingUnderline` | Document caller-visible behavior and constraints. |
| `steadyUnderline` | Document caller-visible behavior and constraints. |
| `blinkingBar` | Document caller-visible behavior and constraints. |
| `steadyBar` | Document caller-visible behavior and constraints. |
| `Color16` | Document caller-visible behavior and constraints. |
| `gray` | Document caller-visible behavior and constraints. |
| `grey` | Document caller-visible behavior and constraints. |
| `foregroundCode` | Document caller-visible behavior and constraints. |
| `backgroundCode` | Document caller-visible behavior and constraints. |
| `Color256` | Document caller-visible behavior and constraints. |
| `index` | Document caller-visible behavior and constraints. |
| `cube` | Document caller-visible behavior and constraints. |
| `grayscale` | Document caller-visible behavior and constraints. |
| `black` | Document caller-visible behavior and constraints. |
| `red` | Document caller-visible behavior and constraints. |
| `green` | Document caller-visible behavior and constraints. |
| `yellow` | Document caller-visible behavior and constraints. |
| `blue` | Document caller-visible behavior and constraints. |
| `magenta` | Document caller-visible behavior and constraints. |
| `cyan` | Document caller-visible behavior and constraints. |
| `white` | Document caller-visible behavior and constraints. |
| `TrueColor` | Document caller-visible behavior and constraints. |
| `orange` | Document caller-visible behavior and constraints. |
| `pink` | Document caller-visible behavior and constraints. |
| `purple` | Document caller-visible behavior and constraints. |
| `Color` | Document caller-visible behavior and constraints. |
| `rgb` | Document caller-visible behavior and constraints. |
| `hex` | Document caller-visible behavior and constraints. |
| `palette` | Document caller-visible behavior and constraints. |
| `brightBlack` | Document caller-visible behavior and constraints. |
| `brightRed` | Document caller-visible behavior and constraints. |
| `brightGreen` | Document caller-visible behavior and constraints. |
| `brightYellow` | Document caller-visible behavior and constraints. |
| `brightBlue` | Document caller-visible behavior and constraints. |
| `brightMagenta` | Document caller-visible behavior and constraints. |
| `brightCyan` | Document caller-visible behavior and constraints. |
| `brightWhite` | Document caller-visible behavior and constraints. |
| `init` | Document caller-visible behavior and constraints. |
| `standard` | Document caller-visible behavior and constraints. |

## Invariants

1. ANSI builders are pure: constructing a sequence never reads from or writes to a terminal.
2. SGR sequences begin with CSI and end with `m`; cursor, erase, screen, and report helpers use their defined final byte.
3. Indexed colors remain in `0...255`, RGB channels remain in `0...255`, and hexadecimal parsing accepts six-digit RGB.
4. Style composition preserves caller order so later SGR parameters retain their standard override behavior.

## Behavioral Examples

- **Given** a named foreground color, **when** it is rendered, **then** the result is the matching SGR escape sequence.
- **Given** an RGB or hexadecimal color, **when** foreground or background output is requested, **then** all three
  channel values are encoded in the true-color sequence.
- **Given** a cursor movement or erase request, **when** its helper is called, **then** the requested count or scope is
  encoded without side effects.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Invalid hexadecimal RGB text | The failable color initializer returns `nil`. |
| Channel or palette input outside its representable domain | Initializers clamp or reject according to the declared API. |
| Terminal lacks support for a generated sequence | The module still returns the sequence; capability decisions belong to `TerminalCore`. |

## Dependencies

Consumes only the Swift standard library. It is consumed by every higher-level Swift CLI module that renders or
controls a terminal.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured the existing ANSI contract for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
