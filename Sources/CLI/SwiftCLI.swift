/// SwiftCLI - A comprehensive Swift CLI toolkit
///
/// Import this module to get access to all SwiftCLI packages:
/// - ANSI: Escape code generation
/// - TerminalCore: Low-level terminal I/O
/// - TerminalStyle: Colors and styling
/// - TerminalInput: Keyboard and mouse input
/// - TerminalLayout: Boxes, tables, panels
/// - TerminalComponents: Progress bars, spinners, prompts
/// - TerminalGraphics: Terminal images
/// - TerminalUI: High-level TUI framework
///
/// ## Quick Start
///
/// ```swift
/// import SwiftCLI
///
/// @main
/// struct MyCLI {
///     static func main() async throws {
///         let terminal = Terminal.shared
///
///         // Styled output
///         await terminal.writeLine("Hello".green.bold + " World!".cyan)
///
///         // Boxes
///         await terminal.render(Box("Welcome!", style: .rounded))
///
///         // Progress
///         let spinner = Spinner(style: .dots, message: "Loading...")
///         await spinner.start()
///         try await Task.sleep(for: .seconds(2))
///         await spinner.success("Done!")
///
///         // Prompts
///         let name = try await terminal.input("What's your name?")
///         await terminal.success("Hello, \(name)!")
///     }
/// }
/// ```

// Re-export all modules
@_exported import ANSI
@_exported import TerminalCore
@_exported import TerminalStyle
@_exported import TerminalInput
@_exported import TerminalLayout
@_exported import TerminalComponents
@_exported import TerminalGraphics
@_exported import TerminalUI
