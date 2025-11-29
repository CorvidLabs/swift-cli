# ``TerminalGraphics``

Terminal image display using iTerm2, Kitty, and Sixel protocols.

## Overview

TerminalGraphics enables displaying images directly in supported terminal emulators. It supports multiple image protocols including iTerm2's inline images, Kitty's graphics protocol, and the Sixel format.

```swift
import TerminalGraphics

// Auto-detect best protocol
let image = try TerminalImage(path: "photo.png")
await terminal.render(image)

// Use specific protocol
let iterm = try ITerm2Image(path: "photo.png")
let kitty = try KittyImage(path: "photo.png")
let sixel = try SixelImage(path: "photo.png")
```

## Topics

### Terminal Images

- ``TerminalImage``

### Protocol Implementations

- ``ITerm2Image``
- ``KittyImage``
- ``SixelImage``

### Image Protocol

- ``ImageProtocol``
