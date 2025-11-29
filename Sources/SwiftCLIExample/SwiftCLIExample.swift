import CLI
import Foundation
import TerminalCore

@main
struct SwiftCLIExample {
    static func main() async throws {
        debugLog("App starting")
        let terminal = Terminal.shared

        // Welcome banner
        await terminal.writeLine("")
        await terminal.render(Box(
            """
            swift-cli Interactive
            Explore • Test • Build
            """,
            style: .double,
            padding: .medium,
            title: "Welcome",
            borderColor: .cyan
        ))
        await terminal.writeLine("")

        // Main menu loop
        while true {
            do {
                let choice = try await showMainMenu(terminal)
                if choice == "Exit" { break }
                try await runDemo(choice, terminal: terminal)
            } catch TerminalError.cancelled {
                // User pressed Ctrl+C, exit gracefully
                break
            }
        }

        await terminal.writeLine("")
        await terminal.success("Thanks for using swift-cli!")
        await terminal.writeLine("")
    }

    static func showMainMenu(_ terminal: Terminal) async throws -> String {
        let options = [
            // Interactive Documentation
            Select<String>.Option("Explore Library", value: "Explore Library", description: "Browse modules, view source code"),
            Select<String>.Option("Run Tests", value: "Run Tests", description: "Execute and view test results"),
            // Component Demos
            Select<String>.Option("Component Demos", value: "Component Demos", description: "See library features in action"),
            // TUI Apps
            Select<String>.Option("TUI Apps", value: "TUI Apps", description: "Full-screen terminal applications"),
            // Info
            Select<String>.Option("Terminal Info", value: "Terminal Info", description: "Detect terminal capabilities"),
            Select<String>.Option("Exit", value: "Exit", description: "Quit")
        ]

        return try await Select("What would you like to do?", options: options, terminal: terminal).run()
    }

    static func runDemo(_ demo: String, terminal: Terminal) async throws {
        debugLog("Running demo: \(demo)")
        await terminal.writeLine("")

        switch demo {
        case "Explore Library":
            debugLog("Launching ExploreApp")
            try await runApp(ExploreApp())
            return  // TUI apps handle their own lifecycle
        case "Run Tests":
            try await runApp(TestRunnerApp())
            return
        case "Component Demos":
            try await showComponentDemos(terminal)
            return
        case "TUI Apps":
            try await demoTUIApps(terminal)
            return
        case "Terminal Info":
            try await demoTerminalInfo(terminal)
        default:
            break
        }

        await terminal.writeLine("")
        await pressAnyKey(terminal)
        await terminal.writeLine("")
    }

    static func showComponentDemos(_ terminal: Terminal) async throws {
        while true {
            let options = [
                Select<String>.Option("Styled Text & Colors", value: "Styled Text & Colors", description: "Colors, bold, underline, rainbow"),
                Select<String>.Option("Box Styles & Layout", value: "Box Styles & Layout", description: "Single, double, rounded, heavy borders"),
                Select<String>.Option("Tables & Trees", value: "Tables & Trees", description: "Data tables and tree structures"),
                Select<String>.Option("Interactive Prompts", value: "Interactive Prompts", description: "Select, confirm, input prompts"),
                Select<String>.Option("Spinners & Progress", value: "Spinners & Progress", description: "Loading indicators and progress bars"),
                Select<String>.Option("Gradients", value: "Gradients", description: "Color gradient text effects"),
                Select<String>.Option("Keyboard Input", value: "Keyboard Input", description: "Real-time key detection"),
                Select<String>.Option("Back to Main Menu", value: "back", description: "Return to main menu")
            ]

            let choice = try await Select("Choose a component demo:", options: options, terminal: terminal).run()

            if choice == "back" { return }

            await terminal.writeLine("")

            switch choice {
            case "Styled Text & Colors":
                try await demoStyledText(terminal)
            case "Box Styles & Layout":
                try await demoBoxStyles(terminal)
            case "Tables & Trees":
                try await demoTablesAndTrees(terminal)
            case "Interactive Prompts":
                try await demoInteractivePrompts(terminal)
            case "Spinners & Progress":
                try await demoSpinnersAndProgress(terminal)
            case "Gradients":
                try await demoGradients(terminal)
            case "Keyboard Input":
                try await demoKeyboardInput(terminal)
            default:
                break
            }

            await terminal.writeLine("")
            await pressAnyKey(terminal)
            await terminal.writeLine("")
        }
    }

