import Playdate

final class SpriteEntity {
    var position: Vector = Vector(x: 0, y: 0)
    var anchorPoint: Vector = Vector(x: 0.5, y: 0.5)
    var rotate: Float = 0
    var velocity: Vector = .zero
    private let sprite: Sprite
    
    init(filePath: StaticString) {
        sprite = Sprite(bitmapPath: filePath)
    }
    
    func updateAndDraw() {
        position = position + velocity
        
        Graphics.drawRotatedBitmap(
            bitmap: bitmap.unsafelyUnwrapped,
            x: Int32(position.x),
            y: Int32(position.y),
            degrees: rotate,
            centerx: anchorPoint.x,
            centery: anchorPoint.y,
            xscale: 1,
            yscale: 1
        )
    }
    
    private var bitmap: LCDBitmap {
        sprite.image!
    }

    var width: Float {
        sprite.bounds.width
    }

    var height: Float {
        sprite.bounds.height
    }

    func intersects(with other: SpriteEntity) -> Bool {
        let left = position.x - width * anchorPoint.x
        let right = left + width
        let top = position.y - height * anchorPoint.y
        let bottom = top + height

        let otherLeft = other.position.x - other.width * other.anchorPoint.x
        let otherRight = otherLeft + other.width
        let otherTop = other.position.y - other.height * other.anchorPoint.y
        let otherBottom = otherTop + other.height

        return left < otherRight && right > otherLeft &&
               top < otherBottom && bottom > otherTop
    }
}
