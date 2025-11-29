import CLI
import Foundation

/// Module information for the library browser
struct ModuleInfo: Sendable {
    let name: String
    let description: String
    let files: [String]

    static let modules: [ModuleInfo] = [
        ModuleInfo(
            name: "ANSI",
            description: "Pure ANSI escape code generation",
            files: ["ANSI.swift", "BoxDrawing.swift", "Color.swift", "Cursor.swift", "Erase.swift", "Hyperlink.swift", "Report.swift", "Screen.swift", "Style.swift"]
        ),
        ModuleInfo(
            name: "TerminalCore",
            description: "Low-level terminal I/O operations",
            files: ["Terminal.swift", "TerminalCapabilities.swift", "TerminalConfiguration.swift", "TerminalError.swift", "TerminalSize.swift"]
        ),
        ModuleInfo(
            name: "TerminalStyle",
            description: "Colors, text styles, gradients",
            files: ["Gradient.swift", "String+Style.swift", "StyledText.swift", "Terminal+Style.swift", "Theme.swift"]
        ),
        ModuleInfo(
            name: "TerminalInput",
            description: "Keyboard and mouse input handling",
            files: ["InputEvent.swift", "InputReader.swift", "KeyCode.swift", "LineEditor.swift", "Modifiers.swift", "MouseEvent.swift", "Terminal+Input.swift"]
        ),
        ModuleInfo(
            name: "TerminalLayout",
            description: "Boxes, tables, panels, tree views",
            files: ["Box.swift", "BoxStyle.swift", "Divider.swift", "Panel.swift", "Renderable.swift", "Table.swift", "Terminal+Layout.swift", "Tree.swift"]
        ),
        ModuleInfo(
            name: "TerminalComponents",
            description: "Progress bars, spinners, prompts",
            files: ["Confirm.swift", "Input.swift", "MultiSelect.swift", "ProgressBar.swift", "Select.swift", "Spinner.swift"]
        ),
        ModuleInfo(
            name: "TerminalGraphics",
            description: "Terminal image protocols",
            files: ["ITerm2Image.swift", "ImageProtocol.swift", "KittyImage.swift", "SixelImage.swift", "TerminalImage.swift"]
        ),
        ModuleInfo(
            name: "TerminalUI",
            description: "SwiftUI-like TUI framework",
            files: ["App.swift", "Border.swift", "EmptyView.swift", "ForEach.swift", "HStack.swift", "Padding.swift", "ProgressView.swift", "RenderEngine.swift", "SystemMetrics.swift", "Text.swift", "VStack.swift", "View.swift", "ViewBuilder.swift", "ZStack.swift"]
        )
    ]
}

/// Interactive module/code browser
final class ExploreApp: App, @unchecked Sendable {
    enum ViewState {
        case moduleList
        case fileList(ModuleInfo)
        case codeView(module: String, file: String, content: [String], scrollOffset: Int)
    }

    private var state: ViewState = .moduleList
    private var selectedIndex: Int = 0
    private var projectRoot: String
    private var terminalHeight: Int = 20

    init() {
        // Find project root (where Package.swift is)
        var path = FileManager.default.currentDirectoryPath
        while !FileManager.default.fileExists(atPath: "\(path)/Package.swift") {
            let parent = (path as NSString).deletingLastPathComponent
            if parent == path { break }
            path = parent
        }
        self.projectRoot = path
    }

    var updateInterval: TimeInterval { 0 }

    func onAppear() async {
        terminalHeight = await Terminal.shared.size.rows - 6
    }

    func onUpdate() async {
        terminalHeight = await Terminal.shared.size.rows - 6
    }

    var body: some View {
        switch state {
        case .moduleList:
            moduleListView
        case .fileList(let module):
            fileListView(module)
        case .codeView(let module, let file, let content, let scrollOffset):
            codeViewBody(module: module, file: file, content: content, scrollOffset: scrollOffset)
        }
    }

    @ViewBuilder
    private var moduleListView: some View {
        VStack {
            Text("  Explore swift-cli  ").bold()
                .border(.double, title: "Library", color: .cyan)

            VStack {
                ForEach(0..<ModuleInfo.modules.count) { [self] i in
                    let module = ModuleInfo.modules[i]
                    let isSelected = i == self.selectedIndex
                    let prefix = isSelected ? ">" : " "

                    if isSelected {
                        Text("  \(prefix) \(module.name.padding(toLength: 18, withPad: " ", startingAt: 0)) \(module.description)  ").cyan
                    } else {
                        HStack {
                            Text("  \(prefix) \(module.name.padding(toLength: 18, withPad: " ", startingAt: 0))  ").bold()
                            Text("\(module.description)  ").dim()
                        }
                    }
                }
            }
            .padding(1)
            .border(.rounded)

            Text("  ↑↓ Navigate  |  Enter: Browse Files  |  q: Back  ").dim()
        }
    }

