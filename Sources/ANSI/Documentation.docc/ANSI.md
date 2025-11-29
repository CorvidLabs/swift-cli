# ``ANSI``

Pure ANSI escape code generation with zero dependencies.

## Overview

The ANSI module provides type-safe generation of ANSI escape sequences for terminal control. It handles cursor movement, screen clearing, colors, styles, and more - all as pure string generation with no I/O operations.

```swift
import ANSI

// Control sequences
let up = ANSI.Cursor.up(5)           // Move cursor up 5 lines
let clear = ANSI.Erase.screen        // Clear entire screen

// Colors and styles
let red = ANSI.Style.foreground(.red)
let bold = ANSI.Style.bold
let reset = ANSI.Style.reset

// Compose escape sequences
print("\(red)\(bold)Error!\(reset)")
```

## Topics

### Escape Sequences

- ``ANSI``

### Cursor Control

- ``ANSI/Cursor``

### Screen and Line Erasing

- ``ANSI/Erase``

### Colors and Styles

- ``ANSI/Style``
- ``ANSI/Color``

### Screen Control

- ``ANSI/Screen``

### Box Drawing

- ``ANSI/Box``

### Hyperlinks

- ``ANSI/Hyperlink``

### Terminal Reports

- ``ANSI/Report``
