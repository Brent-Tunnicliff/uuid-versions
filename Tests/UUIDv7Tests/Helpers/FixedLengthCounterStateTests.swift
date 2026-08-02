// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv7

struct FixedLengthCounterStateTests {
    @Test(arguments: GetFixedLengthCounterArgument.allCases)
    func getFixedLengthCounter(_ argument: GetFixedLengthCounterArgument) throws {
        let mockRandomNumberGenerator = MockRandomNumberGenerator.mock(ofSizeUInt16Values: [argument.randomNumberValue])

        let initialCache = argument.initialCache
        let fixedLengthCounterState = FixedLengthCounterState(
            cache: initialCache,
            randomNumberGenerator: mockRandomNumberGenerator
        )

        let result = try fixedLengthCounterState.getFixedLengthCounter(
            timestamp: argument.nowTimestamp,
            fractionNanoseconds: argument.nowFractionNanoseconds
        )

        #expect(result == argument.expectedResult)
    }

    @Test
    func getFixedLengthCounterThrowsIfMatchingCacheIsAtMax() throws {
        let timeStamp: UInt64 = 0
        let fractionNanoseconds: UInt16 = 0
        let fixedLengthCounterState = FixedLengthCounterState(
            cache: (StateKey(timestamp: timeStamp, fractionNanoseconds: fractionNanoseconds), .max),
            randomNumberGenerator: .mock()
        )

        #expect(throws: CounterAtMaxSizeError.self) {
            try fixedLengthCounterState.getFixedLengthCounter(
                timestamp: timeStamp,
                fractionNanoseconds: fractionNanoseconds
            )
        }
    }
}

extension FixedLengthCounterStateTests {
    enum GetFixedLengthCounterArgument: CaseIterable {
        case cacheEmpty
        case cacheContainsSameKey
        case cacheContainsOlderTimestamp
        case cacheContainsOlderFractionNanoseconds

        // An edge case that was simple to also cover.
        case cacheContainsFutureTimestamp
        case cacheContainsFutureFractionNanoseconds

        var initialCache: FixedLengthCounterState.Cache {
            let key: StateKey
            switch self {
            case .cacheEmpty:
                return nil
            case .cacheContainsSameKey:
                key = StateKey(timestamp: nowTimestamp, fractionNanoseconds: nowFractionNanoseconds)
            case .cacheContainsFutureTimestamp:
                key = StateKey(
                    timestamp: nowTimestamp + 1,
                    fractionNanoseconds: nowFractionNanoseconds
                )
            case .cacheContainsOlderTimestamp:
                key = StateKey(
                    timestamp: nowTimestamp - 1,
                    fractionNanoseconds: nowFractionNanoseconds
                )
            case .cacheContainsFutureFractionNanoseconds:
                key = StateKey(
                    timestamp: nowTimestamp,
                    fractionNanoseconds: nowFractionNanoseconds + 1
                )
            case .cacheContainsOlderFractionNanoseconds:
                key = StateKey(
                    timestamp: nowTimestamp,
                    fractionNanoseconds: nowFractionNanoseconds - 1
                )
            }

            return (key, 345)
        }

        var nowTimestamp: UInt64 {
            1_234_567_890
        }

        var nowFractionNanoseconds: UInt16 {
            5_432
        }

        var randomNumberValue: UInt16 {
            12_345
        }

        var expectedResult: UInt16 {
            switch self {
            // new random number
            case .cacheEmpty, .cacheContainsOlderTimestamp, .cacheContainsOlderFractionNanoseconds:
                randomNumberValue

            // the cached value is bumped by 1
            case .cacheContainsSameKey, .cacheContainsFutureTimestamp, .cacheContainsFutureFractionNanoseconds:
                (initialCache?.value ?? .max) + 1
            }
        }
    }
}
