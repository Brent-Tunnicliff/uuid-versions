// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
import UUIDv1

struct DefaultClockSequenceServiceTests {
    private let clockSequence: UInt16 = 0x33C8
    private let previousTimestamp: UInt64 = 1000

    @Test
    func getClockSequenceWithLaterTimestampReturnsCachedValue() {
        let clockSequenceService = DefaultClockSequenceService(
            clockSequence: clockSequence,
            clockSequenceIncrement: 1,
            previousTimestamp: previousTimestamp
        )

        let timestamp = previousTimestamp + 100
        #expect(clockSequenceService.getClockSequence(timestamp: timestamp) == clockSequence)
    }

    @Test
    func getClockSequenceWithEarlierTimestampReturnsAdvancedValue() {
        let clockSequenceService = DefaultClockSequenceService(
            clockSequence: clockSequence,
            clockSequenceIncrement: 1,
            previousTimestamp: previousTimestamp
        )

        let expectedClockSequence: UInt16 = 0x33C9
        let earlierTimestamp = previousTimestamp - 100
        #expect(clockSequenceService.getClockSequence(timestamp: earlierTimestamp) == expectedClockSequence)

        // Lets check that the advanced clockSequence was cached and continues to be returned.
        let laterTimestamp = previousTimestamp + 100
        #expect(clockSequenceService.getClockSequence(timestamp: laterTimestamp) == expectedClockSequence)
    }

    @Test
    func customClockSequenceIncrement() {
        let clockSequenceService = DefaultClockSequenceService(
            clockSequence: clockSequence,
            // 0x0100 is the value that UUIDv2 needs.
            clockSequenceIncrement: 0x0100,
            previousTimestamp: previousTimestamp
        )

        let expectedClockSequence: UInt16 = 0x34C8
        let earlierTimestamp = previousTimestamp - 100
        #expect(clockSequenceService.getClockSequence(timestamp: earlierTimestamp) == expectedClockSequence)
    }
}
