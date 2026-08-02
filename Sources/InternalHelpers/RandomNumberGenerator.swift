// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

package protocol RandomNumberGenerator: Sendable {
    var byte: UInt8 { get }

    /// Returns a random 48 bit number.
    var int48: UInt64 { get }

    func bytes(size: Int) -> [UInt8]
    func of(size: UInt16) -> UInt16
}

extension RandomNumberGenerator where Self == DefaultRandomNumberGenerator {
    @inlinable
    package static var `default`: Self {
        .shared
    }
}

package struct DefaultRandomNumberGenerator: RandomNumberGenerator {
    package static let shared = DefaultRandomNumberGenerator()

    package var byte: UInt8 {
        UInt8.random(in: 0...255)
    }

    package var int48: UInt64 {
        UInt64.random(in: 0..<(1 << 48))
    }

    package func bytes(size: Int) -> [UInt8] {
        (0..<size).map { _ in
            byte
        }
    }

    package func of(size: UInt16) -> UInt16 {
        UInt16.random(in: 0..<size)
    }
}
