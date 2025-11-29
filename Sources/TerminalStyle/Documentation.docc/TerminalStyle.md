# ``TerminalStyle``

Colors, text styles, and chainable styling API for terminal output.

## Overview

TerminalStyle provides a fluent API for styling terminal text with colors and text attributes. Chain multiple styles together and apply them to strings for rich, colorful terminal output.

```swift
import TerminalStyle

// Chainable styling
let styled = "Hello".red.bold.underline
let warning = "Warning".yellow.on(.black)

// Gradient text
let gradient = Gradient.rainbow("Rainbow text!")

// Using StyledText directly
let text = StyledText("Custom")
    .foreground(.cyan)
    .background(.blue)
    .bold()

// Print styled output
await terminal.writeLine(styled)
```

## Topics

### Styled Text

- ``StyledText``

### Themes

- ``Theme``

### Gradients

- ``Gradient``

### String Extensions

String styling is available through extensions that add properties like `.red`, `.bold`, `.underline`, etc.
