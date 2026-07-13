---
spec: terminal-graphics.spec.md
---

# Requirements

### REQ-terminal-graphics-001

iTerm2Image SHALL encode image data and configured metadata in one valid OSC 1337 file payload.

Acceptance Criteria
- Data is base64 encoded and terminated by the protocol delimiter.
- Name, width, height, inline, and preserve-aspect-ratio fields appear only as configured.

### REQ-terminal-graphics-002

KittyImage SHALL emit ordered protocol chunks with correct continuation state.

Acceptance Criteria

- Non-final chunks advertise continuation and the final chunk does not.
- Image identifier, format, dimensions, and placement remain consistent across chunks.

### REQ-terminal-graphics-003

SixelImage SHALL encode supported pixel data into a Sixel-framed payload.

Acceptance Criteria

- Output begins and ends with the protocol's control framing.
- Encoded dimensions match the supplied image size.

### REQ-terminal-graphics-004

TerminalImage SHALL select only a protocol supported by detected terminal capabilities or report unsupported output.

Acceptance Criteria

- Explicit protocol wrappers remain independently usable.
- Automatic selection does not silently claim success when no supported protocol exists.

## Constraints

- The module encodes caller-supplied image bytes; it does not decode image file formats.

## Out of Scope

- Remote image retrieval, image editing, and terminal capability discovery implementation.