    static func pressAnyKey(_ terminal: Terminal) async {
        await terminal.write("Press any key to continue...".dim.render())
        try? await terminal.enableRawMode()
        _ = try? await terminal.readKey()
        try? await terminal.disableRawMode()
        await terminal.writeLine("")
    }
}

// MARK: - Demo: Styled Text & Colors

func demoStyledText(_ terminal: Terminal) async throws {
    await terminal.divider("Styled Text & Colors")
    await terminal.writeLine("")

    // Basic colors
    await terminal.writeLine("Basic Colors:".bold.render())
    await terminal.writeLine("  " + "Red".red.render() + "  " + "Green".green.render() + "  " + "Blue".blue.render() + "  " + "Yellow".yellow.render() + "  " + "Cyan".cyan.render() + "  " + "Magenta".magenta.render())
    await terminal.writeLine("")

    // Text styles
    await terminal.writeLine("Text Styles:".bold.render())
    await terminal.writeLine("  " + "Bold".bold.render() + "  " + "Dim".dim.render() + "  " + "Italic".italic.render() + "  " + "Underline".underline.render() + "  " + "Strikethrough".strikethrough.render())
    await terminal.writeLine("")

    // Chained styles
    await terminal.writeLine("Chained Styles:".bold.render())
    await terminal.writeLine("  " + "Bold Red".red.bold.render())
    await terminal.writeLine("  " + "Italic Cyan Underline".cyan.italic.underline.render())
    await terminal.writeLine("  " + "Dim Yellow".yellow.dim.render())
    await terminal.writeLine("")

    // Rainbow
    await terminal.writeLine("Special Effects:".bold.render())
    await terminal.writeLine("  Rainbow: " + "SwiftCLI is awesome!".rainbow)
    await terminal.writeLine("  Blink:   " + "Attention!".blink.red.render() + " (if supported)")
    await terminal.writeLine("")

    // Composing styled text
    await terminal.writeLine("Composing:".bold.render())
    await terminal.writeLine("  " + "Hello".red.bold + " " + "World".green + "!".yellow.blink)
}

// MARK: - Demo: Box Styles & Layout

func demoBoxStyles(_ terminal: Terminal) async throws {
    await terminal.divider("Box Styles & Layout")
    await terminal.writeLine("")

    // Box styles
    let styles: [(String, BoxStyle)] = [
        ("Single", .single),
        ("Double", .double),
        ("Rounded", .rounded),
        ("Heavy", .heavy)
    ]

    for (name, style) in styles {
        await terminal.render(Box(name, style: style, padding: .small))
    }
    await terminal.writeLine("")

    // Box with title
    await terminal.render(Box(
        "This box has a title and medium padding.\nIt can contain multiple lines of text.",
        style: .rounded,
        padding: .medium,
        title: "Titled Box",
        borderColor: .cyan
    ))
    await terminal.writeLine("")

    // Colored borders
    await terminal.writeLine("Colored Borders:".bold.render())
    await terminal.render(Box("Red border", style: .single, padding: .small, borderColor: .red))
    await terminal.render(Box("Green border", style: .single, padding: .small, borderColor: .green))
    await terminal.render(Box("Blue border", style: .single, padding: .small, borderColor: .blue))
}

// MARK: - Demo: Tables & Trees

