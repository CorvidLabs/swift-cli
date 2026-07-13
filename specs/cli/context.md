---
spec: cli.spec.md
---

## Key Decisions

- Keep CLI as a source-only umbrella that re-exports every library product.
- Place behavior and tests in the owning lower-level module.

## Files to Read First

- `Sources/CLI/SwiftCLI.swift`
- `Package.swift`

## Current Status

The umbrella is stable and contains no independent executable behavior; this governance change documents it only.
