// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

@Suite("UUIDVersion+v7Tests")
struct UUIDVersionV7Tests {
    private static let randA = 0xCC3
    private static let randB = (0b01 << 60) | 0x8_C4_DC_0C_0C_07_39_8F
    private let mockDateService = MockDateService()
    private let mockRandomNumberGenerator = MockRandomNumberGenerator(
        bytesValue: [
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
    private let generator: VersionSevenUUIDGenerator

    init() {
        self.generator = VersionSevenUUIDGenerator(
            configuration: .default,
            dateService: mockDateService,
            fixedLengthCounterState: VersionSevenUUIDGenerator.FixedLengthCounterState(
                randomNumberGenerator: mockRandomNumberGenerator
            ),
            monotonicRandomCounterState: VersionSevenUUIDGenerator.MonotonicRandomCounterState(
                randomNumberGenerator: mockRandomNumberGenerator
            ),
            randomNumberGenerator: mockRandomNumberGenerator,
            sleepService: MockSleepService()
        )
    }

    // https://www.rfc-editor.org/rfc/rfc9562#name-example-of-a-uuidv6-value
    @Test
    func matchesTheStandardExample() {
        let uuid = generator.new().uuidString
        #expect(uuid == "017F22E2-79B0-7CC3-98C4-DC0C0C07398F")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        let configurations: [V7Configuration] = [
            .default,
            .with(counter: .fixedLength),
            .with(counter: .monotonicRandom),
            .withIncreasedClockPrecision,
            .withIncreasedClockPrecision(counter: .fixedLength),
            .withIncreasedClockPrecision(counter: .monotonicRandom),
        ]

        for configuration in configurations {
            for _ in 0..<200 {
                let uuid = UUID(version: .v7(configuration: configuration)).uuidString.lowercased()

                // With the version and variant position we expect one of the following formats:
                //  - xxxxxxxx-xxxx-7xxx-8xxx-xxxxxxxxxxxx
                //  - xxxxxxxx-xxxx-7xxx-9xxx-xxxxxxxxxxxx
                //  - xxxxxxxx-xxxx-7xxx-axxx-xxxxxxxxxxxx
                //  - xxxxxxxx-xxxx-7xxx-bxxx-xxxxxxxxxxxx
                let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

                #expect(
                    uuid.wholeMatch(of: regex) != nil,
                    "'\(uuid)' does not match the expected UUIDv7 regex pattern"
                )
            }
        }
    }
}

@Suite("UUIDVersion+v7Tests")
struct UUIDVersionV7ConfigurationTests {
    private let mockDateService: MockDateService
    private let mockRandomNumberGenerator: MockRandomNumberGenerator
    private let mockSleepService = MockSleepService()

