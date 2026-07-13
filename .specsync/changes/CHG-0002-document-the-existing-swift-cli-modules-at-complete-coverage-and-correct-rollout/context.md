---
change: CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout
artifact: context
---

# Context

Swift CLI contains nine library targets but previously had no canonical companions. The rollout scaffold therefore
reported zero useful coverage and could not prove which source or public export belonged to which contract. This
change documents the existing implementation only: all 65 Swift source files, the complete public export inventory,
stable requirements, native test evidence, and all four generated agent integrations. Product source and tests remain
unchanged.

The umbrella CLI target owns only re-exports. ANSI owns pure escape construction; TerminalCore owns I/O and platform
state; the remaining modules build styling, input, layout, components, graphics, and declarative UI above them.
