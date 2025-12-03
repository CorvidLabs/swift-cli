// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-cli",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Individual packages - use only what you need
        .library(name: "ANSI", targets: ["ANSI"]),
        .library(name: "TerminalCore", targets: ["TerminalCore"]),
        .library(name: "TerminalStyle", targets: ["TerminalStyle"]),
        .library(name: "TerminalInput", targets: ["TerminalInput"]),
        .library(name: "TerminalLayout", targets: ["TerminalLayout"]),
        .library(name: "TerminalComponents", targets: ["TerminalComponents"]),
        .library(name: "TerminalGraphics", targets: ["TerminalGraphics"]),
        .library(name: "TerminalUI", targets: ["TerminalUI"]),

        // Umbrella - import everything
        .library(name: "CLI", targets: ["CLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0")
    ],
    targets: [
        // MARK: - Foundation Layer

        /// Pure ANSI escape code generation - zero dependencies
        .target(name: "ANSI"),

        // MARK: - Core Layer

        /// Low-level terminal operations: I/O, raw mode, capabilities
        .target(
            name: "TerminalCore",
            dependencies: [
                "ANSI",
                .product(name: "Atomics", package: "swift-atomics")
            ]
        ),

        // MARK: - Feature Packages

        /// Colors, text styles, chainable styling API
        .target(
            name: "TerminalStyle",
            dependencies: ["ANSI", "TerminalCore"]
        ),

        /// Keyboard input, mouse events, line editing
        .target(
            name: "TerminalInput",
            dependencies: ["ANSI", "TerminalCore", "TerminalStyle"]
        ),

        /// Boxes, tables, grids, panels, tree views
        .target(
            name: "TerminalLayout",
            dependencies: ["ANSI", "TerminalCore", "TerminalStyle"]
        ),

        /// Progress bars, spinners, prompts, selection menus
        .target(
            name: "TerminalComponents",
            dependencies: ["ANSI", "TerminalCore", "TerminalStyle", "TerminalInput"]
        ),

        /// Terminal images: iTerm2, Kitty, Sixel protocols
        .target(
            name: "TerminalGraphics",
            dependencies: ["ANSI", "TerminalCore"]
        ),

        // MARK: - High-Level Framework

        /// Full TUI framework with SwiftUI-like API
        .target(
            name: "TerminalUI",
            dependencies: [
                "ANSI",
                "TerminalCore",
                "TerminalStyle",
                "TerminalInput",
                "TerminalLayout",
                "TerminalComponents",
                "TerminalGraphics"
            ]
        ),

        // MARK: - Umbrella

        /// Everything in one import
        .target(
            name: "CLI",
            dependencies: [
                "ANSI",
                "TerminalCore",
                "TerminalStyle",
                "TerminalInput",
                "TerminalLayout",
                "TerminalComponents",
                "TerminalGraphics",
                "TerminalUI"
            ]
        ),

        // MARK: - Tests

        .testTarget(name: "ANSITests", dependencies: ["ANSI"]),
        .testTarget(name: "TerminalCoreTests", dependencies: ["TerminalCore"]),
        .testTarget(name: "TerminalStyleTests", dependencies: ["TerminalStyle"]),
        .testTarget(name: "TerminalInputTests", dependencies: ["TerminalInput"]),
        .testTarget(name: "TerminalLayoutTests", dependencies: ["TerminalLayout"]),
        .testTarget(name: "TerminalComponentsTests", dependencies: ["TerminalComponents"]),
        .testTarget(name: "TerminalGraphicsTests", dependencies: ["TerminalGraphics"]),
        .testTarget(name: "TerminalUITests", dependencies: ["TerminalUI"])
    ]
)
