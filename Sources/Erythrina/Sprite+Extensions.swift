import Playdate

extension Sprite {
    init(bitmapPath: StaticString) {
        let bitmap = Graphics.loadBitmap(path: bitmapPath)
        var width: Int32 = 0
        var height: Int32 = 0
        Graphics.getBitmapData(
            bitmap: bitmap,
            width: &width,
            height: &height,
            rowbytes: nil,
            mask: nil,
            data: nil)
        let bounds = PDRect(x: 0, y: 0, width: Float(width), height: Float(height))
        
        self.init()
        self.setImage(image: bitmap)
        self.bounds = bounds
        self.collideRect = bounds
    }
}

extension Sprite {
    static func setupBackground() {
        var sprite = Sprite(bitmapPath: "images/background.png")
        sprite.collisionsEnabled = false
        sprite.zIndex = 0
        sprite.addSprite()
        sprite.forget()
    }
}