func demoTablesAndTrees(_ terminal: Terminal) async throws {
    await terminal.divider("Tables")
    await terminal.writeLine("")

    var table = Table(
        columns: [
            .init("Package", width: .auto),
            .init("Description", width: .auto),
            .init("Status", width: .fixed(10), alignment: .center)
        ],
        style: .rounded,
        headerStyle: .bold
    )
    table.addRow(["ANSI", "Escape code generation", "✓".green.render()])
    table.addRow(["TerminalCore", "Low-level terminal I/O", "✓".green.render()])
    table.addRow(["TerminalStyle", "Colors and styling", "✓".green.render()])
    table.addRow(["TerminalInput", "Keyboard/mouse input", "✓".green.render()])
    table.addRow(["TerminalLayout", "Boxes, tables, panels", "✓".green.render()])
    table.addRow(["TerminalComponents", "Progress, spinners", "✓".green.render()])
    table.addRow(["TerminalGraphics", "Terminal images", "✓".green.render()])
    table.addRow(["TerminalUI", "TUI framework", "✓".green.render()])

    await terminal.render(table)
    await terminal.writeLine("")

    await terminal.divider("Tree View")
    await terminal.writeLine("")

    let tree = Tree<String>(
        root: treeNode("swift-cli".bold, children: [
            treeNode("Sources/".cyan, children: [
                treeNode("ANSI/".yellow),
                treeNode("TerminalCore/".yellow),
                treeNode("TerminalStyle/".yellow),
                treeNode("TerminalInput/".yellow),
                treeNode("TerminalLayout/".yellow),
                treeNode("TerminalComponents/".yellow),
                treeNode("TerminalGraphics/".yellow),
                treeNode("TerminalUI/".yellow),
                treeNode("SwiftCLI/".yellow)
            ]),
            treeNode("Tests/".cyan),
            treeNode("Package.swift".green)
        ])
    )
    await terminal.render(tree)
}

// MARK: - Demo: Interactive Prompts

func demoInteractivePrompts(_ terminal: Terminal) async throws {
    await terminal.divider("Interactive Prompts")
    await terminal.writeLine("")
    await terminal.writeLine("These prompts accept keyboard input.".dim.render())
    await terminal.writeLine("")

    // Confirm prompt
    let proceed = try await terminal.confirm("Do you want to see more prompts?", default: true)

    if !proceed {
        await terminal.writeLine("Okay, skipping the rest!".dim.render())
        return
    }

    await terminal.writeLine("")

    // Select prompt
    let color = try await terminal.select(
        "Pick your favorite color:",
        options: ["Red", "Green", "Blue", "Yellow", "Cyan", "Magenta"]
    )
    await terminal.writeLine("You picked: ".dim.render() + color.cyan.render())
    await terminal.writeLine("")

    // MultiSelect prompt
    let features = try await MultiSelect(
        "Which features interest you most?",
        options: [
            MultiSelect<String>.Option("Styled Text", value: "styled", description: "Colors and formatting"),
            MultiSelect<String>.Option("Interactive Prompts", value: "prompts", description: "User input"),
            MultiSelect<String>.Option("TerminalUI", value: "tui", description: "Full-screen apps"),
            MultiSelect<String>.Option("Graphics", value: "graphics", description: "Terminal images")
        ],
        min: 1
    ).run()
    await terminal.writeLine("Selected: ".dim.render() + features.joined(separator: ", ").cyan.render())
    await terminal.writeLine("")

    // Text input
    let name = try await terminal.input("What's your name?", default: "Anonymous")
    await terminal.writeLine("Hello, ".dim.render() + name.cyan.render() + "!".dim.render())
    await terminal.writeLine("")

    // Secret input
    let secret = try await terminal.secret("Enter a secret (hidden):")
    await terminal.writeLine("Your secret has ".dim.render() + "\(secret.count)".cyan.render() + " characters.".dim.render())
}

// MARK: - Demo: Spinners & Progress

