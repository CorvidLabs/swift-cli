import ANSI
import TerminalUI
import TerminalInput
import Foundation

/// Interactive Todo List app with persistence
final class TodoListApp: App, @unchecked Sendable {
    enum Filter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Done"
    }

    enum Priority: Int, Codable, CaseIterable {
        case high = 1
        case medium = 2
        case low = 3

        var symbol: String {
            switch self {
            case .high: return "!"
            case .medium: return "-"
            case .low: return " "
            }
        }

        var color: ANSI.Color {
            switch self {
            case .high: return .red
            case .medium: return .yellow
            case .low: return .blue
            }
        }
    }

    struct TodoItem: Codable, Sendable {
        var id: UUID
        var text: String
        var completed: Bool
        var priority: Priority
        var createdAt: Date

        init(text: String, priority: Priority = .medium) {
            self.id = UUID()
            self.text = text
            self.completed = false
            self.priority = priority
            self.createdAt = Date()
        }
    }

    // State
    private var todos: [TodoItem] = []
    private var selectedIndex: Int = 0
    private var filter: Filter = .all
    private var isAddingNew: Bool = false
    private var newTodoText: String = ""
    private var isEditing: Bool = false
    private var editText: String = ""

    init() {
        loadTodos()
    }

    var updateInterval: TimeInterval { 0 }

    var body: some View {
        VStack {
            // Header
            Text("  Todo List  ").bold()
                .border(.double, color: .cyan)

            // Filter tabs
            Text(renderFilterTabs() + "  (\(filteredTodos.count) items)".dim.render())

            // Todo list
            listView

            // Input or help
            inputOrHelpView
        }
    }

    private var listView: AnyView {
        if filteredTodos.isEmpty {
            AnyView(
                VStack {
                    Text("  No items  ").dim()
                    Text("  Press 'a' to add a new task  ").dim()
                }
                .border(.rounded)
            )
        } else {
            AnyView(
                VStack {
                    ForEach(0..<filteredTodos.count) { [self] index in
                        Text(renderTodoItem(filteredTodos[index], index: index))
                    }
                }
                .border(.rounded)
            )
        }
    }

    private var inputOrHelpView: AnyView {
        if isAddingNew {
            AnyView(
                Text("  New: \(newTodoText)_  ")
                    .border(.single, title: "Add", color: .green)
            )
        } else if isEditing {
            AnyView(
                Text("  Edit: \(editText)_  ")
                    .border(.single, title: "Edit", color: .yellow)
            )
        } else {
            AnyView(
                VStack {
                    Text("  \(completedCount)/\(todos.count) completed  ").dim()
                    Text(helpText).dim()
                }
            )
        }
    }

    private var completedCount: Int {
        todos.filter(\.completed).count
    }

    private var filteredTodos: [TodoItem] {
        switch filter {
        case .all: return todos
        case .active: return todos.filter { !$0.completed }
        case .completed: return todos.filter { $0.completed }
        }
    }

    private func renderFilterTabs() -> String {
        Filter.allCases.map { f in
            if f == filter {
                "[\(f.rawValue)]".cyan.bold.render()
            } else {
                f.rawValue.dim.render()
            }
        }.joined(separator: "  ")
    }

    private func renderTodoItem(_ item: TodoItem, index: Int) -> String {
        let isSelected = index == selectedIndex
        let checkbox = item.completed ? "[x]" : "[ ]"
        let prioritySymbol = item.priority.symbol

        var line = ""

        // Selection indicator
        if isSelected {
            line += "> ".cyan.bold.render()
        } else {
            line += "  "
        }

        // Priority
        line += prioritySymbol.foreground(item.priority.color).render()
        line += " "

        // Checkbox
        if item.completed {
            line += checkbox.green.render()
        } else {
            line += checkbox
        }
        line += " "

        // Text (dim if completed)
        if item.completed {
            line += item.text.dim.strikethrough.render()
        } else if isSelected {
            line += item.text.bold.render()
        } else {
            line += item.text
        }

        return line
    }

    private var helpText: String {
        if isAddingNew || isEditing {
            return "  Enter: Save  |  Esc: Cancel  "
        }
        return "  a: Add  |  Space: Toggle  |  d: Delete  |  e: Edit  |  1/2/3: Priority  |  Tab: Filter  |  q: Quit  "
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        // Handle input mode
        if isAddingNew {
            return handleAddInput(key)
        }
        if isEditing {
            return handleEditInput(key)
        }

        // Normal mode
        switch key {
        case .arrow(.up):
            if !filteredTodos.isEmpty {
                selectedIndex = max(0, selectedIndex - 1)
            }
            return true

        case .arrow(.down):
            if !filteredTodos.isEmpty {
                selectedIndex = min(filteredTodos.count - 1, selectedIndex + 1)
            }
            return true

        case .character(" "), .enter:
            toggleSelected()
            return true

        case .character("a"), .character("A"):
            isAddingNew = true
            newTodoText = ""
            return true

        case .character("e"), .character("E"):
            startEditing()
            return true

        case .character("d"), .character("D"), .character("x"), .character("X"):
            deleteSelected()
            return true

        case .character("1"):
            setPriority(.high)
            return true

        case .character("2"):
            setPriority(.medium)
            return true

        case .character("3"):
            setPriority(.low)
            return true

        case .tab:
            cycleFilter()
            return true

        default:
            return false
        }
    }

    private func handleAddInput(_ key: KeyCode) -> Bool {
        switch key {
        case .enter:
            if !newTodoText.trimmingCharacters(in: .whitespaces).isEmpty {
                todos.append(TodoItem(text: newTodoText))
                saveTodos()
            }
            isAddingNew = false
            newTodoText = ""
            return true

        case .escape:
            isAddingNew = false
            newTodoText = ""
            return true

        case .backspace:
            if !newTodoText.isEmpty {
                newTodoText.removeLast()
            }
            return true

        case .character(let c):
            newTodoText.append(c)
            return true

        default:
            return true
        }
    }

    private func handleEditInput(_ key: KeyCode) -> Bool {
        switch key {
        case .enter:
            if !editText.trimmingCharacters(in: .whitespaces).isEmpty {
                if let realIndex = getRealIndex() {
                    todos[realIndex].text = editText
                    saveTodos()
                }
            }
            isEditing = false
            editText = ""
            return true

        case .escape:
            isEditing = false
            editText = ""
            return true

        case .backspace:
            if !editText.isEmpty {
                editText.removeLast()
            }
            return true

        case .character(let c):
            editText.append(c)
            return true

        default:
            return true
        }
    }

    private func toggleSelected() {
        guard let realIndex = getRealIndex() else { return }
        todos[realIndex].completed.toggle()
        saveTodos()
    }

    private func deleteSelected() {
        guard let realIndex = getRealIndex() else { return }
        todos.remove(at: realIndex)
        selectedIndex = min(selectedIndex, max(0, filteredTodos.count - 1))
        saveTodos()
    }

    private func startEditing() {
        guard let realIndex = getRealIndex() else { return }
        editText = todos[realIndex].text
        isEditing = true
    }

    private func setPriority(_ priority: Priority) {
        guard let realIndex = getRealIndex() else { return }
        todos[realIndex].priority = priority
        saveTodos()
    }

    private func cycleFilter() {
        let cases = Filter.allCases
        if let idx = cases.firstIndex(of: filter) {
            filter = cases[(idx + 1) % cases.count]
        }
        selectedIndex = 0
    }

    /// Get the real index in todos array from the filtered selection
    private func getRealIndex() -> Int? {
        let filtered = filteredTodos
        guard selectedIndex < filtered.count else { return nil }
        let selectedItem = filtered[selectedIndex]
        return todos.firstIndex(where: { $0.id == selectedItem.id })
    }

    // MARK: - Persistence

    private var todosFile: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".todos.json")
    }

    private func loadTodos() {
        guard let data = try? Data(contentsOf: todosFile),
              let loaded = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            return
        }
        todos = loaded
    }

    private func saveTodos() {
        guard let data = try? JSONEncoder().encode(todos) else { return }
        try? data.write(to: todosFile)
    }
}
