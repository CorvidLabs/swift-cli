---
module: cli
version: 2
status: stable
files:
  - Sources/CLI/SwiftCLI.swift

db_tables: []
depends_on:
  - specs/ansi/ansi.spec.md
  - specs/terminal-components/terminal-components.spec.md
  - specs/terminal-core/terminal-core.spec.md
  - specs/terminal-graphics/terminal-graphics.spec.md
  - specs/terminal-input/terminal-input.spec.md
  - specs/terminal-layout/terminal-layout.spec.md
  - specs/terminal-style/terminal-style.spec.md
  - specs/terminal-ui/terminal-ui.spec.md
---

# Cli

## Purpose

`CLI` is the umbrella import for Swift CLI. It re-exports ANSI generation, terminal I/O, styling, input, layout,
components, graphics, and declarative terminal UI so clients can depend on one product without wrapper behavior.

## Public API

The module intentionally declares no independent runtime API. Its public contract is the set of exported imports in
`SwiftCLI.swift`, and each re-exported module owns its detailed behavior.

### Exported Types

| Type | Kind | Description |
|------|------|-------------|

### Exported Protocols

| Protocol | Description |
|----------|-------------|

## Invariants

1. Importing `CLI` makes all eight constituent library modules available to a client.
2. The umbrella adds no state, I/O, or behavioral divergence from those modules.

## Behavioral Examples

- **Given** a package target that imports `CLI`, **when** it uses an ANSI, terminal, style, input, layout, component,
  graphics, or TerminalUI API, **then** no separate module import is required.

## Error Cases

No independent error cases exist; errors and availability constraints come from the re-exported module being used.

## Dependencies

Consumes and re-exports all other package library products. It is consumed by applications that prefer a single
umbrella dependency.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured the existing umbrella-module contract for SpecSync 5 governance. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout: Document the existing Swift CLI modules at complete coverage and correct rollout policy gaps |
