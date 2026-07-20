// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv7

struct StateKeyTests {
    @Test
    func comparable() async throws {
        let keyA = StateKey(timestamp: 1, fractionNanoseconds: 1)
        let keyB = StateKey(timestamp: 1, fractionNanoseconds: 5)
        let keyC = StateKey(timestamp: 2, fractionNanoseconds: 4)
        let keyD = StateKey(timestamp: 3, fractionNanoseconds: 2)
        let keyE = StateKey(timestamp: 4, fractionNanoseconds: 3)

        let values = [
            keyE,
            keyB,
            keyD,
            keyA,
            keyC,
        ]

        let expectedResults = [
            keyA,
            keyB,
            keyC,
            keyD,
            keyE,
        ]

        #expect(values.sorted() == expectedResults)
    }
}
