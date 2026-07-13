---
module: terminal-graphics
version: 2
status: stable
files:
  - Sources/TerminalGraphics/ITerm2Image.swift
  - Sources/TerminalGraphics/ImageProtocol.swift
  - Sources/TerminalGraphics/KittyImage.swift
  - Sources/TerminalGraphics/SixelImage.swift
  - Sources/TerminalGraphics/TerminalImage.swift


db_tables: []
depends_on:
  - specs/ansi/ansi.spec.md
  - specs/terminal-core/terminal-core.spec.md
---

# Terminal Graphics

## Purpose

`TerminalGraphics` encodes image data for iTerm2, Kitty, and Sixel-capable terminals and selects an available protocol
through `TerminalImage`. It owns encoding and escape framing, not image decoding or terminal capability policy.

## Public API

The inventory covers the shared image protocol and size model, protocol-specific configuration and rendering, Kitty
chunking, iTerm2 metadata, Sixel encoding, and automatic protocol selection.

### Exported Functions

| Symbol |
|--------|
| `ITerm2Image` |
| `data` |
| `config` |
| `name` |
| `render` |
| `init` |
| `TerminalImageProtocol` |
| `ImageSize` |
| `ImageConfig` |
| `width` |
| `height` |
| `preserveAspectRatio` |
| `inline` |
| `auto` |
| `cells` |
| `percent` |
| `pixels` |
| `KittyImage` |
| `format` |
| `Format` |
| `rgb` |
| `rgba` |
| `png` |
| `SixelImage` |
| `sixelData` |
| `SixelEncoder` |
| `encode` |
| `TerminalImage` |
| `imageProtocol` |
| `renderImage` |
### Exported Types

| Type | Description |
|------|-------------|

## Invariants

1. Rendered image payloads use the selected terminal protocol's framing and encoded data format.
2. Kitty payloads are chunked with correct continuation markers and retain their image identifier.
3. Optional dimensions, names, placement, and preservation flags are emitted only when configured.
4. Automatic rendering does not claim support for a protocol absent from detected terminal capabilities.

## Behavioral Examples

- An iTerm2 image renders as one OSC 1337 file payload containing optional name and dimension metadata.
- A large Kitty image renders as ordered chunks whose continuation flag is clear only on the final chunk.
- `TerminalImage` selects the best supported encoder while explicit protocol wrappers remain caller-selectable.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| No supported image protocol is detected | Automatic rendering reports the unsupported condition. |
| Invalid image data is supplied | The encoder propagates its typed failure rather than emitting a success marker. |
| Output fails | TerminalCore's write failure is propagated. |

## Dependencies

Consumes ANSI and TerminalCore. It is re-exported by CLI and consumed by TerminalUI image-capable clients.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured existing terminal image protocols for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
