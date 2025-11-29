# ``TerminalUI``

A SwiftUI-inspired framework for building terminal user interfaces.

## Overview

TerminalUI provides a declarative, SwiftUI-like API for building terminal user interfaces. Compose views using familiar patterns like VStack, HStack, and view modifiers.

```swift
import TerminalUI

struct MyView: View {
    var body: some View {
        VStack {
            Text("Hello").bold()
            HStack {
                Text("Left").red()
                Text("Right").blue()
            }
        }
        .border(.rounded, title: "Welcome")
        .padding()
    }
}

// Render the view
let output = RenderEngine.renderString(MyView(), size: Size(width: 80, height: 24))
print(output)
```

## Topics

### App Structure

- ``App``
- ``View``
- ``ViewBuilder``

### Layout Containers

- ``VStack``
- ``HStack``
- ``ZStack``

### Basic Views

- ``Text``
- ``EmptyView``
- ``TerminalUI/Divider``
- ``Spacer``
- ``ForEach``

### View Modifiers

- ``Padding``
- ``Border``

### Progress Views

- ``ProgressView``
- ``ProgressBarView``
- ``SpinnerView``

### System Information

- ``SystemMetrics``

### Rendering

- ``RenderEngine``
- ``RenderBuffer``
- ``DifferentialRenderer``
