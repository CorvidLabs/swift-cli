import ANSI
import TerminalUI
import TerminalInput
import Foundation

/// Network connections monitor (netstat-style)
final class NetworkMonitorApp: App, @unchecked Sendable {
    enum Protocol_: String, CaseIterable {
        case all = "All"
        case tcp = "TCP"
        case udp = "UDP"
    }

    enum SortColumn: Int, CaseIterable {
        case proto = 0
        case local = 1
        case remote = 2
        case state = 3
    }

    struct Connection: Sendable {
        let proto: String
        let localAddress: String
        let localPort: String
        let remoteAddress: String
        let remotePort: String
        let state: String
    }

    // State
    private var connections: [Connection] = []
    private var filteredConnections: [Connection] = []
    private var selectedIndex: Int = 0
    private var scrollOffset: Int = 0
    private let visibleRows = 16
    private var protocolFilter: Protocol_ = .all
    private var sortColumn: SortColumn = .state
    private var sortAscending: Bool = true
    private var lastUpdate: String = ""

    init() {
        // Don't call refreshConnections() here - it blocks with waitUntilExit()
        // Let onAppear() handle the first load after render
    }

    func onAppear() async {
        // Run in background to not block the event loop
        Task {
            refreshConnections()
        }
    }

    var updateInterval: TimeInterval { 1.0 }

    var body: some View {
        VStack {
            // Header
            Text("  Network Connections - \(filteredConnections.count) connections  ").bold()
                .border(.double, color: .cyan)

            // Filter bar + headers
            Text(renderFilterBar())
            Text(renderHeaders())

            // Connection list
            connectionList

            // Footer
            footerView
        }
    }

    private var connectionList: some View {
        VStack {
            ForEach(0..<visibleRows) { [self] row in
                Text(renderRow(row))
            }
        }
        .border(.rounded)
    }

    private var footerView: some View {
        VStack {
            Text(renderSummary()).dim()
            Text("  Tab: Filter  |  1-4: Sort  |  r: Reverse  |  q: Quit  ").dim()
        }
    }

    private func renderFilterBar() -> String {
        Protocol_.allCases.map { p in
            if p == protocolFilter {
                "[\(p.rawValue)]".cyan.bold.render()
            } else {
                p.rawValue.dim.render()
            }
        }.joined(separator: "  ") + "  Updated: \(lastUpdate)".dim.render()
    }

    private func renderHeaders() -> String {
        let headers = ["Proto", "Local Address", "Remote Address", "State"]
        let widths = [8, 24, 24, 14]

        return headers.enumerated().map { i, header in
            var h = header
            if SortColumn(rawValue: i) == sortColumn {
                h += sortAscending ? " ^" : " v"
            }
            h = h.padding(toLength: widths[i], withPad: " ", startingAt: 0)
            if SortColumn(rawValue: i) == sortColumn {
                return h.cyan.bold.render()
            }
            return h.bold.render()
        }.joined()
    }

    private func renderRow(_ row: Int) -> String {
        let index = scrollOffset + row
        guard index < filteredConnections.count else {
            return String(repeating: " ", count: 70)
        }

        let conn = filteredConnections[index]
        let isSelected = index == selectedIndex

        let proto = conn.proto.padding(toLength: 8, withPad: " ", startingAt: 0)
        let local = "\(conn.localAddress):\(conn.localPort)".padding(toLength: 24, withPad: " ", startingAt: 0)
        let remote = "\(conn.remoteAddress):\(conn.remotePort)".padding(toLength: 24, withPad: " ", startingAt: 0)
        let state = conn.state.padding(toLength: 14, withPad: " ", startingAt: 0)

        var line = ""

        // Protocol
        if conn.proto == "tcp" || conn.proto == "tcp4" || conn.proto == "tcp6" {
            line += proto.blue.render()
        } else {
            line += proto.magenta.render()
        }

        // Local address
        line += local

        // Remote address
        if conn.remoteAddress == "*" || conn.remoteAddress.isEmpty {
            line += remote.dim.render()
        } else {
            line += remote
        }

        // State with color
        line += colorState(state)

        if isSelected {
            return "> ".cyan.bold.render() + line
        }
        return "  " + line
    }

    private func colorState(_ state: String) -> String {
        let trimmed = state.trimmingCharacters(in: .whitespaces)
        let padded = state
        switch trimmed {
        case "ESTABLISHED":
            return padded.green.render()
        case "LISTEN":
            return padded.blue.render()
        case "TIME_WAIT":
            return padded.yellow.render()
        case "CLOSE_WAIT":
            return padded.red.render()
        case "SYN_SENT", "SYN_RECV":
            return padded.cyan.render()
        default:
            return padded.dim.render()
        }
    }

