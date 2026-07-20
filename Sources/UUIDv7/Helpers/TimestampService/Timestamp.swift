// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

struct Timestamp: Equatable {
    let milliseconds: UInt64
    let fraction: UInt16
}

extension Timestamp: Comparable {
    static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        guard lhs.milliseconds == rhs.milliseconds else {
            return lhs.milliseconds < rhs.milliseconds
        }

        return lhs.fraction < rhs.fraction
    }
}

extension Timestamp: Hashable {}
