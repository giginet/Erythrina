import Playdate
import CPlaydate

enum GameState {
    case ready
    case playing
    case gameOverDelay
    case over
}

final class Game: @unchecked Sendable {
    private var explosionPlayer: OpaquePointer?
    private var shotPlayer: OpaquePointer?
    private var playerExplosionPlayer: OpaquePointer?
    private var gameStartPlayer: OpaquePointer?
    private var gameOverPlayer: OpaquePointer?
    private var background: SpriteEntity
    private var canon: SpriteEntity
    private var logo: SpriteEntity
    private var gameoverImage: SpriteEntity
    private var hearts: [SpriteEntity] = []
    private var degree: Float = 0
    private var bullets: [SpriteEntity] = []
    private var bombs: [SpriteEntity] = []
    private var explosions: [Explosion] = []
    private var score: Int = 0
    private var life: Int = 3
    private let maxLife: Int = 3
    private var frameCount: Int = 0
    private var bombSpawnInterval: Int = 60
    private var currentState: GameState = .ready
    private var gameOverDelayTimer: Int = 0
    private let gameOverDelayDuration: Int = 120 // 2 seconds at 60fps

    init() {
        // Load explosion sound
        explosionPlayer = Sound.FilePlayer.newPlayer()
        let explosionResult = Sound.FilePlayer.loadIntoPlayer(explosionPlayer!, "sounds/explosion2")
        System.logToConsole("Explosion sound loaded: \(explosionResult)")

        // Load shot sound
        shotPlayer = Sound.FilePlayer.newPlayer()
        let shotResult = Sound.FilePlayer.loadIntoPlayer(shotPlayer!, "sounds/shot")
        System.logToConsole("Shot sound loaded: \(shotResult)")

        // Load player explosion sound
        playerExplosionPlayer = Sound.FilePlayer.newPlayer()
        let playerExplosionResult = Sound.FilePlayer.loadIntoPlayer(playerExplosionPlayer!, "sounds/explosion-player")
        System.logToConsole("Player explosion sound loaded: \(playerExplosionResult)")

        // Load game start sound
        gameStartPlayer = Sound.FilePlayer.newPlayer()
        let gameStartResult = Sound.FilePlayer.loadIntoPlayer(gameStartPlayer!, "sounds/gamestart")
        System.logToConsole("Game start sound loaded: \(gameStartResult)")

        // Load game over sound
        gameOverPlayer = Sound.FilePlayer.newPlayer()
        let gameOverResult = Sound.FilePlayer.loadIntoPlayer(gameOverPlayer!, "sounds/gameover")
        System.logToConsole("Game over sound loaded: \(gameOverResult)")

        background = SpriteEntity(filePath: "images/background.png")
        background.anchorPoint = Vector(x: 0, y: 0)
//        background.addSprite()

        canon = SpriteEntity(filePath: "images/canon.png")
        canon.position = Vector(x: 200, y: 220)
        canon.anchorPoint = Vector(x: 0.5, y: 0.75)

        // Logo for ready state - positioned at left 1/3, vertical center
        logo = SpriteEntity(filePath: "images/logo.png")
        logo.position = Vector(x: 133, y: 120)
        logo.anchorPoint = Vector(x: 0.5, y: 0.5)

        // Game over image - positioned at left 1/3, vertical center
        gameoverImage = SpriteEntity(filePath: "images/gameover.png")
        gameoverImage.position = Vector(x: 133, y: 120)
        gameoverImage.anchorPoint = Vector(x: 0.5, y: 0.5)

        // Create heart sprites for life display (24x24, margin 8px)
        for i in 0..<maxLife {
            let heart = SpriteEntity(filePath: "images/heart.png")
            heart.position = Vector(x: 8 + Float(i) * 32, y: 8 + 12) // 8px margin + index * (24 + 8), centered vertically
            heart.anchorPoint = Vector(x: 0, y: 0)
            hearts.append(heart)
        }
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
        case .gameOverDelay:
            updateGameOverDelay(buttonState: buttonState)
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
            Sound.FilePlayer.play(gameStartPlayer!, 1)
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

        // Check if any bomb reached the bottom (y >= 240)
        var bombsToRemove: [Int] = []
        for (index, bomb) in bombs.enumerated() {
            if bomb.position.y >= 240 {
                bombsToRemove.append(index)

                // Create explosion at bomb position
                let explosion = Explosion(position: bomb.position)
                explosions.append(explosion)

                // Play explosion sound
                Sound.FilePlayer.play(explosionPlayer!, 1)

                // Decrease life
                life -= 1
                System.logToConsole("Life: \(life)")

                // Check if game over
                if life <= 0 {
                    // Play player explosion sound
                    Sound.FilePlayer.play(playerExplosionPlayer!, 1)

                    // Create explosion at canon position
                    let playerExplosion = Explosion(position: canon.position, imagePath: "images/explosion-player.png")
                    explosions.append(playerExplosion)

                    // Transition to game over delay state
                    currentState = .gameOverDelay
                    gameOverDelayTimer = 0
                    return
                }
            }
        }

        // Remove bombs that reached the bottom
        for index in bombsToRemove.reversed() {
            bombs.remove(at: index)
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

        // Draw hearts based on current life
        for i in 0..<life {
            hearts[i].updateAndDraw()
        }

        // TODO: Draw score when text API is available
        // System.logToConsole("Score: \(score)")

        if buttonState.pushed == .a {
            Sound.FilePlayer.play(shotPlayer!, 1)
            shootBullet()
        }

        let change = Crank.change
        System.logToConsole("\(Int(change * 100))")
    }

    private func updateGameOverDelay(buttonState: (current: PDButtons, pushed: PDButtons, released: PDButtons)) {
        gameOverDelayTimer += 1

        // Continue updating bombs and explosions during delay
        for bomb in bombs {
            bomb.velocity = Vector(x: 0, y: 1)
        }

        // Update explosions
        for i in 0..<explosions.count {
            explosions[i].update()
        }

        // Remove finished explosions
        explosions.removeAll { $0.isFinished }

        background.updateAndDraw()
        // Don't draw canon during game over delay

        bullets.forEach { $0.updateAndDraw() }
        bombs.forEach { $0.updateAndDraw() }

        // Draw explosions
        explosions.forEach { $0.draw() }

        // After delay duration, transition to game over state
        if gameOverDelayTimer >= gameOverDelayDuration {
            Sound.FilePlayer.play(gameOverPlayer!, 1)
            currentState = .over
        }
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
        life = maxLife
        frameCount = 0
        canon.position = Vector(x: 200, y: 220)
        canon.anchorPoint = Vector(x: 0.5, y: 0.75)
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

                    // Play explosion sound
                    Sound.FilePlayer.play(explosionPlayer!, 1)

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
