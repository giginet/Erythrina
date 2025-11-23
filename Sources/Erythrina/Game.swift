import Playdate
import CPlaydate

enum GameState {
    case ready
    case playing
    case over
}

final class Game: @unchecked Sendable {
    private var soundPlayer: OpaquePointer?
    private var background: SpriteEntity
    private var canon: SpriteEntity
    private var logo: SpriteEntity
    private var gameoverImage: SpriteEntity
    private var degree: Float = 0
    private var bullets: [SpriteEntity] = []
    private var bombs: [SpriteEntity] = []
    private var explosions: [Explosion] = []
    private var score: Int = 0
    private var frameCount: Int = 0
    private var bombSpawnInterval: Int = 30
    private var currentState: GameState = .ready
    
    init() {
        soundPlayer = Sound.FilePlayer.newPlayer()
        let result = Sound.FilePlayer.loadIntoPlayer(soundPlayer!, "sounds/explosion")
        System.logToConsole("\(result)")

        background = SpriteEntity(filePath: "images/background.png")
        background.anchorPoint = Vector(x: 0, y: 0)
//        background.addSprite()

        canon = SpriteEntity(filePath: "images/canon.png")
        canon.position = Vector(x: 200, y: 200)

        // Logo for ready state - positioned at left 1/3, vertical center
        logo = SpriteEntity(filePath: "images/logo.png")
        logo.position = Vector(x: 133, y: 120)
        logo.anchorPoint = Vector(x: 0.5, y: 0.5)

        // Game over image - positioned at left 1/3, vertical center
        gameoverImage = SpriteEntity(filePath: "images/gameover.png")
        gameoverImage.position = Vector(x: 133, y: 120)
        gameoverImage.anchorPoint = Vector(x: 0.5, y: 0.5)
    }
    
    func initialize() {
    }
    
    func update(pointer: UnsafeMutableRawPointer!) -> Int32 {
        let buttonState = System.buttonState

        switch currentState {
        case .ready:
            updateReady(buttonState: buttonState)
        case .playing:
            updatePlaying(buttonState: buttonState)
        case .over:
            updateGameOver(buttonState: buttonState)
        }

        return 1
    }

    private func updateReady(buttonState: (current: PDButtons, pushed: PDButtons, released: PDButtons)) {
        background.updateAndDraw()
        logo.updateAndDraw()

        // Press A to start game
        if buttonState.pushed == .a {
            currentState = .playing
            frameCount = 0
        }
    }

    private func updatePlaying(buttonState: (current: PDButtons, pushed: PDButtons, released: PDButtons)) {
        frameCount += 1

        let crankAngle = Crank.angle
        canon.rotate = crankAngle

        // Move canon with left/right buttons
        if buttonState.current.contains(.left) {
            canon.position.x -= 3
        }
        if buttonState.current.contains(.right) {
            canon.position.x += 3
        }

        // Keep canon within screen bounds
        if canon.position.x < 20 {
            canon.position.x = 20
        }
        if canon.position.x > 380 {
            canon.position.x = 380
        }

        // Spawn bombs periodically
        if frameCount % bombSpawnInterval == 0 {
            spawnBomb()
        }

        // Update bombs position (falling)
        for bomb in bombs {
            bomb.velocity = Vector(x: 0, y: 1)
        }

        // Check if any bomb is within 8 pixels of canon (game over)
        for bomb in bombs {
            let distance = bomb.position.distance(to: canon.position)
            if distance < 8 {
                currentState = .over
                return
            }
        }

        // Remove bombs that are off-screen
        bombs.removeAll { $0.position.y > 260 }

        // Remove bullets that are off-screen
        bullets.removeAll {
            $0.position.x < -20 || $0.position.x > 420 ||
            $0.position.y < -20 || $0.position.y > 260
        }

        // Check collisions between bullets and bombs
        checkCollisions()

        // Update explosions
        for i in 0..<explosions.count {
            explosions[i].update()
        }

        // Remove finished explosions
        explosions.removeAll { $0.isFinished }

        background.updateAndDraw()
        canon.updateAndDraw()

        bullets.forEach { $0.updateAndDraw() }
        bombs.forEach { $0.updateAndDraw() }

        // Draw explosions
        explosions.forEach { $0.draw() }

        // TODO: Draw score when text API is available
        // System.logToConsole("Score: \(score)")

        if buttonState.pushed == .a {
            let result = Sound.FilePlayer.play(soundPlayer!, 1)
            shootBullet()
        }

        let change = Crank.change
        System.logToConsole("\(Int(change * 100))")
    }

    private func updateGameOver(buttonState: (current: PDButtons, pushed: PDButtons, released: PDButtons)) {
        background.updateAndDraw()
        gameoverImage.updateAndDraw()

        // Press A to restart
        if buttonState.pushed == .a {
            resetGame()
            currentState = .ready
        }
    }

    private func resetGame() {
        bullets.removeAll()
        bombs.removeAll()
        explosions.removeAll()
        score = 0
        frameCount = 0
        canon.position = Vector(x: 200, y: 200)
    }
    
    private func shootBullet() {
        let bullet = SpriteEntity(filePath: "images/bullet.png")
        bullet.position = canon.position

        let velocity = Vector.fromAngleDegrees(canon.rotate - 90)
        bullet.velocity = velocity * 5
        bullets.append(bullet)
    }

    private func spawnBomb() {
        let bomb = SpriteEntity(filePath: "images/bomb.png")
        let randomValue = rand()
        let randomX = Float(randomValue % 380) + 10
        bomb.position = Vector(x: randomX, y: -10)
        bombs.append(bomb)
    }

    private func checkCollisions() {
        var bulletsToRemove: [Int] = []
        var bombsToRemove: [Int] = []

        for (bulletIndex, bullet) in bullets.enumerated() {
            for (bombIndex, bomb) in bombs.enumerated() {
                if bullet.intersects(with: bomb) {
                    bulletsToRemove.append(bulletIndex)
                    bombsToRemove.append(bombIndex)
                    score += 100
                    System.logToConsole("Hit! Score: \(score)")

                    // Create explosion at bomb position
                    let explosion = Explosion(position: bomb.position)
                    explosions.append(explosion)
                }
            }
        }

        // Remove in reverse order to maintain indices
        for index in bulletsToRemove.reversed() {
            bullets.remove(at: index)
        }
        for index in bombsToRemove.reversed() {
            bombs.remove(at: index)
        }
    }
    
    private static func makeBackground() -> Sprite {
        var sprite = Sprite(bitmapPath: "images/background.png")
        sprite.collisionsEnabled = false
        sprite.zIndex = 0
        return sprite
    }
}
