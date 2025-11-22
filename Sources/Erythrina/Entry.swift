import Playdate

// Opt out of static concurrency checking. We know that the playdate runtime is
// single threaded and this global will never be concurrently accessed.

let game = Game()

@_cdecl("eventHandler")
public func eventHandler(
    pointer: UnsafeMutableRawPointer!,
    event: PDSystemEvent,
    arg: UInt32
) -> Int32 {
    if event == .initialize {
        // Setup the Playdate API, this is required for functions like:
        // `Display.setRefreshRate(rate: 0)` to call into the correct Playdate
        // runtime function
        initializePlaydateAPI(with: pointer)
        
        // Configure the display to run as fast as our game can run (on the Playdate
        // simulator)
        Display.setRefreshRate(rate: 0)
        
        // Setup the `update` function below as the function to call on each game
        // runloop tick.
        System.setUpdateCallback(update: { game.update(pointer: $0) }, userdata: nil)
        
        game.initialize()
    }
    return 0
}
