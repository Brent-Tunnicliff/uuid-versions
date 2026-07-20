// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

struct MockRandomNumberGenerator: RandomNumberGenerator {
    var byte: UInt8 { preconditionFailure("Not implemented") }
    let int48: UInt64

    init(int48: UInt64) {
        self.int48 = int48
    }

    func bytes(size: Int) -> [UInt8] {
        preconditionFailure("Not implemented")
    }

    func of(size: UInt16) -> UInt16 {
        preconditionFailure("Not implemented")
    }
}

extension RandomNumberGenerator where Self == MockRandomNumberGenerator {
    static func mock(int48: UInt64 = 0) -> Self {
        Self(int48: int48)
    }
}
