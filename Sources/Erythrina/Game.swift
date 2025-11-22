import Playdate

public import Playdate

final class Game: @unchecked Sendable {
    private var soundPlayer: OpaquePointer?
    
    init() {
        soundPlayer = Sound.FilePlayer.newPlayer()
        let result = Sound.FilePlayer.loadIntoPlayer(soundPlayer!, "sounds/explosion")
        System.logToConsole("\(result)")
    }
    
    func update(pointer: UnsafeMutableRawPointer!) -> Int32 {
        
        var background = makeBackground()
        background.addSprite()
        background.forget()
        
        Sprite.drawSprites()
        
        if System.buttonState.pushed == .a {
            let result = Sound.FilePlayer.play(soundPlayer!, 1)
            System.logToConsole("\(result)")
        }
                
        return 1
    }
    
    private func makeBackground() -> Sprite {
        var sprite = Sprite(bitmapPath: "images/background.png")
        sprite.collisionsEnabled = false
        sprite.zIndex = 0
        sprite.forget()
        return sprite
    }
}
