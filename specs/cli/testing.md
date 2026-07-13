---
spec: cli.spec.md
---

## Automated Testing

| Test Surface | Requirements | What It Covers |
|--------------|--------------|----------------|
| `swift build` plus all package test targets | REQ-cli-001, REQ-cli-002 | Umbrella compilation and availability of all re-exported products through the package graph. |

## Manual Testing

No independent runtime flow exists. Build and test the complete package from a clean checkout.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| A lower-level module changes its public import | Umbrella compilation detects an unavailable re-export. |
| A platform excludes a lower-level declaration | The lower-level availability contract remains authoritative. |
