import ANSI
import TerminalUI
import TerminalInput
import Foundation

/// Classic Snake game
final class SnakeApp: App, @unchecked Sendable {
    enum GameState {
        case start
        case playing
        case paused
        case gameOver
    }

    enum Direction {
        case up, down, left, right

        var opposite: Direction {
            switch self {
            case .up: return .down
            case .down: return .up
            case .left: return .right
            case .right: return .left
            }
        }
    }

    struct Point: Equatable, Hashable {
        var x: Int
        var y: Int
    }

    // Game constants
    private let boardWidth = 40
    private let boardHeight = 20

    // Game state
    private var state: GameState = .start
    private var snake: [Point] = []
    private var direction: Direction = .right
    private var nextDirection: Direction = .right
    private var food: Point = Point(x: 0, y: 0)
    private var score: Int = 0
    private var highScore: Int = 0
    private var tickCount: Int = 0
    private var verticalSkip: Bool = false

    init() {
        loadHighScore()
    }

    var updateInterval: TimeInterval {
        switch state {
        case .playing:
            // Speed increases with score (faster = smaller interval)
            let baseSpeed = 0.15
            let speedBonus = Double(score) * 0.002
            return max(0.05, baseSpeed - speedBonus)
        default:
            // Keep event loop active for responsive input
            return 0.1
        }
    }

    var body: some View {
        VStack {
            // Header
            HStack {
                Text("  Score: \(score)  ").bold()
                Text("  High: \(highScore)  ").dim()
            }
            .border(.single, color: .cyan)

            // Game board - render as text lines
            VStack {
                ForEach(0..<boardHeight) { [self] y in
                    Text(renderRow(y: y))
                }
            }
            .border(.double, title: stateTitle, color: borderColor)

            // Controls
            Text(controlsText).dim()
        }
    }

    private func renderRow(y: Int) -> String {
        var row = ""
        for x in 0..<boardWidth {
            let point = Point(x: x, y: y)

            if snake.first == point {
                row += "@".green.bold.render()
            } else if snake.contains(point) {
                row += "o".green.render()
            } else if food == point {
                row += "*".red.bold.render()
            } else {
                row += " "
            }
        }
        return row
    }

    private var stateTitle: String {
        switch state {
        case .start: return "SNAKE"
        case .playing: return "PLAYING"
        case .paused: return "PAUSED"
        case .gameOver: return "GAME OVER"
        }
    }

    private var borderColor: ANSI.Color? {
        switch state {
        case .start: return .cyan
        case .playing: return .green
        case .paused: return .yellow
        case .gameOver: return .red
        }
    }

    private var controlsText: String {
        switch state {
        case .start:
            return "  Press SPACE to start  |  Arrow keys to move  |  q: Quit  "
        case .playing:
            return "  Arrow keys: Move  |  SPACE: Pause  |  q: Quit  "
        case .paused:
            return "  Press SPACE to resume  |  r: Restart  |  q: Quit  "
        case .gameOver:
            return "  Press SPACE to play again  |  q: Quit  "
        }
    }

    func onUpdate() async {
        guard state == .playing else { return }

        // Skip every other tick for vertical movement to compensate for aspect ratio
        if direction == .up || direction == .down {
            verticalSkip.toggle()
            if verticalSkip { return }
        }

        tickCount += 1
        moveSnake()
    }

    func onKeyPress(_ key: KeyCode) async -> Bool {
        switch state {
        case .start:
            if key == .character(" ") {
                startGame()
                return true
            }

        case .playing:
            switch key {
            case .arrow(.up) where direction != .down:
                nextDirection = .up
                return true
            case .arrow(.down) where direction != .up:
                nextDirection = .down
                return true
            case .arrow(.left) where direction != .right:
                nextDirection = .left
                return true
            case .arrow(.right) where direction != .left:
                nextDirection = .right
                return true
            case .character(" "):
                state = .paused
                return true
            default:
                break
            }

        case .paused:
            if key == .character(" ") {
                state = .playing
                return true
            } else if key == .character("r") || key == .character("R") {
                startGame()
                return true
            }

        case .gameOver:
            if key == .character(" ") {
                startGame()
                return true
            }
        }

        return false
    }

    private func startGame() {
        // Initialize snake in center
        let centerX = boardWidth / 2
        let centerY = boardHeight / 2
        snake = [
            Point(x: centerX, y: centerY),
            Point(x: centerX - 1, y: centerY),
            Point(x: centerX - 2, y: centerY)
        ]

        direction = .right
        nextDirection = .right
        score = 0
        tickCount = 0

        spawnFood()
        state = .playing
    }

    private func moveSnake() {
        direction = nextDirection

        guard let head = snake.first else { return }

        var newHead = head
        switch direction {
        case .up: newHead.y -= 1
        case .down: newHead.y += 1
        case .left: newHead.x -= 1
        case .right: newHead.x += 1
        }

        // Check wall collision
        if newHead.x < 0 || newHead.x >= boardWidth ||
           newHead.y < 0 || newHead.y >= boardHeight {
            endGame()
            return
        }

        // Check self collision (excluding tail since it will move)
        let bodyWithoutTail = snake.dropLast()
        if bodyWithoutTail.contains(newHead) {
            endGame()
            return
        }

        // Move snake
        snake.insert(newHead, at: 0)

        // Check food
        if newHead == food {
            score += 10
            spawnFood()
            // Don't remove tail - snake grows
        } else {
            snake.removeLast()
        }
    }

    private func spawnFood() {
        var newFood: Point
        repeat {
            newFood = Point(
                x: Int.random(in: 0..<boardWidth),
                y: Int.random(in: 0..<boardHeight)
            )
        } while snake.contains(newFood)

        food = newFood
    }

    private func endGame() {
        state = .gameOver
        if score > highScore {
            highScore = score
            saveHighScore()
        }
    }

    // MARK: - High Score Persistence

    private var highScoreFile: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".snake_highscore")
    }

    private func loadHighScore() {
        if let data = try? Data(contentsOf: highScoreFile),
           let value = Int(String(data: data, encoding: .utf8) ?? "") {
            highScore = value
        }
    }

    private func saveHighScore() {
        try? "\(highScore)".write(to: highScoreFile, atomically: true, encoding: .utf8)
    }
}
