import ANSI
import TerminalUI
import TerminalInput
import Foundation

/// File system browser with tree navigation
final class FileBrowserApp: App, @unchecked Sendable {
    struct FileNode: Sendable {
        let path: String
        let name: String
        let isDirectory: Bool
        let size: Int64
        let modifiedDate: Date
        var isExpanded: Bool = false
        var children: [FileNode] = []
        var depth: Int = 0
    }

    // State
    private var currentPath: String
    private var nodes: [FileNode] = []
    private var flattenedNodes: [FileNode] = []
    private var selectedIndex: Int = 0
    private var scrollOffset: Int = 0
    private let visibleRows = 18
    private var preview: [String] = []
    private var errorMessage: String? = nil

    init() {
        currentPath = FileManager.default.currentDirectoryPath
        loadDirectory()
    }

    var updateInterval: TimeInterval { 0 }

    var body: some View {
        VStack {
            // Path breadcrumb
            Text("  \(currentPath)  ").bold()
                .border(.single, color: .cyan)

            // Main content
            HStack(spacing: 1) {
                // File list
                VStack {
                    ForEach(0..<visibleRows) { [self] row in
                        Text(renderRow(row))
                    }
                }
                .border(.rounded, title: "Files")

                // Preview panel
                VStack {
                    ForEach(0..<min(visibleRows, preview.count)) { [self] row in
                        Text(previewRow(row))
                    }
                }
                .border(.rounded, title: "Preview")
            }

            // Status bar
            Text(statusText).dim()

            // Help
            Text("  Arrows: Navigate  |  Enter: Open/Expand  |  Backspace: Parent  |  q: Quit  ").dim()
        }
    }

    private func renderRow(_ row: Int) -> String {
        let index = scrollOffset + row
        guard index < flattenedNodes.count else {
            return String(repeating: " ", count: 40)
        }

        let node = flattenedNodes[index]
        let isSelected = index == selectedIndex

        var line = ""

        // Selection indicator
        if isSelected {
            line += "> ".cyan.bold.render()
        } else {
            line += "  "
        }

        // Indentation
        line += String(repeating: "  ", count: node.depth)

        // Expand/collapse indicator for directories
        if node.isDirectory {
            if node.isExpanded {
                line += "v ".yellow.render()
            } else {
                line += "> ".yellow.render()
            }
        } else {
            line += "  "
        }

        // Icon and name
        let icon = node.isDirectory ? "/" : ""
        let name = node.name + icon

        if node.isDirectory {
            if isSelected {
                line += name.cyan.bold.render()
            } else {
                line += name.cyan.render()
            }
        } else {
            if isSelected {
                line += name.bold.render()
            } else {
                line += name
            }
        }

        // Pad to fixed width
        let visibleLen = visibleLength(line)
        if visibleLen < 40 {
            line += String(repeating: " ", count: 40 - visibleLen)
        }

        return line
    }

    private func previewRow(_ row: Int) -> String {
        guard row < preview.count else {
            return String(repeating: " ", count: 35)
        }
        var line = preview[row]
        // Truncate if too long
        if line.count > 35 {
            line = String(line.prefix(32)) + "..."
        }
        // Pad
        let visibleLen = visibleLength(line)
        if visibleLen < 35 {
            line += String(repeating: " ", count: 35 - visibleLen)
        }
        return line
    }

    private func visibleLength(_ str: String) -> Int {
        // Strip ANSI codes for length calculation
        let pattern = "\u{001B}\\[[0-9;]*m"
        let stripped = str.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        return stripped.count
    }

    private var statusText: String {
        if let error = errorMessage {
            return "  Error: \(error)  ".red.render()
        }
        guard selectedIndex < flattenedNodes.count else {
            return "  Empty directory  "
        }
        let node = flattenedNodes[selectedIndex]
        let sizeStr = formatSize(node.size)
        let dateStr = formatDate(node.modifiedDate)
        return "  \(sizeStr)  |  \(dateStr)  "
    }

    private func formatSize(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB"]
        var size = Double(bytes)
        var unitIndex = 0
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        if unitIndex == 0 {
            return "\(Int(size)) \(units[unitIndex])"
        }
        return String(format: "%.1f %@", size, units[unitIndex])
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy HH:mm"
        return formatter.string(from: date)
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        errorMessage = nil

        switch key {
        case .arrow(.up):
            if selectedIndex > 0 {
                selectedIndex -= 1
                updateScroll()
                updatePreview()
            }
            return true

        case .arrow(.down):
            if selectedIndex < flattenedNodes.count - 1 {
                selectedIndex += 1
                updateScroll()
                updatePreview()
            }
            return true

        case .arrow(.right), .enter:
            expandOrOpen()
            return true

        case .arrow(.left):
            collapseOrParent()
            return true

        case .backspace:
            goToParent()
            return true

        default:
            return false
        }
    }

