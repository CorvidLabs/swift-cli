import CLI
import Foundation

/// Test target information
struct TestTarget: Sendable {
    let name: String
    let module: String

    static let targets: [TestTarget] = [
        TestTarget(name: "ANSITests", module: "ANSI"),
        TestTarget(name: "TerminalCoreTests", module: "TerminalCore"),
        TestTarget(name: "TerminalStyleTests", module: "TerminalStyle"),
        TestTarget(name: "TerminalInputTests", module: "TerminalInput"),
        TestTarget(name: "TerminalLayoutTests", module: "TerminalLayout"),
        TestTarget(name: "TerminalComponentsTests", module: "TerminalComponents"),
        TestTarget(name: "TerminalGraphicsTests", module: "TerminalGraphics"),
        TestTarget(name: "TerminalUITests", module: "TerminalUI")
    ]
}

/// Test result from running tests
struct TestResult: Sendable {
    let name: String
    let passed: Bool
    let duration: String
}

/// Thread-safe output collector for async process I/O
private final class OutputCollector: @unchecked Sendable {
    private var lines: [String]
    private let lock = NSLock()

    init(initialLines: [String]) {
        self.lines = initialLines
    }

    func append(_ newLines: [String]) {
        lock.lock()
        defer { lock.unlock() }
        lines.append(contentsOf: newLines)
    }

    func getLines() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return lines
    }
}

/// Interactive test runner
final class TestRunnerApp: App, @unchecked Sendable {
    enum ViewState {
        case targetList
        case running(target: String, output: [String])
        case results(target: String, results: [TestResult], totalTime: String)
    }

    private var state: ViewState = .targetList
    private var selectedIndex: Int = 0
    private var scrollOffset: Int = 0
    private var terminalHeight: Int = 20

    init() {}

    func onAppear() async {
        terminalHeight = await Terminal.shared.size.rows - 10
    }

    var updateInterval: TimeInterval {
        switch state {
        case .running:
            return 0.1  // Re-render every 100ms while tests run
        default:
            return 0
        }
    }

    var body: some View {
        switch state {
        case .targetList:
            targetListView
        case .running(let target, let output):
            runningView(target: target, output: output)
        case .results(let target, let results, let totalTime):
            resultsView(target: target, results: results, totalTime: totalTime)
        }
    }

    @ViewBuilder
    private var targetListView: some View {
        VStack {
            Text("  Test Runner  ").bold()
                .border(.double, title: "Tests", color: .green)

            VStack {
                Text("  Test Targets:  ").bold()

                ForEach(0..<TestTarget.targets.count) { [self] i in
                    let target = TestTarget.targets[i]
                    let isSelected = i == self.selectedIndex
                    let prefix = isSelected ? ">" : " "

                    if isSelected {
                        Text("  \(prefix) \(target.name)  ").cyan
                    } else {
                        Text("  \(prefix) \(target.name)  ")
                    }
                }
            }
            .padding(1)
            .border(.rounded)

            Text("  ↑↓ Navigate  |  Enter: Run Tests  |  a: Run All  |  q: Back  ").dim()
        }
    }

    @ViewBuilder
    private func runningView(target: String, output: [String]) -> some View {
        let visibleLines = output.suffix(terminalHeight)

        VStack {
            HStack {
                SpinnerView(style: .dots, message: "Running \(target)...")
            }
            .border(.single, color: .yellow)

            VStack {
                ForEach(0..<visibleLines.count) { i in
                    let line = Array(visibleLines)[i]
                    Text("  \(line)  ").dim()
                }
            }
            .padding(1)
            .border(.rounded)

            Text("  Building and running tests...  ").dim()
        }
    }

    @ViewBuilder
    private func resultsView(target: String, results: [TestResult], totalTime: String) -> some View {
        let passed = results.filter { $0.passed }.count
        let failed = results.count - passed
        let visibleResults = Array(results.dropFirst(scrollOffset).prefix(terminalHeight))

        VStack {
            HStack {
                Text("  \(target)  ").bold()
                if failed == 0 {
                    Text("  ✓ All Passed  ").green
                } else {
                    Text("  ✗ \(failed) Failed  ").red
                }
            }
            .border(.double, title: "Results", color: failed == 0 ? .green : .red)

            VStack {
                ForEach(0..<visibleResults.count) { i in
                    let result = visibleResults[i]
                    let icon = result.passed ? "✓" : "✗"
                    let color: Text = result.passed
                        ? Text("  \(icon) \(result.name.padding(toLength: 35, withPad: " ", startingAt: 0)) \(result.duration)  ").green
                        : Text("  \(icon) \(result.name.padding(toLength: 35, withPad: " ", startingAt: 0)) \(result.duration)  ").red

                    color
                }
            }
            .padding(1)
            .border(.rounded)

            HStack {
                Text("  \(passed)/\(results.count) passed  ").bold()
                Text("  (\(totalTime))  ").dim()
            }

            Text("  ↑↓ Scroll  |  Enter: Run Again  |  Esc: Back  ").dim()
        }
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        switch state {
        case .targetList:
            return await handleTargetListKeys(key)
        case .running:
            // Allow Ctrl+C to quit during test run
            if key.isInterrupt {
                return false
            }
            return true  // Consume other keys
        case .results(let target, _, _):
            return await handleResultsKeys(key, target: target)
        }
    }

