// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv7

struct MonotonicRandomCounterStateTests {
    @Test(arguments: GetMonotonicRandomCounterArgument.allCases)
    func getMonotonicRandomCounter(_ argument: GetMonotonicRandomCounterArgument) throws {
        let mockRandomNumberGenerator = MockRandomNumberGenerator.mock(
            byteValues: argument.bytesSizeValues,
            bytesSizeValues: argument.bytesSizeValues
        )
        var initialCache: MonotonicRandomCounterState.Cache = [:]

        if let initialCacheKey = argument.initialCacheKey {
            initialCache[argument.size] = (initialCacheKey, argument.initialCacheValue)
        }

        let monotonicRandomCounterState = MonotonicRandomCounterState(
            cache: initialCache,
            randomNumberGenerator: mockRandomNumberGenerator
        )

        let result = try monotonicRandomCounterState.getMonotonicRandomCounter(
            timestamp: argument.nowTimestamp,
            fractionNanoseconds: argument.nowFractionNanoseconds,
            size: argument.size
        )

        #expect(result == argument.expectedResult)
    }

    @Test
    func getMonotonicRandomCounterThrowsIfMatchingCacheIsAtMax() throws {
        let timeStamp: UInt64 = 0
        let fractionNanoseconds: UInt16 = 0
        let size: Int = 6
        let cacheKey = StateKey(timestamp: timeStamp, fractionNanoseconds: fractionNanoseconds)
        let cacheValue = (0..<size).map({ _ in UInt8.max })
        let initialCache: MonotonicRandomCounterState.Cache = [
            size: (cacheKey, cacheValue)
        ]
        let monotonicRandomCounterState = MonotonicRandomCounterState(
            cache: initialCache,
            randomNumberGenerator: .mock()
        )

        #expect(throws: CounterAtMaxSizeError.self) {
            try monotonicRandomCounterState.getMonotonicRandomCounter(
                timestamp: timeStamp,
                fractionNanoseconds: fractionNanoseconds,
                size: size
            )
        }
    }
}

extension MonotonicRandomCounterStateTests {
    enum GetMonotonicRandomCounterArgument: CaseIterable {
        case cacheEmpty
        case cacheContainsSameKey
        case cacheContainsSameKeyWithMultipleMaxBytes
        case cacheContainsOlderTimestamp
        case cacheContainsOlderFractionNanoseconds

        // An edge case that was simple to also cover.
        case cacheContainsFutureTimestamp
        case cacheContainsFutureFractionNanoseconds

        var bytesSizeValues: [UInt8] { Array(UInt8.min...UInt8.max) }
        var nowTimestamp: UInt64 { 1_234_567_890 }
        var nowFractionNanoseconds: UInt16 { 5_432 }
        var size: Int { 6 }

        var initialCacheKey: StateKey? {
            switch self {
            case .cacheEmpty:
                nil
            case .cacheContainsSameKey, .cacheContainsSameKeyWithMultipleMaxBytes:
                StateKey(timestamp: nowTimestamp, fractionNanoseconds: nowFractionNanoseconds)
            case .cacheContainsFutureTimestamp:
                StateKey(
                    timestamp: nowTimestamp + 1,
                    fractionNanoseconds: nowFractionNanoseconds
                )
            case .cacheContainsOlderTimestamp:
                StateKey(
                    timestamp: nowTimestamp - 1,
                    fractionNanoseconds: nowFractionNanoseconds
                )
            case .cacheContainsFutureFractionNanoseconds:
                StateKey(
                    timestamp: nowTimestamp,
                    fractionNanoseconds: nowFractionNanoseconds + 1
                )
            case .cacheContainsOlderFractionNanoseconds:
                StateKey(
                    timestamp: nowTimestamp,
                    fractionNanoseconds: nowFractionNanoseconds - 1
                )
            }
        }

        var initialCacheValue: [UInt8] {
            switch self {
            case .cacheEmpty: []
            case .cacheContainsSameKeyWithMultipleMaxBytes:
                [0x00, 0xaa, 0xff, 0xff, 0xff, 0xff]
            case .cacheContainsSameKey,
                .cacheContainsFutureTimestamp,
                .cacheContainsOlderTimestamp,
                .cacheContainsFutureFractionNanoseconds,
                .cacheContainsOlderFractionNanoseconds:
                [9, 8, 7, 6, 5, 4]
            }
        }

        var expectedResult: [UInt8] {
            switch self {
            case .cacheEmpty,
                .cacheContainsOlderTimestamp,
                .cacheContainsOlderFractionNanoseconds:
                [0, 1, 2, 3, 4, 5]
            case .cacheContainsSameKey,
                .cacheContainsFutureTimestamp,
                .cacheContainsFutureFractionNanoseconds:
                [9, 8, 7, 6, 6, 0]
            case .cacheContainsSameKeyWithMultipleMaxBytes:
                // we increment by 1 the latest value that can, then fill following with random values.
                [0x00, 0xab, 0x00, 0x01, 0x02, 0x03]
            }
        }
    }
}
