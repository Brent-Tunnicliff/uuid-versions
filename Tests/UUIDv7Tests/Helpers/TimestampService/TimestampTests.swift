// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv7

struct TimestampTests {
    let valueA = Timestamp(milliseconds: 0, fraction: 0)
    let valueB = Timestamp(milliseconds: 0, fraction: 1)
    let valueC = Timestamp(milliseconds: 1, fraction: 0)
    let valueD = Timestamp(milliseconds: 1, fraction: 1)

    @Test
    func comparable() {
        // valueA
        #expect(valueA == valueA)
        #expect(valueA < valueB)
        #expect(valueA < valueC)
        #expect(valueA < valueD)

        // valueB
        #expect(valueB > valueA)
        #expect(valueB == valueB)
        #expect(valueB < valueC)
        #expect(valueB < valueD)

        // valueC
        #expect(valueC > valueA)
        #expect(valueC > valueB)
        #expect(valueC == valueC)
        #expect(valueC < valueD)

        // valueD
        #expect(valueD > valueA)
        #expect(valueD > valueB)
        #expect(valueD > valueC)
        #expect(valueD == valueD)
    }

    @Test
    func sorted() {
        let expectedResult = [
            valueA,
            valueB,
            valueC,
            valueD,
        ]

        #expect([valueD, valueB, valueA, valueC].sorted() == expectedResult)
    }
}