    @ViewBuilder
    private func fileListView(_ module: ModuleInfo) -> some View {
        VStack {
            Text("  \(module.name)  ").bold()
                .border(.double, title: "Module", color: .cyan)

            Text("  \(module.description)  ").dim()

            VStack {
                Text("  Files (\(module.files.count)):  ").bold()

                ForEach(0..<module.files.count) { [self] i in
                    let file = module.files[i]
                    let isSelected = i == self.selectedIndex
                    let prefix = isSelected ? ">" : " "

                    if isSelected {
                        Text("  \(prefix) \(file)  ").cyan
                    } else {
                        Text("  \(prefix) \(file)  ")
                    }
                }
            }
            .padding(1)
            .border(.rounded)

            Text("  ↑↓ Navigate  |  Enter: View Code  |  Esc: Back  ").dim()
        }
    }

    @ViewBuilder
    private func codeViewBody(module: String, file: String, content: [String], scrollOffset: Int) -> some View {
        let visibleLines = min(terminalHeight, content.count - scrollOffset)
        let endLine = min(scrollOffset + visibleLines, content.count)

        VStack {
            HStack {
                Text("  \(module)/\(file)  ").bold().cyan
                Text("  Lines \(scrollOffset + 1)-\(endLine) of \(content.count)  ").dim()
            }
            .border(.single, color: .cyan)

            VStack {
                ForEach(scrollOffset..<endLine) { i in
                    let lineNum = String(format: "%4d", i + 1)
                    let line = content[i]
                    HStack {
                        Text("  \(lineNum) │ ").dim()
                        Text("\(line)  ")
                    }
                }
            }

            Text("  ↑↓ Scroll  |  PgUp/PgDn: Page  |  Esc: Back  ").dim()
        }
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        switch state {
        case .moduleList:
            return handleModuleListKeys(key)
        case .fileList(let module):
            return handleFileListKeys(key, module: module)
        case .codeView(let module, let file, let content, let scrollOffset):
            return handleCodeViewKeys(key, module: module, file: file, content: content, scrollOffset: scrollOffset)
        }
    }

    private func handleModuleListKeys(_ key: KeyCode) -> Bool {
        switch key {
        case .arrow(.up):
            selectedIndex = max(0, selectedIndex - 1)
            return true
        case .arrow(.down):
            guard !ModuleInfo.modules.isEmpty else { return false }
            selectedIndex = min(ModuleInfo.modules.count - 1, selectedIndex + 1)
            return true
        case .enter:
            let module = ModuleInfo.modules[selectedIndex]
            state = .fileList(module)
            selectedIndex = 0
            return true
        default:
            return false
        }
    }

    private func handleFileListKeys(_ key: KeyCode, module: ModuleInfo) -> Bool {
        switch key {
        case .arrow(.up):
            selectedIndex = max(0, selectedIndex - 1)
            return true
        case .arrow(.down):
            guard !module.files.isEmpty else { return false }
            selectedIndex = min(module.files.count - 1, selectedIndex + 1)
            return true
        case .enter:
            let file = module.files[selectedIndex]
            let filePath = "\(projectRoot)/Sources/\(module.name)/\(file)"
            if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
                let lines = content.components(separatedBy: "\n")
                state = .codeView(module: module.name, file: file, content: lines, scrollOffset: 0)
            }
            return true
        case .escape:
            state = .moduleList
            selectedIndex = ModuleInfo.modules.firstIndex { $0.name == module.name } ?? 0
            return true
        default:
            return false
        }
    }

    private func handleCodeViewKeys(_ key: KeyCode, module: String, file: String, content: [String], scrollOffset: Int) -> Bool {
        let maxOffset = max(0, content.count - terminalHeight)

        switch key {
        case .arrow(.up):
            state = .codeView(module: module, file: file, content: content, scrollOffset: max(0, scrollOffset - 1))
            return true
        case .arrow(.down):
            state = .codeView(module: module, file: file, content: content, scrollOffset: min(maxOffset, scrollOffset + 1))
            return true
        case .pageUp:
            state = .codeView(module: module, file: file, content: content, scrollOffset: max(0, scrollOffset - terminalHeight))
            return true
        case .pageDown:
            state = .codeView(module: module, file: file, content: content, scrollOffset: min(maxOffset, scrollOffset + terminalHeight))
            return true
        case .escape:
            if let moduleInfo = ModuleInfo.modules.first(where: { $0.name == module }) {
                state = .fileList(moduleInfo)
                selectedIndex = moduleInfo.files.firstIndex(of: file) ?? 0
            }
            return true
        default:
            return false
        }
    }
}
