import Playdate

final class Game: @unchecked Sendable {
    private var soundPlayer: OpaquePointer?
    private var background: SpriteEntity
    private var canon: SpriteEntity
    private var degree: Float = 0
    private var bullets: [SpriteEntity] = []
    private var bombs: [SpriteEntity] = []
    private var score: Int = 0
    private var frameCount: Int = 0
    private var bombSpawnInterval: Int = 30
    
    init() {
        soundPlayer = Sound.FilePlayer.newPlayer()
        let result = Sound.FilePlayer.loadIntoPlayer(soundPlayer!, "sounds/explosion")
        System.logToConsole("\(result)")
        
        background = SpriteEntity(filePath: "images/background.png")
        background.anchorPoint = Vector(x: 0, y: 0)
//        background.addSprite()
        
        canon = SpriteEntity(filePath: "images/canon.png")
        canon.position = Vector(x: 200, y: 200)
    }
    
    func initialize() {
    }
    
    func update(pointer: UnsafeMutableRawPointer!) -> Int32 {
        frameCount += 1

        let crankAngle = Crank.angle
        canon.rotate = crankAngle

        // Spawn bombs periodically
        if frameCount % bombSpawnInterval == 0 {
            spawnBomb()
        }

        // Update bombs position (falling)
        for bomb in bombs {
            bomb.velocity = Vector(x: 0, y: 2)
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

        background.updateAndDraw()
        canon.updateAndDraw()

        bullets.forEach { $0.updateAndDraw() }
        bombs.forEach { $0.updateAndDraw() }

        // TODO: Draw score when text API is available
        // System.logToConsole("Score: \(score)")

        if System.buttonState.pushed == .a {
            let result = Sound.FilePlayer.play(soundPlayer!, 1)
            shootBullet()
        }

        let change = Crank.change
        System.logToConsole("\(Int(change * 100))")

        return 1
    }
    
    private func shootBullet() {
        let bullet = SpriteEntity(filePath: "images/bullet.png")
        bullet.position = canon.position

        let velocity = Vector.fromAngleDegrees(canon.rotate - 90)
        bullet.velocity = velocity * 5
        bullets.append(bullet)
    }

    private func spawnBomb() {
        let bomb = SpriteEntity(filePath: "images/bullet.png")
        let timeValue = System.getSecondsSinceEpoch(milliseconds: nil)
        let randomX = Float(timeValue % 380) + 10
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
