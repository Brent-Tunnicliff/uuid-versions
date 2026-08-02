// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv1

/// These tests are just sanity tests that the results appear to be roughly right
/// and not causing crashes with incorrect data size.
@Suite("UInt16+randomClockSequenceTests")
struct UInt16RandomClockSequenceTests {
    private let rangeOfIterations = 0..<100_000

    @Test
    func randomClockSequence() {
        /// Max value of 14 bits.
        let maxValue: UInt16 = 16_383
        let expectedRange: ClosedRange<UInt16> = 0...maxValue
        var values: Set<UInt16> = []
        for _ in rangeOfIterations {
            let result = UInt16.randomClockSequence
            #expect(expectedRange.contains(result))
            values.insert(result)
        }

        // We expect multiple different values
        #expect(values.count > 1)
    }
}
