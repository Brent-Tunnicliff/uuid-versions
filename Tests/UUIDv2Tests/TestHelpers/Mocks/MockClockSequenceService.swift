// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import UUIDv1

struct MockClockSequenceService: ClockSequenceService {
    let clockSequence: UInt16

    func getClockSequence(timestamp: UInt64) -> UInt16 {
        clockSequence
    }
}

extension ClockSequenceService where Self == MockClockSequenceService {
    static func mock(clockSequence: UInt16) -> Self {
        Self(clockSequence: clockSequence)
    }
}
