// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import UUIDv6

struct MockClockSequenceGenerator: ClockSequenceGenerator {
    var clockSequence: UInt16

    func generateClockSequence() -> UInt16 {
        clockSequence
    }
}

extension ClockSequenceGenerator where Self == MockClockSequenceGenerator {
    static func mock(clockSequence: UInt16 = 0x33C8) -> Self {
        Self(clockSequence: clockSequence)
    }
}