func demoSpinnersAndProgress(_ terminal: Terminal) async throws {
    await terminal.divider("Spinner Styles")
    await terminal.writeLine("")
    await terminal.writeLine("Showing various spinner animations...".dim.render())
    await terminal.writeLine("")

    let styles: [(String, Spinner.Style)] = [
        ("dots", .dots),
        ("line", .line),
        ("circle", .circle),
        ("arc", .arc),
        ("box", .box),
        ("arrow", .arrow),
        ("bounce", .bounce),
        ("clock", .clock),
        ("moon", .moon),
        ("earth", .earth)
    ]

    for (name, style) in styles {
        let spinner = Spinner(style: style, message: "Style: \(name)", terminal: terminal)
        await spinner.start()
        try await Task.sleep(nanoseconds: 1_200_000_000)
        await spinner.success()
    }

    await terminal.writeLine("")
    await terminal.divider("Progress Bar")
    await terminal.writeLine("")

    // Progress bar demo
    let progress = ProgressBar(total: 50, style: .blocks, message: "Processing", terminal: terminal)
    await progress.start()
    for i in 0...50 {
        await progress.update(current: i)
        try await Task.sleep(nanoseconds: 40_000_000)
    }
    await progress.finish(message: "Complete!")

    await terminal.writeLine("")

    // withSpinner convenience
    await terminal.writeLine("Using withSpinner for async operations:".dim.render())
    await terminal.writeLine("")

    _ = try await terminal.withSpinner(
        message: "Simulating network request...",
        style: .dots,
        successMessage: "Data loaded successfully!"
    ) {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "data"
    }
}

// MARK: - Demo: Gradients

func demoGradients(_ terminal: Terminal) async throws {
    await terminal.divider("Gradient Effects")
    await terminal.writeLine("")
    await terminal.writeLine("Two-color gradients:".bold.render())
    await terminal.writeLine("")

    await terminal.writeLine("  Sunset:  " + "SwiftCLI is awesome!".gradient(.sunset))
    await terminal.writeLine("  Ocean:   " + "SwiftCLI is awesome!".gradient(.ocean))
    await terminal.writeLine("  Forest:  " + "SwiftCLI is awesome!".gradient(.forest))
    await terminal.writeLine("  Fire:    " + "SwiftCLI is awesome!".gradient(.fire))
    await terminal.writeLine("  Ice:     " + "SwiftCLI is awesome!".gradient(.ice))
    await terminal.writeLine("")

    await terminal.writeLine("Multi-color gradients:".bold.render())
    await terminal.writeLine("")
    await terminal.writeLine("  Rainbow: " + "The quick brown fox jumps over the lazy dog".rainbow)
    await terminal.writeLine("  Pastel:  " + "The quick brown fox jumps over the lazy dog".gradient(MultiGradient.pastel))
    await terminal.writeLine("")

    await terminal.writeLine("Custom gradient:".bold.render())
    await terminal.writeLine("")
    let custom = Gradient(
        from: ANSI.TrueColor(r: 255, g: 0, b: 128),
        to: ANSI.TrueColor(r: 0, g: 255, b: 255)
    )
    await terminal.writeLine("  Custom:  " + "Create your own gradients!".gradient(custom))
}

// MARK: - Demo: Keyboard Input

func demoKeyboardInput(_ terminal: Terminal) async throws {
    await terminal.divider("Keyboard Input")
    await terminal.writeLine("")
    await terminal.writeLine("Press keys to see their codes. Press ".dim.render() + "ESC".yellow.render() + " to exit.".dim.render())
    await terminal.writeLine("")

    try await terminal.enableRawMode()
    await terminal.hideCursor()

    defer {
        Task {
            try? await terminal.disableRawMode()
            await terminal.showCursor()
        }
    }

    var keyCount = 0
    while keyCount < 20 {
        let key = try await terminal.readKey()

        if key == .escape {
            await terminal.writeLine("")
            await terminal.writeLine("Escape pressed, exiting...".dim.render())
            break
        }

        if key.isInterrupt {
            throw TerminalError.cancelled
        }

        await terminal.writeLine("  Key: " + key.description.cyan.render() + " | Printable: " + (key.isPrintable ? "Yes".green.render() : "No".red.render()))
        keyCount += 1

        if keyCount >= 20 {
            await terminal.writeLine("")
            await terminal.writeLine("Max keys reached, exiting...".dim.render())
        }
    }
}

// MARK: - Demo: TUI Apps

