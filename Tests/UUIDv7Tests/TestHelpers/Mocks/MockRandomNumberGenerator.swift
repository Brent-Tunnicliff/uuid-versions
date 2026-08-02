// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
@testable import UUIDv7

final class MockRandomNumberGenerator: RandomNumberGenerator, @unchecked Sendable {
    private let lock = Lock()

    private var byteValues: [UInt8]
    var byte: UInt8 {
        lock.withLock { byteValues.removeFirst() }
    }

    var int48: UInt64 {
        preconditionFailure("Not implemented")
    }

    init(
        byteValues: [UInt8],
        bytesSizeValues: [UInt8],
        ofSizeUInt16Values: [UInt16]
    ) {
        self.byteValues = byteValues
        self.bytesSizeValues = bytesSizeValues
        self.ofSizeUInt16Values = ofSizeUInt16Values
    }

    private var bytesSizeValues: [UInt8]
    func bytes(size: Int) -> [UInt8] {
        lock.withLock {
            (0..<size).map { _ in
                bytesSizeValues.removeFirst()
            }
        }
    }

    private var ofSizeUInt16Values: [UInt16]
    func of(size: UInt16) -> UInt16 {
        lock.withLock { ofSizeUInt16Values.removeFirst() }
    }
}

extension RandomNumberGenerator where Self == MockRandomNumberGenerator {
    static func mock(
        byteValues: [UInt8] = [0],
        bytesSizeValues: [UInt8] = [0],
        ofSizeUInt16Values: [UInt16] = [0]
    ) -> Self {
        Self(
            byteValues: byteValues,
            bytesSizeValues: bytesSizeValues,
            ofSizeUInt16Values: ofSizeUInt16Values
        )
    }

    /// Initially set all as max.
    static func mockWithMaxValues() -> Self {
        Self(
            byteValues: (0..<40).map { _ in UInt8.max },
            bytesSizeValues: (0..<40).map { _ in UInt8.max },
            ofSizeUInt16Values: (0..<40).map { _ in UInt16.max }
        )
    }
}
