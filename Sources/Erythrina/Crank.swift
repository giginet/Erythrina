import Playdate

enum Crank { }

extension Crank {
    static var angle: Float {
        System.crankAngle
    }
    
    static var change: Float {
        System.crankChange
    }
    
    static var isDocked: Bool {
        System.isCrankDocked
    }
}