    private func expandOrOpen() {
        guard selectedIndex < flattenedNodes.count else { return }
        var node = flattenedNodes[selectedIndex]

        if node.isDirectory {
            if !node.isExpanded {
                // Expand
                loadChildren(for: &node)
                updateNodeExpanded(at: selectedIndex, expanded: true, children: node.children)
                rebuildFlattenedList()
            }
        }
        updatePreview()
    }

    private func collapseOrParent() {
        guard selectedIndex < flattenedNodes.count else { return }
        let node = flattenedNodes[selectedIndex]

        if node.isDirectory && node.isExpanded {
            // Collapse
            updateNodeExpanded(at: selectedIndex, expanded: false, children: [])
            rebuildFlattenedList()
        } else if node.depth > 0 {
            // Go to parent node
            for i in stride(from: selectedIndex - 1, through: 0, by: -1) {
                if flattenedNodes[i].depth < node.depth {
                    selectedIndex = i
                    updateScroll()
                    break
                }
            }
        } else {
            goToParent()
        }
        updatePreview()
    }

    private func goToParent() {
        let parentPath = (currentPath as NSString).deletingLastPathComponent
        if parentPath != currentPath {
            currentPath = parentPath
            loadDirectory()
        }
    }

    private func loadDirectory() {
        nodes = []
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: currentPath)
            for name in contents.sorted() {
                if name.hasPrefix(".") { continue } // Skip hidden files
                let fullPath = (currentPath as NSString).appendingPathComponent(name)
                if let node = createNode(path: fullPath, depth: 0) {
                    nodes.append(node)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        selectedIndex = 0
        scrollOffset = 0
        rebuildFlattenedList()
        updatePreview()
    }

    private func createNode(path: String, depth: Int) -> FileNode? {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return nil }

        let attrs = try? fm.attributesOfItem(atPath: path)
        let size = (attrs?[.size] as? Int64) ?? 0
        let modDate = (attrs?[.modificationDate] as? Date) ?? Date()

        return FileNode(
            path: path,
            name: (path as NSString).lastPathComponent,
            isDirectory: isDir.boolValue,
            size: size,
            modifiedDate: modDate,
            isExpanded: false,
            children: [],
            depth: depth
        )
    }

    private func loadChildren(for node: inout FileNode) {
        guard node.isDirectory else { return }
        node.children = []
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: node.path)
            for name in contents.sorted() {
                if name.hasPrefix(".") { continue }
                let fullPath = (node.path as NSString).appendingPathComponent(name)
                if var child = createNode(path: fullPath, depth: node.depth + 1) {
                    child.depth = node.depth + 1
                    node.children.append(child)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateNodeExpanded(at index: Int, expanded: Bool, children: [FileNode]) {
        // Find and update the node in the tree
        func updateInList(_ list: inout [FileNode], targetPath: String) -> Bool {
            for i in list.indices {
                if list[i].path == targetPath {
                    list[i].isExpanded = expanded
                    list[i].children = children
                    return true
                }
                if updateInList(&list[i].children, targetPath: targetPath) {
                    return true
                }
            }
            return false
        }

        let targetPath = flattenedNodes[index].path
        _ = updateInList(&nodes, targetPath: targetPath)
    }

    private func rebuildFlattenedList() {
        flattenedNodes = []
        func flatten(_ list: [FileNode]) {
            for node in list {
                flattenedNodes.append(node)
                if node.isExpanded {
                    flatten(node.children)
                }
            }
        }
        flatten(nodes)
    }

    private func updateScroll() {
        if selectedIndex < scrollOffset {
            scrollOffset = selectedIndex
        } else if selectedIndex >= scrollOffset + visibleRows {
            scrollOffset = selectedIndex - visibleRows + 1
        }
    }

    private func updatePreview() {
        preview = []
        guard selectedIndex < flattenedNodes.count else { return }
        let node = flattenedNodes[selectedIndex]

        if node.isDirectory {
            preview = ["<directory>"]
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: node.path)
                preview.append("\(contents.count) items")
            } catch {
                preview.append("Cannot read")
            }
        } else {
            // Try to read file preview
            if node.size > 100_000 {
                preview = ["<file too large>"]
            } else if let content = try? String(contentsOfFile: node.path, encoding: .utf8) {
                preview = content.components(separatedBy: .newlines)
                    .prefix(visibleRows)
                    .map { String($0.prefix(35)) }
            } else {
                preview = ["<binary file>"]
            }
        }
    }
}