    private func renderSummary() -> String {
        let established = filteredConnections.filter { $0.state == "ESTABLISHED" }.count
        let listening = filteredConnections.filter { $0.state == "LISTEN" }.count
        let timeWait = filteredConnections.filter { $0.state == "TIME_WAIT" }.count

        return "  ESTABLISHED: \(established)  |  LISTEN: \(listening)  |  TIME_WAIT: \(timeWait)  "
    }

    func onUpdate() async {
        // Run in background to not block the event loop
        Task {
            refreshConnections()
        }
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        switch key {
        case .arrow(.up):
            if selectedIndex > 0 {
                selectedIndex -= 1
                updateScroll()
            }
            return true

        case .arrow(.down):
            if selectedIndex < filteredConnections.count - 1 {
                selectedIndex += 1
                updateScroll()
            }
            return true

        case .tab:
            cycleProtocolFilter()
            return true

        case .character("1"):
            toggleSort(.proto)
            return true

        case .character("2"):
            toggleSort(.local)
            return true

        case .character("3"):
            toggleSort(.remote)
            return true

        case .character("4"):
            toggleSort(.state)
            return true

        case .character("r"), .character("R"):
            sortAscending.toggle()
            applyFilterAndSort()
            return true

        default:
            return false
        }
    }

    private func cycleProtocolFilter() {
        let cases = Protocol_.allCases
        if let idx = cases.firstIndex(of: protocolFilter) {
            protocolFilter = cases[(idx + 1) % cases.count]
        }
        applyFilterAndSort()
        selectedIndex = 0
        scrollOffset = 0
    }

    private func toggleSort(_ column: SortColumn) {
        if sortColumn == column {
            sortAscending.toggle()
        } else {
            sortColumn = column
            sortAscending = true
        }
        applyFilterAndSort()
    }

    private func updateScroll() {
        if selectedIndex < scrollOffset {
            scrollOffset = selectedIndex
        } else if selectedIndex >= scrollOffset + visibleRows {
            scrollOffset = selectedIndex - visibleRows + 1
        }
    }

    private func refreshConnections() {
        // Run netstat and parse output
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/sbin/netstat")
        process.arguments = ["-an"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                parseNetstatOutput(output)
            }
        } catch {
            // Silently fail
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        lastUpdate = formatter.string(from: Date())
    }

    private func parseNetstatOutput(_ output: String) {
        connections = []

        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            // Skip header lines
            if line.hasPrefix("Active") || line.hasPrefix("Proto") || line.isEmpty {
                continue
            }

            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 4 else { continue }

            let proto = String(parts[0])
            // Skip non-TCP/UDP
            guard proto.hasPrefix("tcp") || proto.hasPrefix("udp") else { continue }

            // Parse addresses (format varies by OS)
            let localFull = String(parts[3])
            let remoteFull = parts.count > 4 ? String(parts[4]) : "*.*"

            let (localAddr, localPort) = splitAddress(localFull)
            let (remoteAddr, remotePort) = splitAddress(remoteFull)

            // State (TCP only)
            var state = ""
            if proto.hasPrefix("tcp") && parts.count > 5 {
                state = String(parts[5])
            }

            connections.append(Connection(
                proto: proto,
                localAddress: localAddr,
                localPort: localPort,
                remoteAddress: remoteAddr,
                remotePort: remotePort,
                state: state
            ))
        }

        applyFilterAndSort()
    }

    private func splitAddress(_ addr: String) -> (String, String) {
        // Handle IPv6 and IPv4 formats
        if let lastDot = addr.lastIndex(of: ".") {
            let address = String(addr[..<lastDot])
            let port = String(addr[addr.index(after: lastDot)...])
            return (address, port)
        }
        return (addr, "*")
    }

    private func applyFilterAndSort() {
        // Filter
        filteredConnections = connections.filter { conn in
            switch protocolFilter {
            case .all:
                return true
            case .tcp:
                return conn.proto.hasPrefix("tcp")
            case .udp:
                return conn.proto.hasPrefix("udp")
            }
        }

        // Sort
        filteredConnections.sort { a, b in
            let comparison: Bool
            switch sortColumn {
            case .proto:
                comparison = a.proto < b.proto
            case .local:
                comparison = a.localAddress < b.localAddress
            case .remote:
                comparison = a.remoteAddress < b.remoteAddress
            case .state:
                comparison = a.state < b.state
            }
            return sortAscending ? comparison : !comparison
        }
    }
}