func demoTUIApps(_ terminal: Terminal) async throws {
    await terminal.divider("TUI Apps")
    await terminal.writeLine("")

    let options = [
        // Full Apps
        Select<String>.Option("Snake Game", value: "snake", description: "Classic arcade game"),
        Select<String>.Option("Todo List", value: "todo", description: "Task manager with persistence"),
        Select<String>.Option("File Browser", value: "files", description: "Navigate filesystem"),
        Select<String>.Option("Text Editor", value: "editor", description: "Edit files with syntax highlighting"),
        // Demo Apps
        Select<String>.Option("Live System Dashboard", value: "live-dashboard", description: "Real CPU/Memory/Disk with navigation"),
        Select<String>.Option("Clock & Timer", value: "clock", description: "Live clock with stopwatch"),
        Select<String>.Option("API Data Viewer", value: "api", description: "Fetch and display GitHub repos"),
        // Simple Demos
        Select<String>.Option("Basic Demo", value: "basic", description: "Simple VStack with styled text"),
        Select<String>.Option("Feature Showcase", value: "showcase", description: "All TerminalUI features"),
        // Back
        Select<String>.Option("Back to Main Menu", value: "back", description: "Return to main menu")
    ]

    let choice = try await Select("Choose a TUI app:", options: options, terminal: terminal).run()

    if choice == "back" { return }

    await terminal.writeLine("")
    await terminal.writeLine("Launching app... Press ".dim.render() + "q".yellow.render() + " to exit.".dim.render())
    await terminal.writeLine("")
    try await Task.sleep(nanoseconds: 1_000_000_000)

    switch choice {
    // Full Apps
    case "snake":
        try await runApp(SnakeApp())
    case "todo":
        try await runApp(TodoListApp())
    case "files":
        try await runApp(FileBrowserApp())
    case "editor":
        try await runApp(TextEditorApp())
    // Demo Apps
    case "basic":
        try await runApp(BasicDemoApp())
    case "showcase":
        try await runApp(ShowcaseApp())
    case "live-dashboard":
        try await runApp(LiveDashboardApp())
    case "clock":
        try await runApp(ClockTimerApp())
    case "api":
        try await runApp(APIViewerApp())
    default:
        break
    }
}

// MARK: - TerminalUI Demo Apps

/// Basic demo - simple VStack with styled text
struct BasicDemoApp: App {
    var body: some View {
        VStack {
            Text("  TerminalUI Demo  ").bold()
            Text("  A SwiftUI-like framework for terminal UIs  ").dim()
            HStack {
                Text("  Red  ").red
                Text("  Green  ").green
                Text("  Blue  ").blue
            }
            Text("  Press 'q' to exit  ").dim()
        }
        .border(.rounded)
    }
}

/// Feature showcase - demonstrates all TerminalUI capabilities
struct ShowcaseApp: App {
    var body: some View {
        VStack {
            // Header
            Text("  TerminalUI Feature Showcase  ").bold()
                .padding(horizontal: 2, vertical: 1)
                .border(.double, title: "SwiftCLI")

            // HStack demonstration
            VStack {
                Text("  HStack with colors:  ").dim()
                HStack(spacing: 2) {
                    Text("  Red  ").red
                    Text("  Green  ").green
                    Text("  Blue  ").blue
                }
            }

            // Nested layouts
            VStack {
                Text("  Nested layouts:  ").dim()
                HStack(spacing: 1) {
                    VStack {
                        Text("  Col 1  ").bold()
                        Text("  A  ")
                    }
                    .border(.single)

                    VStack {
                        Text("  Col 2  ").bold()
                        Text("  B  ")
                    }
                    .border(.single)
                }
            }

            Text("  Press 'q' to exit  ").dim()
        }
        .border(.rounded)
    }
}