    private func handleTargetListKeys(_ key: KeyCode) async -> Bool {
        switch key {
        case .arrow(.up):
            selectedIndex = max(0, selectedIndex - 1)
            return true
        case .arrow(.down):
            guard !TestTarget.targets.isEmpty else { return false }
            selectedIndex = min(TestTarget.targets.count - 1, selectedIndex + 1)
            return true
        case .enter:
            let target = TestTarget.targets[selectedIndex]
            state = .running(target: target.name, output: ["Building...", "Starting tests..."])
            Task { [self] in
                await self.runTests(target: target.name)
            }
            return true
        case .character("a"), .character("A"):
            state = .running(target: "All Tests", output: ["Building...", "Starting all tests..."])
            Task { [self] in
                await self.runAllTests()
            }
            return true
        default:
            return false
        }
    }

    private func handleResultsKeys(_ key: KeyCode, target: String) async -> Bool {
        switch key {
        case .arrow(.up):
            scrollOffset = max(0, scrollOffset - 1)
            return true
        case .arrow(.down):
            scrollOffset += 1
            return true
        case .enter:
            await runTests(target: target)
            return true
        case .escape:
            state = .targetList
            scrollOffset = 0
            return true
        default:
            return false
        }
    }

    private func runTests(target: String) async {
        await runProcess(
            arguments: ["test", "--filter", target],
            target: target,
            initialMessages: ["Building...", "Running tests..."]
        )
    }

    private func runAllTests() async {
        await runProcess(
            arguments: ["test"],
            target: "All Tests",
            initialMessages: ["Building...", "Running all tests..."]
        )
    }

    /// Shared process runner with non-blocking I/O using readabilityHandler
    private func runProcess(arguments: [String], target: String, initialMessages: [String]) async {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let startTime = Date()

        // Thread-safe output collector
        let outputCollector = OutputCollector(initialLines: initialMessages)
        let fileHandle = pipe.fileHandleForReading

        // Setup async readability handler - called when data is available
        fileHandle.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            let newLines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
            outputCollector.append(newLines)
        }

        do {
            try process.run()

            // Wait for process while allowing event loop to update UI
            while process.isRunning {
                // Update state with current output (allows spinner to animate)
                let currentLines = outputCollector.getLines()
                state = .running(target: target, output: currentLines)
                try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms - just for periodic state sync
            }

            // Cleanup handler before final read
            fileHandle.readabilityHandler = nil

            // Read any remaining output after process exits
            let remainingData = fileHandle.readDataToEndOfFile()
            if !remainingData.isEmpty, let text = String(data: remainingData, encoding: .utf8) {
                let newLines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
                outputCollector.append(newLines)
            }

            let finalLines = outputCollector.getLines()
            let results = parseTestOutput(finalLines.joined(separator: "\n"))
            let elapsed = Date().timeIntervalSince(startTime)
            let totalTime = String(format: "%.2fs", elapsed)

            state = .results(target: target, results: results, totalTime: totalTime)
        } catch {
            fileHandle.readabilityHandler = nil
            state = .results(target: target, results: [
                TestResult(name: "Error running tests", passed: false, duration: error.localizedDescription)
            ], totalTime: "0s")
        }
    }

    private func parseTestOutput(_ output: String) -> [TestResult] {
        var results: [TestResult] = []
        let lines = output.components(separatedBy: "\n")

        for line in lines {
            // Parse test result lines like:
            // Test Case '-[ANSITests.ANSITests testBasicColors]' passed (0.001 seconds).
            if line.contains("Test Case") && (line.contains("passed") || line.contains("failed")) {
                let passed = line.contains("passed")

                // Extract test name
                if let start = line.range(of: "Test Case '"),
                   let end = line.range(of: "' ") {
                    let testName = String(line[start.upperBound..<end.lowerBound])
                    let shortName = testName.components(separatedBy: " ").last ?? testName

                    // Extract duration
                    var duration = ""
                    if let dStart = line.range(of: "("),
                       let dEnd = line.range(of: ")") {
                        duration = String(line[dStart.upperBound..<dEnd.lowerBound])
                    }

                    results.append(TestResult(name: shortName, passed: passed, duration: duration))
                }
            }
        }

        // If no results parsed, check for build errors or other output
        if results.isEmpty && !output.isEmpty {
            if output.contains("error:") {
                results.append(TestResult(name: "Build Error", passed: false, duration: "See output"))
            } else if output.contains("Build complete") {
                results.append(TestResult(name: "All tests passed", passed: true, duration: ""))
            }
        }

        return results
    }
}
