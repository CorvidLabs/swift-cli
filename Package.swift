// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-cli",
    platforms: [
        .macOS(.v13)
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
        .library(name: "CLI", targets: ["CLI"]),

        // Example executable
        .executable(name: "swift-cli-example", targets: ["SwiftCLIExample"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0")
    ],
    targets: [
        // MARK: - Foundation Layer

        .target(
            name: "ANSI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // MARK: - Core Layer

        .target(
            name: "TerminalCore",
            dependencies: [
                "ANSI",
                .product(name: "Atomics", package: "swift-atomics")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // MARK: - Feature Packages

        .target(
            name: "TerminalStyle",
            dependencies: ["ANSI", "TerminalCore"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "TerminalInput",
            dependencies: ["ANSI", "TerminalCore", "TerminalStyle"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "TerminalLayout",
            dependencies: ["ANSI", "TerminalCore", "TerminalStyle"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "TerminalComponents",
            dependencies: ["ANSI", "TerminalCore", "TerminalStyle", "TerminalInput"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "TerminalGraphics",
            dependencies: ["ANSI", "TerminalCore"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // MARK: - High-Level Framework

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
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // MARK: - Umbrella

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
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // MARK: - Example

        .executableTarget(
            name: "SwiftCLIExample",
            dependencies: ["CLI"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // MARK: - Tests

        .testTarget(
            name: "ANSITests",
            dependencies: ["ANSI"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TerminalCoreTests",
            dependencies: ["TerminalCore"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TerminalStyleTests",
            dependencies: ["TerminalStyle"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TerminalInputTests",
            dependencies: ["TerminalInput"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TerminalLayoutTests",
            dependencies: ["TerminalLayout"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TerminalComponentsTests",
            dependencies: ["TerminalComponents"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TerminalGraphicsTests",
            dependencies: ["TerminalGraphics"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TerminalUITests",
            dependencies: ["TerminalUI"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)