/// Dashboard demo - realistic system monitoring app
struct DashboardApp: App {
    var body: some View {
        VStack {
            // Title bar
            Text("    System Dashboard    ").bold()
                .border(.heavy, color: .cyan)

            // Status panels
            HStack(spacing: 1) {
                // CPU Panel
                VStack {
                    Text("  CPU  ").bold().green
                    Text("  45%  ").bold()
                }
                .padding(1)
                .border(.rounded, title: "CPU")

                // Memory Panel
                VStack {
                    Text("  Memory  ").bold().yellow
                    Text("  8.2 GB  ").bold()
                }
                .padding(1)
                .border(.rounded, title: "MEM")

                // Network Panel
                VStack {
                    Text("  Network  ").bold().blue
                    Text("  ↑↓ 6.6 MB/s  ")
                }
                .padding(1)
                .border(.rounded, title: "NET")
            }

            // Processes
            VStack {
                Text("  Top Processes  ").bold()
                HStack(spacing: 2) {
                    Text("  swift  ").cyan
                    Text("  12.3%  ")
                }
            }
            .border(.rounded)

            Text("  Press 'q' to exit  ").dim()
        }
    }
}

// MARK: - Demo: Terminal Info

func demoTerminalInfo(_ terminal: Terminal) async throws {
    await terminal.divider("Terminal Capabilities")
    await terminal.writeLine("")

    let caps = await terminal.capabilities
    let size = await terminal.refreshSize()

    await terminal.render(Box(
        """
        Size:     \(size.columns) x \(size.rows)
        Colors:   \(caps.colorDepth)
        Unicode:  \(caps.supportsUnicode ? "Yes" : "No")
        Program:  \(caps.terminalProgram ?? "Unknown")
        Images:   \(caps.imageProtocol?.rawValue ?? "None detected")
        """,
        style: .rounded,
        padding: .medium,
        title: "Terminal",
        borderColor: .cyan
    ))
}

// MARK: - Live Dashboard App

/// Live system monitoring dashboard with real metrics
final class LiveDashboardApp: App, @unchecked Sendable {
    // Mutable state
    private var selectedPanel: Int = 0
    private var cpuUsage: Double = 0
    private var memoryUsage: SystemMetrics.MemoryUsage = .init(used: 0, free: 0, total: 0)
    private var diskUsage: SystemMetrics.DiskUsage = .init(path: "/", total: 0, available: 0, used: 0)
    private var currentTime: String = ""

    init() {
        refreshMetrics()
    }

    var updateInterval: TimeInterval { 1.0 }

    var body: some View {
        VStack {
            // Title with time
            Text("  System Dashboard - \(currentTime)  ").bold()
                .border(.heavy, color: .cyan)

            // Metrics panels
            HStack(spacing: 1) {
                // CPU Panel
                VStack {
                    Text("  CPU  ").bold().green
                    ProgressView.percentage(cpuUsage, width: 12, style: .blocks)
                    Text("  \(SystemMetrics.getCPUCoreCount()) cores  ").dim()
                }
                .padding(1)
                .border(selectedPanel == 0 ? .double : .rounded, title: selectedPanel == 0 ? ">" : nil, color: selectedPanel == 0 ? .cyan : nil)

                // Memory Panel
                VStack {
                    Text("  Memory  ").bold().yellow
                    ProgressView.percentage(memoryUsage.usedPercentage, width: 12, style: .blocks)
                    Text("  \(String(format: "%.1f", memoryUsage.usedGB))/\(String(format: "%.0f", memoryUsage.totalGB)) GB  ").dim()
                }
                .padding(1)
                .border(selectedPanel == 1 ? .double : .rounded, title: selectedPanel == 1 ? ">" : nil, color: selectedPanel == 1 ? .cyan : nil)

                // Disk Panel
                VStack {
                    Text("  Disk  ").bold().blue
                    ProgressView.percentage(diskUsage.usedPercentage, width: 12, style: .blocks)
                    Text("  \(String(format: "%.0f", diskUsage.usedGB))/\(String(format: "%.0f", diskUsage.totalGB)) GB  ").dim()
                }
                .padding(1)
                .border(selectedPanel == 2 ? .double : .rounded, title: selectedPanel == 2 ? ">" : nil, color: selectedPanel == 2 ? .cyan : nil)
            }

            // Load average
            let load = SystemMetrics.getLoadAverage()
            Text("  Load: \(String(format: "%.2f", load.one)) / \(String(format: "%.2f", load.five)) / \(String(format: "%.2f", load.fifteen))  ").dim()

            // Navigation help
            Text("  <- -> Navigate  |  q: Quit  ").dim()
        }
    }

