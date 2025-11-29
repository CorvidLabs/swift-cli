import Foundation

#if canImport(Darwin)
import Darwin
#endif

/// System metrics for CPU, memory, and disk usage.
public struct SystemMetrics: Sendable {
    /// CPU usage information.
    public struct CPUUsage: Sendable {
        public let user: Double
        public let system: Double
        public let idle: Double
        public let total: Double  // user + system percentage

        public init(user: Double, system: Double, idle: Double) {
            self.user = user
            self.system = system
            self.idle = idle
            self.total = user + system
        }
    }

    /// Memory usage information.
    public struct MemoryUsage: Sendable {
        public let used: UInt64      // bytes
        public let free: UInt64      // bytes
        public let total: UInt64     // bytes

        public var usedPercentage: Double {
            guard total > 0 else { return 0 }
            return Double(used) / Double(total) * 100
        }

        public var usedGB: Double {
            Double(used) / (1024 * 1024 * 1024)
        }

        public var totalGB: Double {
            Double(total) / (1024 * 1024 * 1024)
        }

        public init(used: UInt64, free: UInt64, total: UInt64) {
            self.used = used
            self.free = free
            self.total = total
        }
    }

    /// Disk usage information.
    public struct DiskUsage: Sendable {
        public let path: String
        public let total: UInt64     // bytes
        public let available: UInt64 // bytes
        public let used: UInt64      // bytes

        public var usedPercentage: Double {
            guard total > 0 else { return 0 }
            return Double(used) / Double(total) * 100
        }

        public var availableGB: Double {
            Double(available) / (1024 * 1024 * 1024)
        }

        public var usedGB: Double {
            Double(used) / (1024 * 1024 * 1024)
        }

        public var totalGB: Double {
            Double(total) / (1024 * 1024 * 1024)
        }

        public init(path: String, total: UInt64, available: UInt64, used: UInt64) {
            self.path = path
            self.total = total
            self.available = available
            self.used = used
        }
    }

    // Store previous CPU ticks for delta calculation
    nonisolated(unsafe) private static var previousTicks: (user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)?

    /// Get current CPU usage.
    /// Note: First call returns 0 as it needs two samples for delta calculation.
    public static func getCPUUsage() -> CPUUsage {
        #if canImport(Darwin)
        var cpuInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride
        )

        let result = withUnsafeMutablePointer(to: &cpuInfo) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(
                    mach_host_self(),
                    HOST_CPU_LOAD_INFO,
                    intPtr,
                    &count
                )
            }
        }

        guard result == KERN_SUCCESS else {
            return CPUUsage(user: 0, system: 0, idle: 100)
        }

        let user = UInt64(cpuInfo.cpu_ticks.0)    // CPU_STATE_USER
        let system = UInt64(cpuInfo.cpu_ticks.1)  // CPU_STATE_SYSTEM
        let idle = UInt64(cpuInfo.cpu_ticks.2)    // CPU_STATE_IDLE
        let nice = UInt64(cpuInfo.cpu_ticks.3)    // CPU_STATE_NICE

        // Calculate delta from previous reading
        if let prev = previousTicks {
            let deltaUser = user - prev.user
            let deltaSystem = system - prev.system
            let deltaIdle = idle - prev.idle
            let deltaNice = nice - prev.nice
            let deltaTotal = deltaUser + deltaSystem + deltaIdle + deltaNice

            previousTicks = (user, system, idle, nice)

            if deltaTotal > 0 {
                return CPUUsage(
                    user: Double(deltaUser + deltaNice) / Double(deltaTotal) * 100,
                    system: Double(deltaSystem) / Double(deltaTotal) * 100,
                    idle: Double(deltaIdle) / Double(deltaTotal) * 100
                )
            }
        }

        previousTicks = (user, system, idle, nice)
        return CPUUsage(user: 0, system: 0, idle: 100)
        #else
        return CPUUsage(user: 0, system: 0, idle: 100)
        #endif
    }

    /// Get current memory usage.
    public static func getMemoryUsage() -> MemoryUsage {
        #if canImport(Darwin)
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride
        )

        let result = withUnsafeMutablePointer(to: &vmStats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    intPtr,
                    &count
                )
            }
        }

        guard result == KERN_SUCCESS else {
            return MemoryUsage(used: 0, free: 0, total: 0)
        }

        // Get page size - typically 4096 on macOS
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)
        let pageSizeUInt64 = UInt64(pageSize)

        // Get total physical memory
        var totalMemory: UInt64 = 0
        var size = MemoryLayout<UInt64>.stride
        sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0)

        let active = UInt64(vmStats.active_count) * pageSizeUInt64
        let wired = UInt64(vmStats.wire_count) * pageSizeUInt64
        let compressed = UInt64(vmStats.compressor_page_count) * pageSizeUInt64
        let free = UInt64(vmStats.free_count) * pageSizeUInt64

        let used = active + wired + compressed

        return MemoryUsage(used: used, free: free, total: totalMemory)
        #else
        return MemoryUsage(used: 0, free: 0, total: 0)
        #endif
    }

    /// Get disk usage for a given path.
    public static func getDiskUsage(path: String = "/") -> DiskUsage {
        #if canImport(Darwin)
        var stats = statfs()
        guard statfs(path, &stats) == 0 else {
            return DiskUsage(path: path, total: 0, available: 0, used: 0)
        }

        let blockSize = UInt64(stats.f_bsize)
        let total = UInt64(stats.f_blocks) * blockSize
        let available = UInt64(stats.f_bavail) * blockSize
        let used = total - available

        return DiskUsage(path: path, total: total, available: available, used: used)
        #else
        return DiskUsage(path: path, total: 0, available: 0, used: 0)
        #endif
    }

    /// Get the number of CPU cores.
    public static func getCPUCoreCount() -> Int {
        ProcessInfo.processInfo.processorCount
    }

    /// Get system load averages (1, 5, 15 minute).
    public static func getLoadAverage() -> (one: Double, five: Double, fifteen: Double) {
        #if canImport(Darwin)
        var loadavg: [Double] = [0, 0, 0]
        getloadavg(&loadavg, 3)
        return (loadavg[0], loadavg[1], loadavg[2])
        #else
        return (0, 0, 0)
        #endif
    }
}
