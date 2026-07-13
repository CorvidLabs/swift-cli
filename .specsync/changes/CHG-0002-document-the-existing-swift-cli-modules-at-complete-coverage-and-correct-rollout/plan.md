---
change: CHG-0002-document-the-existing-swift-cli-modules-at-complete-coverage-and-correct-rollout
artifact: plan
---

# Plan

1. Inventory package products, targets, source files, public exports, dependencies, and native test targets.
2. Create one stable canonical companion for each of ANSI, CLI, TerminalComponents, TerminalCore, TerminalGraphics,
   TerminalInput, TerminalLayout, TerminalStyle, and TerminalUI.
3. Record source-backed requirements, context, completed documentation tasks, and evidence without changing behavior.
4. Regenerate Claude, Cursor, Codex, and Gemini integration files with SpecSync 5.0.1.
5. Run the strict 100-percent SpecSync gate, all native Swift tests, Trust doctor/verify, and scans for unfinished text.
6. Request closing approval only after verification succeeds; hosted checks remain a post-push requirement.

## Rollback

Revert only the documentation and generated governance files from this change. No product-state migration is needed.
