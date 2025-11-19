import Playdate

public import Playdate

infix operator %% : MultiplicationPrecedence

func %% (lhs: Int32, rhs: Int32) -> Int32 {
    let rem = lhs % rhs
    return rem >= 0 ? rem : rem + rhs
}

enum Pixel: Int {
    case black = 0
    case white = 1
}

struct Square {
    var x: Int32
    var y: Int32
    var width: Int32
    var height: Int32
    
    func draw(to frame: inout Frame) {
        for x in stride(from: x, to: x + width, by: 1) {
            for y in stride(from: y, to: y + height, by: 1) {
                frame[x, y] = .black
            }
        }
    }
}

struct Frame {
    static let rows = LCD_ROWS
    static let rowSize = LCD_ROWSIZE
    static let columns = LCD_COLUMNS
    
    // Must be mutable because the setter writes to it
    var buffer: UnsafeMutablePointer<UInt8>
    
    subscript(x: Int32, y: Int32) -> Pixel {
        get {
            // Compute the byte index and bit position for (x, y)
            let byteIndex = Int((y * Self.rowSize) + (x / 8))
            let shift = Int(x % 8)
            let bitPosition = UInt8(0b10000000 >> shift)
            let byte = buffer[byteIndex]
            return (byte & bitPosition) == 0 ? .black : .white
        }
        set {
            let byteIndex = Int((y * Self.rowSize) + (x / 8))
            let shift = Int(x % 8)
            let bitPosition = UInt8(0b10000000 >> shift)
            var byte = buffer[byteIndex]
            if newValue == .black {
                byte &= ~bitPosition
            } else {
                byte |= bitPosition
            }
            buffer[byteIndex] = byte
        }
    }
    
    /// The frame currently on screen.
    static var current: Self { Frame(buffer: Graphics.getDisplayFrame()!) }
    
    /// The frame to be displayed on the screen on the next update.
    static var next: Self { Frame(buffer: Graphics.getFrame()!) }
//    
//    /// Updates each pixel of this frame based on the values in the previous
//    /// frame.
//    @inline(__always)
//    mutating func update(frameCurrent: Frame) {
//        for squareX in 0..<100 {
//            for squareY in 0..<100 {
//                self[Int32(squareX) + 20, Int32(squareY) + 20] = .black
//            }
//        }
//    }
}

final class Game: @unchecked Sendable {
    private var square: Square = Square(x: 0, y: 0, width: 32, height: 32)
    private var soundPlayer: OpaquePointer?
    
    init() {
        soundPlayer = Sound.FilePlayer.newPlayer()
        let result = Sound.FilePlayer.loadIntoPlayer(soundPlayer!, "sounds/explosion")
        System.logToConsole("\(result)")
    }
    
    func update(pointer: UnsafeMutableRawPointer!) -> Int32 {
        
        Sprite.setupBackground()
        
        Sprite.drawSprites()
        
        if System.buttonState.pushed == .a {
            let result = Sound.FilePlayer.play(soundPlayer!, 1)
            System.logToConsole("\(result)")
        }
                
        return 1
    }
}

/// Playdate Frame
///
/// ```
/// (column: 0, row: 0)                    (column: LCD_COLUMNS, row: 0)
/// ╭──────────────────────────────────────────────────────────────────╮
/// │                                                                  │
/// │             SSSSS  CCCCC  RRRR   EEEEE  EEEEE  N   N             │
/// │             S      C      R   R  E      E      NN  N             │
/// │             SSSSS  C      RRRR   EEEEE  EEEEE  N N N             │
/// │                 S  C      R R    E      E      N  NN             │
/// │             SSSSS  CCCCC  R  R   EEEEE  EEEEE  N   N             │
/// │                                                                  │
/// ╰──────────────────────────────────────────────────────────────────╯
/// (column: 0, row: LCD_ROWS)      (column: LCD_COLUMNS, row: LCD_ROWS)
/// ```
