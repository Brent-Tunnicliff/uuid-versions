// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

struct StateKey {
    let timestamp: UInt64
    let fractionNanoseconds: UInt16
}

extension StateKey: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.timestamp == rhs.timestamp else {
            return lhs.timestamp < rhs.timestamp
        }

        return lhs.fractionNanoseconds < rhs.fractionNanoseconds
    }
}

extension StateKey: Hashable {}
