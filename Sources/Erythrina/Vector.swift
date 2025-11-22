import Playdate

public struct Vector: Sendable {
    public var x: Float
    public var y: Float

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    // MARK: - Computed Properties

    /// ベクトルの長さ（大きさ）
    public var length: Float {
        sqrtf(x * x + y * y)
    }

    /// ベクトルの長さの二乗（平方根計算を避けたい場合に使用）
    public var lengthSquared: Float {
        x * x + y * y
    }

    /// 正規化されたベクトル（長さ1のベクトル）
    public var normalized: Vector {
        let len = length
        guard len > 0 else { return Vector(x: 0, y: 0) }
        return Vector(x: x / len, y: y / len)
    }

    // MARK: - Operations

    /// ベクトルの加算
    public static func + (lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// ベクトルの減算
    public static func - (lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// スカラー倍
    public static func * (vector: Vector, scalar: Float) -> Vector {
        Vector(x: vector.x * scalar, y: vector.y * scalar)
    }

    /// スカラー倍（順序逆）
    public static func * (scalar: Float, vector: Vector) -> Vector {
        Vector(x: vector.x * scalar, y: vector.y * scalar)
    }

    /// スカラー除算
    public static func / (vector: Vector, scalar: Float) -> Vector {
        Vector(x: vector.x / scalar, y: vector.y / scalar)
    }

    /// 複合代入演算子: 加算
    public static func += (lhs: inout Vector, rhs: Vector) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    /// 複合代入演算子: 減算
    public static func -= (lhs: inout Vector, rhs: Vector) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    /// 複合代入演算子: スカラー倍
    public static func *= (lhs: inout Vector, scalar: Float) {
        lhs.x *= scalar
        lhs.y *= scalar
    }

    /// 複合代入演算子: スカラー除算
    public static func /= (lhs: inout Vector, scalar: Float) {
        lhs.x /= scalar
        lhs.y /= scalar
    }

    /// 単項マイナス
    public static prefix func - (vector: Vector) -> Vector {
        Vector(x: -vector.x, y: -vector.y)
    }

    // MARK: - Advanced Operations

    /// 内積
    public func dot(_ other: Vector) -> Float {
        x * other.x + y * other.y
    }

    /// 外積のZ成分（2Dベクトルの外積はスカラー値）
    public func cross(_ other: Vector) -> Float {
        x * other.y - y * other.x
    }

    /// 指定された角度（ラジアン）で回転
    public func rotated(by radians: Float) -> Vector {
        let cos = cosf(radians)
        let sin = sinf(radians)
        return Vector(
            x: x * cos - y * sin,
            y: x * sin + y * cos
        )
    }

    /// 指定された角度（度）で回転
    public func rotated(byDegrees degrees: Float) -> Vector {
        rotated(by: degrees * .pi / 180.0)
    }

    /// 指定された長さにリサイズ
    public func resized(to length: Float) -> Vector {
        normalized * length
    }

    /// 各成分を指定範囲にクランプ
    public func clamped(min: Float, max: Float) -> Vector {
        Vector(
            x: Swift.min(Swift.max(x, min), max),
            y: Swift.min(Swift.max(y, min), max)
        )
    }

    /// 長さを指定範囲にクランプ
    public func clampedLength(min: Float, max: Float) -> Vector {
        let len = length
        if len < min {
            return resized(to: min)
        } else if len > max {
            return resized(to: max)
        }
        return self
    }

    /// 他のベクトルとの距離
    public func distance(to other: Vector) -> Float {
        (self - other).length
    }

    /// 他のベクトルとの距離の二乗
    public func distanceSquared(to other: Vector) -> Float {
        (self - other).lengthSquared
    }

    /// 線形補間
    public func lerp(to other: Vector, t: Float) -> Vector {
        self + (other - self) * t
    }

    /// 2つのベクトル間の角度（ラジアン）
    public func angle(to other: Vector) -> Float {
        let dotProduct = dot(other)
        let lengths = length * other.length
        guard lengths > 0 else { return 0 }
        return acosf(Swift.min(Swift.max(dotProduct / lengths, -1), 1))
    }
}

// MARK: - Convenience Initializers

extension Vector {
    /// ゼロベクトル
    public static let zero = Vector(x: 0, y: 0)

    /// 単位ベクトル (1, 0)
    public static let unitX = Vector(x: 1, y: 0)

    /// 単位ベクトル (0, 1)
    public static let unitY = Vector(x: 0, y: 1)

    /// 角度から単位ベクトルを生成（ラジアン）
    public static func fromAngle(_ radians: Float) -> Vector {
        Vector(x: cosf(radians), y: sinf(radians))
    }

    /// 角度から単位ベクトルを生成（度）
    public static func fromAngleDegrees(_ degrees: Float) -> Vector {
        fromAngle(degrees * .pi / 180.0)
    }
}

// MARK: - Equatable

extension Vector: Equatable {
    public static func == (lhs: Vector, rhs: Vector) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// MARK: - CustomStringConvertible

extension Vector: CustomStringConvertible {
    public var description: String {
        "Vector(x: \(x), y: \(y))"
    }
}
