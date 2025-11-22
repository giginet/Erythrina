import Playdate

struct SpriteEntity: ~Copyable {
    var position: Vector = Vector(x: 0, y: 0)
    var anchorPoint: Vector = Vector(x: 0.5, y: 0.5)
    var rotate: Float = 0
    private let sprite: Sprite
    
    init(filePath: StaticString) {
        sprite = Sprite(bitmapPath: filePath)
    }
    
    func draw() {
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
}
