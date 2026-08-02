// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
import Testing

/// These tests are just sanity tests that the results appear to be roughly right.
struct DefaultRandomNumberGeneratorTests {
    private let randomNumberGenerator = DefaultRandomNumberGenerator.shared
    private let rangeOfIterations = 0..<100_000

    @Test
    func byte() {
        var values: Set<UInt8> = []
        for _ in rangeOfIterations {
            // The real test to just to make sure it does not crash do to invalid number of bits.
            // The value is expected to be anywhere between UInt.min (0) and UInt.max (255).
            values.insert(randomNumberGenerator.byte)
        }

        // We expect multiple different values
        #expect(values.count > 1)
    }

    @Test(arguments: [1, 25, 1000])
    func bytes(size: Int) {
        var values: Set<UInt8> = []
        // The nested loops can take a very long time.
        // So lets reduce the outer loop based on the size of the inner loops.
        let rangeOfIterations = self.rangeOfIterations.lowerBound..<(self.rangeOfIterations.upperBound / size)
        for _ in rangeOfIterations {
            let results = randomNumberGenerator.bytes(size: size)
            #expect(results.count == size)
            for result in results {
                values.insert(result)
            }
        }

        // We expect multiple different values
        #expect(values.count > 1)
    }

    @Test
    func int48() {
        // Max value of 48 bits.
        let maxValue: UInt64 = 0xFF_FF_FF_FF_FF_FF
        let expectedRange: ClosedRange<UInt64> = 0...maxValue
        var values: Set<UInt64> = []
        for _ in rangeOfIterations {
            let result = randomNumberGenerator.int48
            #expect(expectedRange.contains(result), "value \(result) out of range")
            values.insert(result)
        }

        // We expect multiple different values
        #expect(values.count > 1)
    }

    @Test(arguments: [255, 1000, UInt16.max])
    func ofSize(size: UInt16) {
        let expectedRange: ClosedRange<UInt16> = 0...size
        var values: Set<UInt16> = []
        for _ in rangeOfIterations {
            let result = randomNumberGenerator.of(size: size)
            #expect(expectedRange.contains(result), "value \(result) out of range")
            values.insert(result)
        }

        // We expect multiple different values
        #expect(values.count > 1)
    }
}
