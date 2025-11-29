# ``TerminalInput``

Keyboard input, mouse events, and line editing for interactive terminal applications.

## Overview

TerminalInput handles all forms of user input in terminal applications. It provides keyboard event parsing, mouse event support, modifier key detection, and a full-featured line editor for text input.

```swift
import TerminalInput

// Read keyboard input
let event = try await terminal.readEvent()
switch event {
case .key(let key, let modifiers):
    if key == .enter {
        print("Enter pressed!")
    }
case .mouse(let mouse):
    print("Mouse at \(mouse.x), \(mouse.y)")
}

// Line editing
let editor = LineEditor()
let input = try await editor.readline(prompt: "> ")
```

## Topics

### Input Events

- ``InputEvent``
- ``KeyCode``
- ``Modifiers``

### Mouse Support

- ``MouseEvent``

### Line Editing

- ``LineEditor``

### Input Reading

- ``InputReader``
