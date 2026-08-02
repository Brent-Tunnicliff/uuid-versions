// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
import Testing
@testable import UUIDv7

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

@Suite("UUID+v7Tests")
struct UUIDV7Tests {
    private static let randA = 0xCC3
    private static let randB: Int64 = (0b01 << 60) | 0x8_C4_DC_0C_0C_07_39_8F
    private let mockRandomNumberGenerator: MockRandomNumberGenerator = .mock(
        bytesSizeValues: [
            UInt8((randA >> 8) & 0x0F),
            UInt8(randA & 0xFF),
            UInt8((randB >> 56)),
            UInt8((randB >> 48) & 0xFF),
            UInt8((randB >> 40) & 0xFF),
            UInt8((randB >> 32) & 0xFF),
            UInt8((randB >> 24) & 0xFF),
            UInt8((randB >> 16) & 0xFF),
            UInt8((randB >> 8) & 0xFF),
            UInt8(randB & 0xFF),
        ]
    )

    // https://www.rfc-editor.org/rfc/rfc9562#name-example-of-a-uuidv6-value
    @Test
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func matchesTheStandardExample() throws {
        // MockDateService uses the common RFC9562 date example by default, so lets just reference it here.
        let mockDateService = try MockDateService()
        let uuid = UUID.v7(
            configuration: .default,
            fixedLengthCounterState: FixedLengthCounterState(
                cache: nil,
                randomNumberGenerator: mockRandomNumberGenerator
            ),
            monotonicRandomCounterState: MonotonicRandomCounterState(
                cache: [:],
                randomNumberGenerator: mockRandomNumberGenerator
            ),
            randomNumberGenerator: mockRandomNumberGenerator,
            sleepService: .mock(),
            timestampService: .mock(milliseconds: mockDateService.now.millisecondsSince1970)
        ).uuidString
        #expect(uuid == "017F22E2-79B0-7CC3-98C4-DC0C0C07398F")
    }

    @Test
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    func isValid() {
        let configurations: [Configuration] = [
            .default,
            .with(counter: .fixedLength),
            .with(counter: .monotonicRandom),
            .withIncreasedClockPrecision,
            .withIncreasedClockPrecision(counter: .fixedLength),
            .withIncreasedClockPrecision(counter: .monotonicRandom),
        ]

        for configuration in configurations {
            var previousValue: UUID?

            for _ in 0..<200 {
                let uuid = UUID.v7(configuration: configuration)
                let uuidString = uuid.uuidString.lowercased()

                // With the version and variant position we expect one of the following formats:
                //  - xxxxxxxx-xxxx-7xxx-8xxx-xxxxxxxxxxxx
                //  - xxxxxxxx-xxxx-7xxx-9xxx-xxxxxxxxxxxx
                //  - xxxxxxxx-xxxx-7xxx-axxx-xxxxxxxxxxxx
                //  - xxxxxxxx-xxxx-7xxx-bxxx-xxxxxxxxxxxx
                let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

                #expect(
                    uuidString.wholeMatch(of: regex) != nil,
                    "'\(uuidString)' does not match the expected UUIDv7 regex pattern for \(configuration)"
                )

                // Counters are meant to guarantee always incrementing, so lets add that as a sanity test too.
                if configuration.counter != nil, let previousValue {
                    #expect(
                        uuid > previousValue,
                        """
                        '\(uuid.uuidString)' not greater than previous UUID '\(previousValue.uuidString)' \
                        for \(configuration)
                        """
                    )
                }

                previousValue = uuid
            }
        }
    }
}

