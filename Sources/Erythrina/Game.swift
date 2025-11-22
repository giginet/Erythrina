import Playdate

struct Canon: ~Copyable {
    private(set) var sprite: Sprite
    
    init() {
        sprite = Sprite(bitmapPath: "images/canon.png")
        sprite.zIndex = 10
    }
    
    deinit {
//        sprite.forget()
    }
}

final class Game: @unchecked Sendable {
    private var soundPlayer: OpaquePointer?
    private let background: Sprite
    private let canon: Canon
    
    init() {
        soundPlayer = Sound.FilePlayer.newPlayer()
        let result = Sound.FilePlayer.loadIntoPlayer(soundPlayer!, "sounds/explosion")
        System.logToConsole("\(result)")
        
        background = Sprite(bitmapPath: "images/background.png")
        background.addSprite()
        
        canon = Canon()
        canon.sprite.addSprite()
    }
    
    func initialize() {
        var background = Self.makeBackground()
        background.addSprite()
    }
    
    func update(pointer: UnsafeMutableRawPointer!) -> Int32 {
        Sprite.drawSprites()
        
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
