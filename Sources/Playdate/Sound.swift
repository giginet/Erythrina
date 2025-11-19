import CPlaydate

var soundAPI: playdate_sound { playdateAPI.sound.unsafelyUnwrapped.pointee }

public enum Sound { }

extension Sound {
    public enum FilePlayer { }
}

extension Sound.FilePlayer {
    private static var filePlayer: playdate_sound_fileplayer {
        soundAPI.fileplayer.unsafelyUnwrapped.pointee
    }
    
    public static func newPlayer() -> OpaquePointer? {
        filePlayer.newPlayer()
    }
    
    public static func loadIntoPlayer(_ filePlayer: OpaquePointer, _ path: StaticString) -> Int32 {
        self.filePlayer.loadIntoPlayer(filePlayer, path.utf8Start)
    }
    
    public static func play(_ filePlayer: OpaquePointer, _ `repeat`: Int32) -> Int32 {
        self.filePlayer.play(filePlayer, `repeat`)
    }
}
