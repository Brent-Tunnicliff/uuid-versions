// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

package protocol ClockSequenceService: Sendable {
    func getClockSequence(timestamp: UInt64) -> UInt16
}

extension ClockSequenceService where Self == DefaultClockSequenceService {
    static var `default`: Self {
        .shared
    }
}

package final class DefaultClockSequenceService {
    static let shared = DefaultClockSequenceService(clockSequenceIncrement: 1)

    /// Wraps access in locks to make it safe to be Sendable.
    private let lock = Lock()

    private var clockSequence: UInt16
    private let clockSequenceIncrement: UInt16
    private var previousTimestamp: UInt64 = 0

    package convenience init(clockSequenceIncrement: UInt16) {
        self.init(
            clockSequence: .randomClockSequence,
            clockSequenceIncrement: 1,
            previousTimestamp: 0
        )
    }

    package init(
        clockSequence: UInt16,
        clockSequenceIncrement: UInt16,
        previousTimestamp: UInt64
    ) {
        self.clockSequence = clockSequence
        self.clockSequenceIncrement = clockSequenceIncrement
        self.previousTimestamp = previousTimestamp
    }
}

extension DefaultClockSequenceService: ClockSequenceService {
    /// Retrieves the clock sequence.
    ///
    /// - Parameter timestamp: The timestamp for determining if the clock was moved backwards.
    ///     If it is lower than the current cached value then the cached clock sequence is incremented before returning.
    /// - Returns: The cached clock sequence.
    package func getClockSequence(timestamp: UInt64) -> UInt16 {
        lock.withLock {
            defer {
                previousTimestamp = timestamp
            }

            let clockSequence: UInt16
            if timestamp <= previousTimestamp {
                // new time stamp is less than last time, so advance clock sequence to avoid possible collisions.
                clockSequence = (self.clockSequence + clockSequenceIncrement) & 0x3FFF
                self.clockSequence = clockSequence
            } else {
                clockSequence = self.clockSequence
            }

            return clockSequence
        }
    }
}

extension DefaultClockSequenceService: @unchecked Sendable {}
