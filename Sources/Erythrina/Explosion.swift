import Playdate

struct Explosion {
    private let sprite: SpriteEntity
    private var timer: Int
    private let duration: Int = 30 // frames to show explosion

    init(position: Vector) {
        sprite = SpriteEntity(filePath: "images/explosion.png")
        sprite.position = position
        timer = 0
    }

    var isFinished: Bool {
        timer >= duration
    }

    mutating func update() {
        timer += 1
    }

    func draw() {
        if isFinished {
            return
        }

        // Calculate fade-out effect by skipping frames
        // Early: draw every frame
        // Mid: draw every 2nd frame
        // Late: draw every 3rd frame
        let progress = Float(timer) / Float(duration)

        if progress < 0.5 {
            // First half: always draw
            sprite.updateAndDraw()
        } else if progress < 0.75 {
            // Third quarter: draw every 2nd frame
            if timer % 2 == 0 {
                sprite.updateAndDraw()
            }
        } else {
            // Last quarter: draw every 3rd frame
            if timer % 3 == 0 {
                sprite.updateAndDraw()
            }
        }
    }
}
