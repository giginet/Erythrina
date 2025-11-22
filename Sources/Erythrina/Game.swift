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
    private var canon: Canon
    private var degree: Float = 0
    
    init() {
        soundPlayer = Sound.FilePlayer.newPlayer()
        let result = Sound.FilePlayer.loadIntoPlayer(soundPlayer!, "sounds/explosion")
        System.logToConsole("\(result)")
        
        background = Sprite(bitmapPath: "images/background.png")
//        background.addSprite()
        
        canon = Canon()
//        canon.sprite.addSprite()
        canon.sprite.moveTo(x: 100, y: 100)
    }
    
    func initialize() {
        var background = Self.makeBackground()
        background.addSprite()
    }
    
    func update(pointer: UnsafeMutableRawPointer!) -> Int32 {
//        Sprite.drawSprites()
        Graphics.drawBitmap(bitmap: background.image!.unsafelyUnwrapped, x: 0, y: 0, flip: LCDBitmapFlip(rawValue: 0)!)
        degree += 10
        Graphics.drawRotatedBitmap(bitmap: canon.sprite.image!.unsafelyUnwrapped, x: 100, y: 100, degrees: degree, centerx: 0.5, centery: 0.5, xscale: 1, yscale: 1)
        
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