    func onUpdate() async {
        refreshMetrics()
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        switch key {
        case .arrow(.left):
            selectedPanel = max(0, selectedPanel - 1)
            return true
        case .arrow(.right):
            selectedPanel = min(2, selectedPanel + 1)
            return true
        default:
            return false
        }
    }

    private func refreshMetrics() {
        cpuUsage = SystemMetrics.getCPUUsage().total
        memoryUsage = SystemMetrics.getMemoryUsage()
        diskUsage = SystemMetrics.getDiskUsage()

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        currentTime = formatter.string(from: Date())
    }
}

// MARK: - Clock & Timer App

/// Live clock with stopwatch functionality
final class ClockTimerApp: App, @unchecked Sendable {
    // State
    private var currentTime: String = ""
    private var currentDate: String = ""
    private var stopwatchRunning: Bool = false
    private var stopwatchStart: Date? = nil
    private var stopwatchElapsed: TimeInterval = 0
    private var selectedPanel: Int = 0

    init() {
        updateTime()
    }

    var updateInterval: TimeInterval { 0.1 }  // Fast updates for stopwatch

    var body: some View {
        VStack {
            // Main clock display
            VStack {
                Text("  \(currentTime)  ").bold()
                Text("  \(currentDate)  ").dim()
            }
            .padding(1)
            .border(.double, title: "Time", color: .cyan)

            // Panels
            HStack(spacing: 1) {
                // Stopwatch panel
                VStack {
                    Text("  Stopwatch  ").bold()
                    Text("  \(formatStopwatch())  ")
                    Text("  [S]tart/Stop  [R]eset  ").dim()
                }
                .padding(1)
                .border(selectedPanel == 0 ? .double : .rounded, title: selectedPanel == 0 ? ">" : nil, color: selectedPanel == 0 ? .green : nil)

                // World clocks panel
                VStack {
                    Text("  World Clocks  ").bold()
                    HStack {
                        Text("  NYC: \(timeIn(zone: "America/New_York"))  ").dim()
                    }
                    HStack {
                        Text("  London: \(timeIn(zone: "Europe/London"))  ").dim()
                    }
                    HStack {
                        Text("  Tokyo: \(timeIn(zone: "Asia/Tokyo"))  ").dim()
                    }
                }
                .padding(1)
                .border(selectedPanel == 1 ? .double : .rounded, title: selectedPanel == 1 ? ">" : nil, color: selectedPanel == 1 ? .blue : nil)
            }

            Text("  <- -> Navigate  |  s: Start/Stop  |  r: Reset  |  q: Quit  ").dim()
        }
    }

    func onUpdate() async {
        updateTime()
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        switch key {
        case .arrow(.left):
            selectedPanel = max(0, selectedPanel - 1)
            return true
        case .arrow(.right):
            selectedPanel = min(1, selectedPanel + 1)
            return true
        case .character("s"), .character("S"):
            toggleStopwatch()
            return true
        case .character("r"), .character("R"):
            resetStopwatch()
            return true
        default:
            return false
        }
    }

    private func updateTime() {
        let now = Date()

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        currentTime = timeFormatter.string(from: now)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        currentDate = dateFormatter.string(from: now)

        // Update stopwatch elapsed time if running
        if stopwatchRunning, let start = stopwatchStart {
            stopwatchElapsed = now.timeIntervalSince(start)
        }
    }

    private func toggleStopwatch() {
        if stopwatchRunning {
            // Stop
            stopwatchRunning = false
        } else {
            // Start
            stopwatchRunning = true
            stopwatchStart = Date().addingTimeInterval(-stopwatchElapsed)
        }
    }

    private func resetStopwatch() {
        stopwatchRunning = false
        stopwatchStart = nil
        stopwatchElapsed = 0
    }

