// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

struct DefaultSleepServiceTests {
    enum Argument: CaseIterable {
        case incrementMicrosecond
        case incrementMillisecond

        var dates: (initial: String, later: String) {
            switch self {
            case .incrementMicrosecond:
                (
                    "2000-01-01T00:00:00.000Z",
                    "2000-01-01T00:00:00.000Z",
                )
            case .incrementMillisecond:
                (
                    "2000-01-01T00:00:00.000Z",
                    "2000-01-01T00:00:00.100Z",
                )
            }
        }

        var fractionNanoseconds: (initial: UInt16, later: UInt16) {
            switch self {
            case .incrementMicrosecond: (0, 100)
            case .incrementMillisecond: (0, 0)
            }
        }
    }

    @Test(arguments: Argument.allCases)
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func waitUntilNextTimestamp(_ argument: Argument) async throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let (initialDateValue, laterDateValue) = argument.dates
        let initialDate = try #require(formatter.date(from: initialDateValue))
        let laterDate = try #require(formatter.date(from: laterDateValue))

        let (initialFractionNanoseconds, laterFractionNanoseconds) = argument.fractionNanoseconds

        let mockDateService = Self.MockDateService(
            fractionNanosecondsValues: [
                initialFractionNanoseconds,
                initialFractionNanoseconds,
                initialFractionNanoseconds,
                initialFractionNanoseconds,
                initialFractionNanoseconds,
                laterFractionNanoseconds,
            ],
            nowValues: [initialDate, initialDate, initialDate, initialDate, initialDate, laterDate]
        )

        let sleepService = DefaultSleepService(dateService: mockDateService)

        try await withThrowingTaskGroup { group in
            group.addTask {
                try await Task.sleep(for: .seconds(1))
                throw TimeoutError()
            }

            group.addTask {
                sleepService.waitUntilNextTimestamp(
                    millisecondsSince1970: 946_684_800_000,
                    fractionNanoseconds: 0
                )
            }

            // Await for the first group to return, if it is the timeout then it will throw.
            try await group.first(where: { _ in true })
            group.cancelAll()
        }
    }

    /// Sanity test that the real wait does not take longer than expected.
    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func sanityTest() async throws {
        let sleepService: any SleepService = .default
        let millisecondsSince1970 = Date().millisecondsSince1970

        try await withThrowingTaskGroup { group in
            group.addTask {
                sleepService.waitUntilNextTimestamp(
                    millisecondsSince1970: millisecondsSince1970,
                    fractionNanoseconds: .max
                )
            }

            group.addTask {
                try await Task.sleep(for: .milliseconds(2))
                throw TimeoutError()
            }

            // Await for the first group to return, if it is the timeout then it will throw.
            try await group.first(where: { _ in true })
            group.cancelAll()
        }
    }
}

extension DefaultSleepServiceTests {
    private final class MockDateService: DateService, @unchecked Sendable {
        private let lock = NSLock()

        private var fractionNanosecondsValues: [UInt16]
        private var nowValues: [Date]

        init(
            fractionNanosecondsValues: [UInt16],
            nowValues: [Date]
        ) {
            self.fractionNanosecondsValues = fractionNanosecondsValues
            self.nowValues = nowValues
        }

        func fractionNanoseconds() -> UInt16 {
            lock.withLock {
                fractionNanosecondsValues.removeFirst()
            }
        }

        func now() -> Date {
            lock.withLock {
                nowValues.removeFirst()
            }
        }
    }
}