@Suite("UUIDVersion+v7Tests")
struct UUIDVersionV7ConfigurationTests {
    private let fixedLengthCounterState: FixedLengthCounterState
    private let monotonicRandomCounterState: MonotonicRandomCounterState
    private let mockRandomNumberGenerator: MockRandomNumberGenerator
    private let mockTimestampService: MockTimestampService

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    init() throws {
        let date = try Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse("2022-02-22T19:22:22.123Z")

        mockTimestampService = MockTimestampService(
            timestampValue: Timestamp(
                milliseconds: date.millisecondsSince1970,
                fraction: 1870
            )
        )
        self.mockRandomNumberGenerator = .mock(
            byteValues: [0x15, 0xac, 0x72],
            // Adding all the bytes needed for any of the tests so each test doesn't need to set this up themselves.
            bytesSizeValues: Array(0x00...0x6f),
            ofSizeUInt16Values: [0x0000, 0x0987]
        )
        self.fixedLengthCounterState = FixedLengthCounterState(
            cache: nil,
            randomNumberGenerator: mockRandomNumberGenerator
        )
        self.monotonicRandomCounterState = MonotonicRandomCounterState(
            cache: [:],
            randomNumberGenerator: mockRandomNumberGenerator
        )
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func withIncreasedClockPrecision() {
        let uuid = UUID.v7(
            configuration: .withIncreasedClockPrecision,
            fixedLengthCounterState: fixedLengthCounterState,
            monotonicRandomCounterState: monotonicRandomCounterState,
            randomNumberGenerator: mockRandomNumberGenerator,
            sleepService: .mock(),
            timestampService: mockTimestampService
        )

        #expect(uuid.uuidString == "017F22E2-7A2B-774E-8001-020304050607")
    }

    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    enum CounterArgument: CaseIterable {
        case fixedLength
        case increasedClockPrecisionAndFixedLength
        case increasedClockPrecisionAndMonotonicRandom
        case monotonicRandom

        var configuration: Configuration {
            switch self {
            case .fixedLength: .with(counter: .fixedLength)
            case .increasedClockPrecisionAndFixedLength: .withIncreasedClockPrecision(counter: .fixedLength)
            case .increasedClockPrecisionAndMonotonicRandom: .withIncreasedClockPrecision(counter: .monotonicRandom)
            case .monotonicRandom: .with(counter: .monotonicRandom)
            }
        }

        var expectedResults: (String, String, String, String, String) {
            switch self {
            case .fixedLength:
                (
                    "017F22E2-7A2B-7000-8001-020304050607",
                    "017F22E2-7A2B-7001-8809-0A0B0C0D0E0F",
                    "017F22E2-7A2B-7002-9011-121314151617",
                    "017F22E2-7A2B-7003-9819-1A1B1C1D1E1F",
                    "017F22E2-7A2C-7987-A021-222324252627",
                )
            case .increasedClockPrecisionAndFixedLength:
                (
                    "017F22E2-7A2B-774E-8000-000102030405",
                    "017F22E2-7A2B-774E-8001-060708090A0B",
                    "017F22E2-7A2B-774E-8002-0C0D0E0F1011",
                    "017F22E2-7A2B-774E-8003-121314151617",
                    "017F22E2-7A2C-774E-8987-18191A1B1C1D",
                )
            case .increasedClockPrecisionAndMonotonicRandom:
                (
                    "017F22E2-7A2B-774E-8001-020304050607",
                    "017F22E2-7A2B-774E-8001-020304050715",
                    "017F22E2-7A2B-774E-8001-0203040508AC",
                    "017F22E2-7A2B-774E-8001-020304050972",
                    "017F22E2-7A2C-774E-8809-0A0B0C0D0E0F",
                )
            case .monotonicRandom:
                (
                    "017F22E2-7A2B-7001-8203-040506070809",
                    "017F22E2-7A2B-7001-8203-040506070915",
                    "017F22E2-7A2B-7001-8203-040506070AAC",
                    "017F22E2-7A2B-7001-8203-040506070B72",
                    "017F22E2-7A2C-7A0B-8C0D-0E0F10111213",
                )
            }
        }

        var expectedTimestampWait: (millisecondsSince1970: UInt64, fractionNanoseconds: UInt16) {
            switch self {
            case .fixedLength, .monotonicRandom:
                (1_645_557_742_123, 0)
            case .increasedClockPrecisionAndFixedLength, .increasedClockPrecisionAndMonotonicRandom:
                (1_645_557_742_123, 1870)
            }
        }
    }

    @Test(arguments: CounterArgument.allCases)
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    func counter(_ argument: CounterArgument) {
        func new() -> UUID {
            .v7(
                configuration: argument.configuration,
                fixedLengthCounterState: fixedLengthCounterState,
                monotonicRandomCounterState: monotonicRandomCounterState,
                randomNumberGenerator: mockRandomNumberGenerator,
                sleepService: .mock(),
                timestampService: mockTimestampService
            )
        }

        var currentValue = new()
        var previousValue = currentValue

        #expect(currentValue.uuidString == argument.expectedResults.0)

        // Then the following calls with the same time stamp increment the counter then generate more random values.

        currentValue = new()
        #expect(currentValue.uuidString == argument.expectedResults.1)
        #expect(previousValue < currentValue)
        previousValue = currentValue

        currentValue = new()
        #expect(currentValue.uuidString == argument.expectedResults.2)
        #expect(previousValue < currentValue)
        previousValue = currentValue

        currentValue = new()
        #expect(currentValue.uuidString == argument.expectedResults.3)
        #expect(previousValue < currentValue)
        previousValue = currentValue

        // New timestamp gets a new random counter value
        mockTimestampService.incrementMockTimestamp()

        currentValue = new()
        #expect(currentValue.uuidString == argument.expectedResults.4)
        #expect(previousValue < currentValue)
    }

    @Test(arguments: CounterArgument.allCases)
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func counterWaitsForNextTimestampAtMaxValue(_ argument: CounterArgument) async {
        let sleepLength = await withCheckedContinuation { continuation in
            let mockRandomNumberGenerator = MockRandomNumberGenerator.mockWithMaxValues()
            let fixedLengthCounterState = FixedLengthCounterState(
                cache: nil,
                randomNumberGenerator: mockRandomNumberGenerator
            )
            let monotonicRandomCounterState = MonotonicRandomCounterState(
                cache: [:],
                randomNumberGenerator: mockRandomNumberGenerator
            )

            let mockSleepService = MockSleepService {
                // Make sure to increment the timestamp to avoid this immediately getting called again.
                // As the system will call to create a new UUID right after this "sleep".
                mockTimestampService.incrementMockTimestamp()
                continuation.resume(returning: (millisecondsSince1970: $0, fractionNanoseconds: $1))
            }

            func new() -> UUID {
                .v7(
                    configuration: argument.configuration,
                    fixedLengthCounterState: fixedLengthCounterState,
                    monotonicRandomCounterState: monotonicRandomCounterState,
                    randomNumberGenerator: mockRandomNumberGenerator,
                    sleepService: mockSleepService,
                    timestampService: mockTimestampService
                )
            }

            // For this test we don't care about the results, just that the system slept to wait
            // for the next timestamp value.
            _ = new()

            // We trigger the first one with the max values, then we expect this second call to trigger the sleep.
            _ = new()
        }

        let expectedTimestampWait = argument.expectedTimestampWait
        #expect(sleepLength.millisecondsSince1970 == expectedTimestampWait.millisecondsSince1970)
        #expect(sleepLength.fractionNanoseconds == expectedTimestampWait.fractionNanoseconds)
    }

    /// Sanity test that the real sleep logic does not take a long time.
    ///
    /// Disabled if WASM due to issues with `Task.sleep(for:)`
    @Test(.disabled(if: isWasm), arguments: CounterArgument.allCases)
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func waitingForNextTimestampShouldBeVerySmall(_ argument: CounterArgument) async throws {
        try await withThrowingTaskGroup { group in
            // real action task
            group.addTask {
                await withCheckedContinuation { continuation in
                    let mockRandomNumberGenerator = MockRandomNumberGenerator.mockWithMaxValues()
                    let fixedLengthCounterState = FixedLengthCounterState(
                        cache: nil,
                        randomNumberGenerator: mockRandomNumberGenerator
                    )
                    let monotonicRandomCounterState = MonotonicRandomCounterState(
                        cache: [:],
                        randomNumberGenerator: mockRandomNumberGenerator
                    )

                    let wrappedSleepService = WrappedSleepService(wrapped: .default) {
                        // Make sure to increment the timestamp to avoid this immediately getting called again.
                        // As the system will call to create a new UUID right after this "sleep".
                        mockTimestampService.incrementMockTimestamp()
                        continuation.resume()
                    }

                    func new() -> UUID {
                        .v7(
                            configuration: argument.configuration,
                            fixedLengthCounterState: fixedLengthCounterState,
                            monotonicRandomCounterState: monotonicRandomCounterState,
                            randomNumberGenerator: mockRandomNumberGenerator,
                            sleepService: wrappedSleepService,
                            timestampService: mockTimestampService
                        )
                    }

                    // For this test we don't care about the results, just that the system slept to wait
                    // for the next timestamp value.
                    _ = new()

                    // We trigger the first one with the max values, then we expect this second call to trigger the sleep.
                    _ = new()
                }
            }

            // timeout task to make sure the real sleep is not taking too long.
            group.addTask {
                // We are just picking a low value that will hopefully not be flaky when running in CI.
                try await Task.sleep(for: .milliseconds(10))
                throw TimeoutError()
            }

            // Await for the first group to return, if it is the timeout then it will throw.
            try await group.first(where: { _ in true })
        }
    }

    @Test(arguments: [true, false])
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func timestampsAlwaysIncrement(withIncreasedClockPrecision: Bool) throws {
        func new() -> UUID {
            .v7(
                configuration: withIncreasedClockPrecision ? .withIncreasedClockPrecision : .default,
                fixedLengthCounterState: fixedLengthCounterState,
                monotonicRandomCounterState: monotonicRandomCounterState,
                randomNumberGenerator: mockRandomNumberGenerator,
                sleepService: .mock(),
                timestampService: mockTimestampService
            )
        }

        let strategy = Date.ISO8601FormatStyle(includingFractionalSeconds: true)

        let subMillisecondIncrement: UInt16 = withIncreasedClockPrecision ? 1 : 0
        let dates: [Date] = try [
            // Initial
            "2022-02-22T19:22:22.123Z",
            // Increment sub-millisecond, date same as above because it will be incremented via a different field.
            withIncreasedClockPrecision ? "2022-02-22T19:22:22.123Z" : nil,
            // Increment millisecond
            "2022-02-22T19:22:22.124Z",
            // Increment second
            "2022-02-22T19:22:23.124Z",
            // Increment minute
            "2022-02-22T19:23:23.124Z",
            // Increment hour
            "2022-02-22T20:23:23.124Z",
            // Increment day
            "2022-02-23T20:23:23.124Z",
            // Increment month
            "2022-03-23T20:23:23.124Z",
            // Increment year
            "2023-03-23T20:23:23.124Z",
            // Increment 10 years
            "2033-03-23T20:23:23.124Z",
            // Increment 100 years
            "2133-03-23T20:23:23.124Z",
            // Increment 1000 years
            "3133-03-23T20:23:23.124Z",
        ].compactMap { (date: String?) in
            try date.map {
                try strategy.parse($0)
            }
        }

        // Lets do the initial one manually
        mockTimestampService.setMock(
            milliseconds: dates[0].millisecondsSince1970,
            fraction: 0
        )

        var results: [UUID] = [new()]

        mockTimestampService.setMock(
            milliseconds: dates[0].millisecondsSince1970,
            fraction: subMillisecondIncrement
        )

        for date in dates.dropFirst() {
            mockTimestampService.setMock(milliseconds: date.millisecondsSince1970)
            let newValue = new()

            // Check that the new date is always greater than the previous ones.
            for previousResult in results {
                #expect(previousResult.uuidString < newValue.uuidString, "for '\(strategy.format(date))'")
            }

            results.append(newValue)
        }
    }
}

/// Wraps the input SleepService which does get called, but completion handler gets called after the wrapped object finishes.
final class WrappedSleepService: SleepService {
    private let wrapped: any SleepService
    private let completionHandler: @Sendable () -> Void

    init(
        wrapped: any SleepService,
        completionHandler: @Sendable @escaping () -> Void
    ) {
        self.completionHandler = completionHandler
        self.wrapped = wrapped
    }

    func waitUntilNextTimestamp(millisecondsSince1970: UInt64, fractionNanoseconds: UInt16) {
        wrapped.waitUntilNextTimestamp(
            millisecondsSince1970: millisecondsSince1970,
            fractionNanoseconds: fractionNanoseconds
        )
        completionHandler()
    }
}
