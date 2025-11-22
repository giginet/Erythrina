import Playdate

final class Game: @unchecked Sendable {
    private var soundPlayer: OpaquePointer?
    private var background: SpriteEntity
    private var canon: SpriteEntity
    private var degree: Float = 0
    
    init() {
        soundPlayer = Sound.FilePlayer.newPlayer()
        let result = Sound.FilePlayer.loadIntoPlayer(soundPlayer!, "sounds/explosion")
        System.logToConsole("\(result)")
        
        background = SpriteEntity(filePath: "images/background.png")
        background.anchorPoint = Vector(x: 0, y: 0)
//        background.addSprite()
        
        canon = SpriteEntity(filePath: "images/canon.png")
        canon.position = Vector(x: 100, y: 100)
    }
    
    func initialize() {
    }
    
    func update(pointer: UnsafeMutableRawPointer!) -> Int32 {
        background.draw()
        canon.rotate += 10
        canon.draw()
        
        if System.buttonState.pushed == .a {
            let result = Sound.FilePlayer.play(soundPlayer!, 1)
            System.logToConsole("\(result)")
        }
        
        let change = Crank.change
        System.logToConsole("\(Int(change * 100))")
                
        return 1
    }
    
    private static func makeBackground() -> Sprite {
        var sprite = Sprite(bitmapPath: "images/background.png")
        sprite.collisionsEnabled = false
        sprite.zIndex = 0
        return sprite
    }
}