    init() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = try #require(formatter.date(from: "2022-02-22T19:22:22.1234567Z"))
        self.mockDateService = MockDateService(
            fractionNanosecondsValue: 1870,
            nowValue: date
        )
        self.mockRandomNumberGenerator = MockRandomNumberGenerator(
            // Adding all the bytes needed for any of the tests so each test doesn't need to set this up themselves.
            bytesValue: Array(0x00...0x2f),
            ofSizeUInt16: [0x0000, 0x0987],
            singleByteValues: [0x15, 0xac, 0x72]
        )
    }

    @Test
    func withIncreasedClockPrecision() {
        let generator = VersionSevenUUIDGenerator(
            configuration: .withIncreasedClockPrecision,
            dateService: mockDateService,
            fixedLengthCounterState: VersionSevenUUIDGenerator.FixedLengthCounterState(
                randomNumberGenerator: mockRandomNumberGenerator
            ),
            monotonicRandomCounterState: VersionSevenUUIDGenerator.MonotonicRandomCounterState(
                randomNumberGenerator: mockRandomNumberGenerator
            ),
            randomNumberGenerator: mockRandomNumberGenerator,
            sleepService: mockSleepService
        )

        #expect(generator.new().uuidString == "017F22E2-7A2B-774E-8001-020304050607")
    }

    enum CounterArgument: CaseIterable {
        case fixedLength
        case increasedClockPrecisionAndFixedLength
        case increasedClockPrecisionAndMonotonicRandom
        case monotonicRandom

        var configuration: V7Configuration {
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
                    "017F22E2-7E13-7987-A021-222324252627",
                )
            case .increasedClockPrecisionAndFixedLength:
                (
                    "017F22E2-7A2B-774E-8000-000102030405",
                    "017F22E2-7A2B-774E-8001-060708090A0B",
                    "017F22E2-7A2B-774E-8002-0C0D0E0F1011",
                    "017F22E2-7A2B-774E-8003-121314151617",
                    "017F22E2-7E13-774E-8987-18191A1B1C1D",
                )
            case .increasedClockPrecisionAndMonotonicRandom:
                (
                    "017F22E2-7A2B-774E-8001-020304050607",
                    "017F22E2-7A2B-774E-8001-020304050715",
                    "017F22E2-7A2B-774E-8001-0203040508AC",
                    "017F22E2-7A2B-774E-8001-020304050972",
                    "017F22E2-7E13-774E-8809-0A0B0C0D0E0F",
                )
            case .monotonicRandom:
                (
                    "017F22E2-7A2B-7001-8203-040506070809",
                    "017F22E2-7A2B-7001-8203-040506070915",
                    "017F22E2-7A2B-7001-8203-040506070AAC",
                    "017F22E2-7A2B-7001-8203-040506070B72",
                    "017F22E2-7E13-7A0B-8C0D-0E0F10111213",
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
        let generator = VersionSevenUUIDGenerator(
            configuration: argument.configuration,
            dateService: mockDateService,
            fixedLengthCounterState: VersionSevenUUIDGenerator.FixedLengthCounterState(
                randomNumberGenerator: mockRandomNumberGenerator
            ),
            monotonicRandomCounterState: VersionSevenUUIDGenerator.MonotonicRandomCounterState(
                randomNumberGenerator: mockRandomNumberGenerator
            ),
            randomNumberGenerator: mockRandomNumberGenerator,
            sleepService: mockSleepService
        )

        var currentValue = generator.new()
        var previousValue = currentValue

        #expect(currentValue.uuidString == argument.expectedResults.0)

        // Then the following calls with the same time stamp increment the counter then generate more random values.

        currentValue = generator.new()
        #expect(currentValue.uuidString == argument.expectedResults.1)
        #expect(previousValue < currentValue)
        previousValue = currentValue

        currentValue = generator.new()
        #expect(currentValue.uuidString == argument.expectedResults.2)
        #expect(previousValue < currentValue)
        previousValue = currentValue

        currentValue = generator.new()
        #expect(currentValue.uuidString == argument.expectedResults.3)
        #expect(previousValue < currentValue)
        previousValue = currentValue

        // New timestamp gets a new random counter value
        mockDateService.nowValue = mockDateService.nowValue.advanced(by: 1)

        currentValue = generator.new()
        #expect(currentValue.uuidString == argument.expectedResults.4)
        #expect(previousValue < currentValue)
    }

    @Test(arguments: CounterArgument.allCases)
    func counterWaitsForNextTimestampAtMaxValue(_ argument: CounterArgument) async {
        let sleepLength = await withCheckedContinuation { continuation in
            let mockRandomNumberGenerator = MockRandomNumberGenerator.maxValues

            mockSleepService.waitUntilNextTimestampCompletionHandler = {
                // Make sure to increment the date to avoid this immediately getting called again.
                // As the system will call to create a new UUID right after this "sleep".
                mockDateService.nowValue = mockDateService.nowValue.advanced(by: 1)
                continuation.resume(returning: (millisecondsSince1970: $0, fractionNanoseconds: $1))
            }

            let generator = VersionSevenUUIDGenerator(
                configuration: argument.configuration,
                dateService: mockDateService,
                fixedLengthCounterState: VersionSevenUUIDGenerator.FixedLengthCounterState(
                    randomNumberGenerator: mockRandomNumberGenerator
                ),
                monotonicRandomCounterState: VersionSevenUUIDGenerator.MonotonicRandomCounterState(
                    randomNumberGenerator: mockRandomNumberGenerator
                ),
                randomNumberGenerator: mockRandomNumberGenerator,
                sleepService: mockSleepService
            )

            // For this test we don't care about the results, just that the system slept to wait
            // for the next timestamp value.
            _ = generator.new()

            // We trigger the first one with the max values, then we expect this second call to trigger the sleep.
            _ = generator.new()
        }

        let expectedTimestampWait = argument.expectedTimestampWait
        #expect(sleepLength.millisecondsSince1970 == expectedTimestampWait.millisecondsSince1970)
        #expect(sleepLength.fractionNanoseconds == expectedTimestampWait.fractionNanoseconds)
    }

    /// Sanity test that the real sleep logic does not take a long time.
    @Test(arguments: CounterArgument.allCases)
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func waitingForNextTimestampShouldBeVerySmall(_ argument: CounterArgument) async throws {
        try await withThrowingTaskGroup { group in
            // timeout task
            group.addTask {
                // We are just picking a low value that will hopefully not be flaky when running in CI.
                try await Task.sleep(for: .milliseconds(10))
                throw TimeoutError()
            }

            // real action task
            group.addTask {
                await withCheckedContinuation { continuation in
                    let mockRandomNumberGenerator = MockRandomNumberGenerator.maxValues

                    let wrappedSleepService = WrappedSleepService(wrapped: .default) {
                        // Make sure to increment the date to avoid this immediately getting called again.
                        // As the system will call to create a new UUID right after this "sleep".
                        mockDateService.nowValue = mockDateService.nowValue.advanced(by: 1)
                        continuation.resume()
                    }

                    let generator = VersionSevenUUIDGenerator(
                        configuration: argument.configuration,
                        dateService: mockDateService,
                        fixedLengthCounterState: VersionSevenUUIDGenerator.FixedLengthCounterState(
                            randomNumberGenerator: mockRandomNumberGenerator
                        ),
                        monotonicRandomCounterState: VersionSevenUUIDGenerator.MonotonicRandomCounterState(
                            randomNumberGenerator: mockRandomNumberGenerator
                        ),
                        randomNumberGenerator: mockRandomNumberGenerator,
                        sleepService: wrappedSleepService
                    )

                    // For this test we don't care about the results, just that the system slept to wait
                    // for the next timestamp value.
                    _ = generator.new()

                    // We trigger the first one with the max values, then we expect this second call to trigger the sleep.
                    _ = generator.new()
                }
            }

            // Await for the first group to return, if it is the timeout then it will throw.
            try await group.first(where: { _ in true })
            group.cancelAll()
        }
    }
}

extension MockRandomNumberGenerator {
    /// Initially set all as max.
    static var maxValues: MockRandomNumberGenerator {
        MockRandomNumberGenerator(
            bytesValue: (0..<40).map { _ in UInt8.max },
            clockSequence: UInt16.max,
            int48: UInt64.max,
            ofSizeUInt16: (0..<40).map { _ in UInt16.max },
            singleByteValues: (0..<40).map { _ in UInt8.max }
        )
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
