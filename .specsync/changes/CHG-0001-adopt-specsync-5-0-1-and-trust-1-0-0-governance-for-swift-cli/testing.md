---
change: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-swift-cli
artifact: testing
---

# Testing

Run `specsync check --strict --force` at advisory threshold 0, `specsync agents status`, `fledge trust doctor`, and `fledge lanes run verify`. The blocking lane must build every module and pass all 105 tests. Existing Linux and macOS workflows remain independent platform evidence.
