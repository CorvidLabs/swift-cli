# ``TerminalComponents``

Progress bars, spinners, prompts, and selection menus for interactive CLI applications.

## Overview

TerminalComponents provides interactive UI components for building rich command-line interfaces. Display progress with animated spinners and progress bars, and gather user input with various prompt types.

```swift
import TerminalComponents

// Spinner
let spinner = Spinner(style: .dots, message: "Loading...")
await spinner.start()
try await Task.sleep(for: .seconds(2))
await spinner.success("Done!")

// Progress bar
let progress = ProgressBar(total: 100)
for i in 0...100 {
    await progress.update(i)
}

// Prompts
let name = try await terminal.input("What's your name?")
let confirmed = try await terminal.confirm("Continue?")
let choice = try await terminal.select("Pick one:", options: ["A", "B", "C"])
```

## Topics

### Progress Indicators

- ``Spinner``
- ``ProgressBar``

### User Prompts

- ``Input``
- ``Confirm``
- ``Select``
- ``MultiSelect``
