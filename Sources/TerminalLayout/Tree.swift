import ANSI
import TerminalStyle

/// Tree connector characters style.
public struct TreeConnectorStyle: Sendable {
    public let branch: String      // ├──
    public let lastBranch: String  // └──
    public let vertical: String    // │
    public let space: String       // Spacing

    public init(branch: String, lastBranch: String, vertical: String, space: String) {
        self.branch = branch
        self.lastBranch = lastBranch
        self.vertical = vertical
        self.space = space
    }

    public static let unicode = TreeConnectorStyle(
        branch: "├── ",
        lastBranch: "└── ",
        vertical: "│   ",
        space: "    "
    )

    public static let ascii = TreeConnectorStyle(
        branch: "+-- ",
        lastBranch: "`-- ",
        vertical: "|   ",
        space: "    "
    )

    public static let minimal = TreeConnectorStyle(
        branch: "|- ",
        lastBranch: "`- ",
        vertical: "|  ",
        space: "   "
    )
}

/// A tree view for hierarchical data.
public struct Tree<T: Sendable>: Renderable, Sendable {
    /// Root node.
    public let root: Node

    /// Tree connector style.
    public let connectorStyle: TreeConnectorStyle

    /// A tree node.
    public struct Node: Sendable {
        public let value: T
        public let label: StyledText
        public let children: [Node]

        public init(_ value: T, label: StyledText, children: [Node] = []) {
            self.value = value
            self.label = label
            self.children = children
        }

        public init(_ value: T, label: String, children: [Node] = []) {
            self.value = value
            self.label = StyledText(label)
            self.children = children
        }
    }

    /// Create a tree.
    public init(root: Node, connectorStyle: TreeConnectorStyle = .unicode) {
        self.root = root
        self.connectorStyle = connectorStyle
    }

    /// Render the tree.
    public func render(width: Int? = nil) -> String {
        var lines: [String] = []
        lines.append(root.label.render())
        renderNode(root, prefix: "", isLast: true, lines: &lines, skipFirst: true)
        return lines.joined(separator: "\n")
    }

    private func renderNode(_ node: Node, prefix: String, isLast: Bool, lines: inout [String], skipFirst: Bool = false) {
        for (index, child) in node.children.enumerated() {
            let isLastChild = index == node.children.count - 1
            let connector = isLastChild ? connectorStyle.lastBranch : connectorStyle.branch
            let childPrefix = isLastChild ? connectorStyle.space : connectorStyle.vertical

            lines.append(prefix + connector + child.label.render())
            renderNode(child, prefix: prefix + childPrefix, isLast: isLastChild, lines: &lines)
        }
    }
}

// MARK: - Convenience for String Trees

extension Tree where T == String {
    /// Create a simple string tree.
    public init(label: String, children: [Tree<String>.Node] = [], connectorStyle: TreeConnectorStyle = .unicode) {
        self.root = Node(label, label: label, children: children)
        self.connectorStyle = connectorStyle
    }
}

/// Simple tree node for string trees.
public func treeNode(_ label: String, children: [Tree<String>.Node] = []) -> Tree<String>.Node {
    Tree<String>.Node(label, label: label, children: children)
}

/// Create a styled tree node.
public func treeNode(_ label: StyledText, children: [Tree<String>.Node] = []) -> Tree<String>.Node {
    Tree<String>.Node(label.plainText, label: label, children: children)
}
