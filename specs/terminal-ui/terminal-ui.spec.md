---
module: terminal-ui
version: 2
status: stable
files:
  - Sources/TerminalUI/App.swift
  - Sources/TerminalUI/Border.swift
  - Sources/TerminalUI/DifferentialRenderer.swift
  - Sources/TerminalUI/EmptyView.swift
  - Sources/TerminalUI/ForEach.swift
  - Sources/TerminalUI/HStack.swift
  - Sources/TerminalUI/Padding.swift
  - Sources/TerminalUI/ProgressBarView.swift
  - Sources/TerminalUI/ProgressView.swift
  - Sources/TerminalUI/RenderBuffer.swift
  - Sources/TerminalUI/RenderEngine.swift
  - Sources/TerminalUI/SpinnerView.swift
  - Sources/TerminalUI/SystemMetrics.swift
  - Sources/TerminalUI/Text.swift
  - Sources/TerminalUI/VStack.swift
  - Sources/TerminalUI/View.swift
  - Sources/TerminalUI/ViewBuilder.swift
  - Sources/TerminalUI/ZStack.swift


db_tables: []
depends_on:
  - specs/ansi/ansi.spec.md
  - specs/terminal-components/terminal-components.spec.md
  - specs/terminal-core/terminal-core.spec.md
  - specs/terminal-graphics/terminal-graphics.spec.md
  - specs/terminal-input/terminal-input.spec.md
  - specs/terminal-layout/terminal-layout.spec.md
  - specs/terminal-style/terminal-style.spec.md
---

# Terminal Ui

## Purpose

`TerminalUI` is a declarative terminal interface layer with a SwiftUI-like `View` model, result builder, stack and
decorator views, render buffers, differential output, progress and spinner views, and an application event loop.

## Public API

The inventory covers the `View` protocol and builder, text/empty/collection views, vertical/horizontal/depth stacks,
padding and borders, render buffers and engines, differential rendering, system metrics, progress indicators, and App.

### Exported Functions

| Symbol |
|--------|
| `App` |
| `onAppear` |
| `onUpdate` |
| `onKeyPress` |
| `onResize` |
| `updateInterval` |
| `runApp` |
| `Body` |
| `body` |
| `BorderedView` |
| `content` |
| `style` |
| `title` |
| `borderColor` |
| `border` |
| `roundedBorder` |
| `singleBorder` |
| `doubleBorder` |
| `init` |
| `DifferentialRenderer` |
| `render` |
| `invalidate` |
| `EmptyView` |
| `Spacer` |
| `minLength` |
| `Divider` |
| `ForEach` |
| `data` |
| `HStack` |
| `alignment` |
| `spacing` |
| `VerticalAlignment` |
| `top` |
| `center` |
| `bottom` |
| `EdgeInsets` |
| `leading` |
| `trailing` |
| `zero` |
| `PaddedView` |
| `padding` |
| `ProgressBarView` |
| `progress` |
| `width` |
| `showPercentage` |
| `ProgressStyle` |
| `LabeledProgressBar` |
| `label` |
| `block` |
| `smooth` |
| `ascii` |
| `minimal` |
| `ProgressView` |
| `Style` |
| `percentage` |
| `blocks` |
| `bar` |
| `dots` |
| `RenderedLine` |
| `==` |
| `DiffResult` |
| `changedLines` |
| `isFullRepaint` |
| `hasChanges` |
| `changeCount` |
| `RenderBuffer` |
| `lines` |
| `size` |
| `diff` |
| `RenderEngine` |
| `renderString` |
| `SpinnerView` |
| `message` |
| `isActive` |
| `SpinnerStyle` |
| `line` |
| `bounce` |
| `arrow` |
| `pulse` |
| `SystemMetrics` |
| `CPUUsage` |
| `user` |
| `system` |
| `idle` |
| `total` |
| `MemoryUsage` |
| `used` |
| `free` |
| `usedPercentage` |
| `usedGB` |
| `totalGB` |
| `DiskUsage` |
| `path` |
| `available` |
| `availableGB` |
| `getCPUUsage` |
| `getMemoryUsage` |
| `getDiskUsage` |
| `getCPUCoreCount` |
| `getLoadAverage` |
| `Text` |
| `foreground` |
| `background` |
| `styles` |
| `foregroundColor` |
| `backgroundColor` |
| `bold` |
| `italic` |
| `underline` |
| `dim` |
| `strikethrough` |
| `toStyledText` |
| `black` |
| `red` |
| `green` |
| `yellow` |
| `blue` |
| `magenta` |
| `cyan` |
| `white` |
| `gray` |
| `VStack` |
| `HorizontalAlignment` |
| `View` |
| `AnyView` |
| `Size` |
| `height` |
| `Position` |
| `x` |
| `y` |
| `ViewBuilder` |
| `buildBlock` |
| `buildOptional` |
| `buildEither` |
| `buildExpression` |
| `TupleView` |
| `value` |
| `OptionalView` |
| `ConditionalView` |
| `first` |
| `second` |
| `ZStackAlignment` |
| `horizontal` |
| `vertical` |
| `topLeading` |
| `topTrailing` |
| `bottomLeading` |
| `bottomTrailing` |
| `ZStack` |
### Exported Types

| Type | Description |
|------|-------------|

## Invariants

1. A view renders deterministically for the same available size and state.
2. Stack layout respects axis, spacing, alignment, child size, padding, and border constraints.
3. RenderBuffer bounds prevent writes outside allocated cells and preserve styled cell content.
4. Differential rendering emits only changed terminal regions while producing the same visible result as full rendering.
5. The application restores terminal state after normal exit, cancellation, or error.

## Behavioral Examples

- `VStack` places child renderings top-to-bottom with configured spacing and horizontal alignment.
- `HStack` places children left-to-right, while padding and border decorators reduce the child's available content area.
- `ForEach` renders each identified element in source order; progress and spinner views derive output from current state.
- Differential rendering compares the previous and next buffers and writes the minimal changed spans.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Available width or height is zero | Views produce an empty bounded rendering without indexing outside the buffer. |
| A cell write targets outside the buffer | The buffer ignores or rejects it according to the declared safe API. |
| Terminal setup, input, rendering, or restoration fails | App propagates the typed failure after attempting restoration. |

## Dependencies

Consumes all lower-level package modules and is re-exported by CLI. Applications compose it into interactive TUIs.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured existing declarative terminal UI behavior for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
