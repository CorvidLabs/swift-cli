# SwiftCLI

[![macOS](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-cli/macOS.yml?label=macOS&branch=main)](https://github.com/CorvidLabs/swift-cli/actions/workflows/macOS.yml)
[![Ubuntu](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-cli/ubuntu.yml?label=Ubuntu&branch=main)](https://github.com/CorvidLabs/swift-cli/actions/workflows/ubuntu.yml)
[![License](https://img.shields.io/github/license/CorvidLabs/swift-cli)](https://github.com/CorvidLabs/swift-cli/blob/main/LICENSE)
[![Version](https://img.shields.io/github/v/release/CorvidLabs/swift-cli)](https://github.com/CorvidLabs/swift-cli/releases)

A comprehensive Swift library for building Terminal User Interfaces and CLI applications.

## Features

- **Swift 6** with modern async/await concurrency support
- **Type-safe** ANSI escape code generation with zero dependencies
- **Modular architecture** - use only what you need
- **Multi-platform** support: macOS 12+, Linux
- **SwiftUI-like** TUI framework for building full terminal applications

## Installation

Add SwiftCLI as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/CorvidLabs/swift-cli.git", from: "0.1.0")
]
```

Then add the target dependency:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "CLI", package: "swift-cli")
    ]
)
```

## Documentation

- [API Documentation](https://corvidlabs.github.io/swift-cli/documentation/swiftcli/)

## Quick Start

### Import Everything

```swift
import CLI
```

### Or Import Only What You Need

```swift
import ANSI              // Pure escape codes
import TerminalCore      // Low-level I/O
import TerminalStyle     // Colors and styling
import TerminalInput     // Keyboard/mouse
import TerminalLayout    // Boxes, tables, panels
import TerminalComponents // Progress, spinners, prompts
import TerminalGraphics  // Terminal images
import TerminalUI        // Full TUI framework
```

### Basic Styling

```swift
import TerminalStyle

let styled = "Hello, World!"
    .bold()
    .foreground(.green)

print(styled)
```

### Progress Bar

```swift
import TerminalComponents

let progress = ProgressBar(total: 100)
for i in 0...100 {
    progress.update(i)
    // do work...
}
```

### Interactive Prompt

```swift
import TerminalComponents

let name = Prompt.ask("What is your name?")
let confirmed = Prompt.confirm("Continue?")
let choice = Prompt.select("Pick one:", options: ["Option A", "Option B", "Option C"])
```

### TerminalUI - SwiftUI-like Terminal Apps

Build full-screen terminal applications with a familiar SwiftUI-like syntax:

```swift
import TerminalUI

struct MyApp: App {
    var body: some View {
        VStack {
            Text("Hello, Terminal!").bold().cyan

            HStack(spacing: 2) {
                Text("Red").red
                Text("Green").green
                Text("Blue").blue
            }

            Text("Press 'q' to quit").dim()
        }
        .padding(1)
        .border(.rounded, title: "My App")
    }
}

// Run the app
try await runApp(MyApp())
```

## Architecture

SwiftCLI follows a layered, modular architecture. Each module builds on the previous layers:

| Module | Description |
|--------|-------------|
| `ANSI` | Pure ANSI escape code generation - zero dependencies |
| `TerminalCore` | Low-level terminal operations: I/O, raw mode, capabilities |
| `TerminalStyle` | Colors, text styles, chainable styling API |
| `TerminalInput` | Keyboard input, mouse events, line editing |
| `TerminalLayout` | Boxes, tables, grids, panels, tree views |
| `TerminalComponents` | Progress bars, spinners, prompts, selection menus |
| `TerminalGraphics` | Terminal images: iTerm2, Kitty, Sixel protocols |
| `TerminalUI` | Full TUI framework with SwiftUI-like API |
| `CLI` | Umbrella module - imports everything |

### Available Views (TerminalUI)

| View | Description |
|------|-------------|
| `Text` | Styled text with colors and formatting |
| `VStack` | Vertical layout with alignment and spacing |
| `HStack` | Horizontal layout with alignment and spacing |
| `ZStack` | Overlapping views with alignment |
| `ForEach` | Data-driven view generation |
| `Spacer` | Flexible spacing |
| `Divider` | Horizontal separator |
| `EmptyView` | Placeholder view |

### View Modifiers

| Modifier | Description |
|----------|-------------|
| `.padding()` | Add padding around views |
| `.border()` | Add borders (single, double, rounded, heavy) |
| `.bold()`, `.italic()`, `.dim()` | Text styles |
| `.red`, `.green`, `.blue`, `.cyan`, `.yellow`, `.magenta` | Text colors |

## Requirements

- Swift 6.0+
- macOS 12+ or Linux

## License

SwiftCLI is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
