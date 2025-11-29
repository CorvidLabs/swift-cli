# ``TerminalCore``

Low-level terminal I/O operations, raw mode, and capability detection.

## Overview

TerminalCore provides the foundation for terminal interaction, including raw mode for character-by-character input, terminal size detection, capability detection, and error handling. It serves as the base layer that other modules build upon.

```swift
import TerminalCore

let terminal = Terminal.shared

// Get terminal size
let size = await terminal.size
print("Terminal is \(size.width)x\(size.height)")

// Check capabilities
let caps = await terminal.capabilities
if caps.supportsColor {
    print("Color is supported!")
}

// Write output
await terminal.write("Hello, Terminal!")
await terminal.writeLine("With newline")
```

## Topics

### Terminal Actor

- ``Terminal``

### Configuration

- ``TerminalConfiguration``
- ``TerminalCapabilities``

### Size and Dimensions

- ``TerminalSize``
- ``Size``

### Error Handling

- ``TerminalError``

### Logging

- ``Logger``
