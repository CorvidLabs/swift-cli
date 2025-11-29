# ``CLI``

A comprehensive Swift toolkit for building beautiful command-line interfaces.

## Overview

SwiftCLI provides a modular architecture for building terminal applications, from simple styled output to full-featured TUI frameworks. Import just what you need, or use the `CLI` umbrella module to access everything.

```swift
import CLI

@main
struct MyCLI {
    static func main() async throws {
        let terminal = Terminal.shared

        // Styled output
        await terminal.writeLine("Hello".green.bold + " World!".cyan)

        // Interactive prompts
        let name = try await terminal.input("What's your name?")
        await terminal.success("Hello, \(name)!")
    }
}
```

## Architecture

SwiftCLI is organized in layers:

**Foundation Layer**
- `ANSI` - Pure escape code generation with zero dependencies

**Core Layer**
- `TerminalCore` - Low-level terminal I/O, raw mode, capabilities

**Feature Packages**
- `TerminalStyle` - Colors, text styles, chainable styling
- `TerminalInput` - Keyboard input, mouse events, line editing
- `TerminalLayout` - Boxes, tables, grids, panels
- `TerminalComponents` - Progress bars, spinners, prompts
- `TerminalGraphics` - Terminal images (iTerm2, Kitty, Sixel)

**High-Level Framework**
- `TerminalUI` - Full TUI framework with SwiftUI-like API

## Topics

### Terminal

- ``Terminal``
- ``TerminalSize``
- ``TerminalCapabilities``
- ``TerminalConfiguration``
- ``TerminalError``

### Styling

- ``StyledText``
- ``Theme``
- ``Gradient``

### Input

- ``InputEvent``
- ``KeyCode``
- ``MouseEvent``
- ``Modifiers``
- ``LineEditor``

### Layout

- ``Box``
- ``Table``
- ``Panel``
- ``Tree``
- ``BoxStyle``

### Components

- ``Spinner``
- ``ProgressBar``

### Graphics

- ``TerminalImage``
- ``ITerm2Image``
- ``KittyImage``
- ``SixelImage``

### TUI Framework

- ``View``
- ``App``
- ``Text``
- ``VStack``
- ``HStack``
- ``ZStack``
- ``RenderEngine``