    private func formatStopwatch() -> String {
        let total = stopwatchElapsed
        let minutes = Int(total) / 60
        let seconds = Int(total) % 60
        let hundredths = Int((total.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }

    private func timeIn(zone: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone(identifier: zone)
        return formatter.string(from: Date())
    }
}

// MARK: - API Viewer App

/// GitHub repository viewer with API fetching
final class APIViewerApp: App, @unchecked Sendable {
    enum LoadState {
        case loading
        case loaded([Repository])
        case error(String)
    }

    struct Repository: Sendable {
        let name: String
        let stars: Int
        let description: String
    }

    // State
    private var loadState: LoadState = .loading
    private var selectedIndex: Int = 0
    private var lastFetch: String = "Never"

    init() {}

    var updateInterval: TimeInterval {
        if case .loading = loadState { return 0.1 }  // Animate spinner during loading
        return 0
    }

    var body: some View {
        VStack {
            // Header
            Text("  GitHub: apple/repos  ").bold()
                .border(.heavy, title: "API Viewer", color: .cyan)

            // Content based on state
            contentView

            // Status bar
            Text("  Last fetch: \(lastFetch)  |  r: Refresh  |  q: Quit  ").dim()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch loadState {
        case .loading:
            VStack {
                SpinnerView(style: .dots, message: "Fetching repository data...")
            }
            .padding(2)
            .border(.rounded)

        case .loaded(let repos):
            VStack {
                Text("  Repositories (\(repos.count))  ").bold()

                // Show up to 6 repos with selection
                ForEach(0..<min(6, repos.count)) { [self] i in
                    let repo = repos[i]
                    let isSelected = i == self.selectedIndex
                    let prefix = isSelected ? ">" : " "
                    let stars = "★ \(self.formatNumber(repo.stars))"

                    if isSelected {
                        Text("  \(prefix) \(repo.name)  \(stars)  ").cyan
                    } else {
                        Text("  \(prefix) \(repo.name)  \(stars)  ")
                    }
                }

                // Selected repo description
                if !repos.isEmpty && selectedIndex < repos.count {
                    Text("  \(repos[selectedIndex].description.prefix(50))...  ").dim()
                }
            }
            .padding(1)
            .border(.rounded)

        case .error(let message):
            VStack {
                Text("  Error  ").bold().red
                Text("  \(message)  ").dim()
                Text("  Press 'r' to retry  ").dim()
            }
            .padding(2)
            .border(.rounded, color: .red)
        }
    }

    func onAppear() async {
        // Start fetch in background so event loop can run (for spinner animation)
        Task {
            await fetchData()
        }
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        switch key {
        case .arrow(.up):
            if case .loaded(let repos) = loadState {
                selectedIndex = max(0, selectedIndex - 1)
                _ = repos // silence warning
                return true
            }
        case .arrow(.down):
            if case .loaded(let repos) = loadState, !repos.isEmpty {
                selectedIndex = min(repos.count - 1, selectedIndex + 1)
                return true
            }
        case .character("r"), .character("R"):
            await fetchData()
            return true
        default:
            break
        }
        return false
    }

    private func fetchData() async {
        loadState = .loading

        // Simulated API data (to avoid network dependency in demo)
        // In a real app, you'd use URLSession here
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        let repos: [Repository] = [
            Repository(name: "swift", stars: 67234, description: "The Swift Programming Language"),
            Repository(name: "swift-evolution", stars: 15123, description: "This maintains proposals for changes and enhancements to Swift"),
            Repository(name: "swift-package-manager", stars: 9876, description: "The Package Manager for the Swift Programming Language"),
            Repository(name: "swift-nio", stars: 7890, description: "Event-driven network application framework"),
            Repository(name: "swift-syntax", stars: 3456, description: "A set of Swift libraries for parsing Swift source code"),
            Repository(name: "swift-format", stars: 2345, description: "Formatting technology for Swift source code"),
            Repository(name: "swift-argument-parser", stars: 3234, description: "Straightforward, type-safe argument parsing for Swift"),
            Repository(name: "swift-collections", stars: 3567, description: "Commonly used data structures for Swift")
        ]

        loadState = .loaded(repos)
        selectedIndex = 0

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        lastFetch = formatter.string(from: Date())
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1000 {
            return String(format: "%.1fk", Double(n) / 1000)
        }
        return "\(n)"
    }
}
