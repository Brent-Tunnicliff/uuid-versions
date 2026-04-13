// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

protocol RandomNumberGenerator: Sendable {
    /// Returns a random byte number.
    var byte: UInt8 { get }

    /// Returns a new valid clock sequence number.
    var clockSequence: UInt16 { get }

    /// Returns a random 48 bit number.
    var int48: UInt64 { get }

    /// Return an array of bytes.
    ///
    /// This is a connivence over calling ``byte`` multiple times manually.
    ///
    /// - Parameter size: The size of the array to return. E.g. a size of 5 will return an array of 5 random bytes.
    /// - Returns: An array containing a number of random bytes.
    func bytes(size: Int) -> [UInt8]

    func of(size: UInt16) -> UInt16
}

extension RandomNumberGenerator where Self == DefaultRandomNumberGenerator {
    @inlinable
    @inline(__always)
    static var `default`: Self {
        .shared
    }
}

struct DefaultRandomNumberGenerator: RandomNumberGenerator {
    fileprivate static let shared = DefaultRandomNumberGenerator()

    var byte: UInt8 {
        UInt8.random(in: 0...255)
    }

    var clockSequence: UInt16 {
        UInt16.random(in: 0..<16384)
    }

    var int48: UInt64 {
        UInt64.random(in: 0..<(1 << 48))
    }

    func bytes(size: Int) -> [UInt8] {
        (0..<size).map { _ in
            byte
        }
    }

    func of(size: UInt16) -> UInt16 {
        UInt16.random(in: 0..<size)
    }
}
