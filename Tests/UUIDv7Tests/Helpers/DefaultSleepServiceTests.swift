// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
import Testing
@testable import UUIDv7

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

struct DefaultSleepServiceTests {
    enum Argument: CaseIterable {
        case incrementMicrosecond
        case incrementMillisecond

        var laterTimestamp: Timestamp {
            switch self {
            case .incrementMicrosecond: Timestamp(milliseconds: 1, fraction: 0)
            case .incrementMillisecond: Timestamp(milliseconds: 0, fraction: 1)
            }
        }
    }

    @Test(arguments: Argument.allCases)
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func waitUntilNextTimestamp(_ argument: Argument) async throws {
        let initialTimestamp = Timestamp(milliseconds: 0, fraction: 0)
        let laterTimestamp = argument.laterTimestamp

        let mockTimestampService = Self.MockTimestampService(
            timestampValues: [
                initialTimestamp,
                initialTimestamp,
                initialTimestamp,
                initialTimestamp,
                initialTimestamp,
                laterTimestamp,
            ]
        )

        let sleepService = DefaultSleepService(timestampService: mockTimestampService)

        try await withThrowingTaskGroup { group in
            group.addTask {
                sleepService.waitUntilNextTimestamp(
                    millisecondsSince1970: 0,
                    fractionNanoseconds: 0
                )
            }

            group.addTask {
                try await Task.sleep(for: .seconds(1))
                throw TimeoutError()
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
    private final class MockTimestampService: TimestampService, @unchecked Sendable {
        private let lock = Lock()
        private var timestampValues: [Timestamp]

        init(timestampValues: [Timestamp]) {
            self.timestampValues = timestampValues
        }

        func getTimestamp() -> Timestamp {
            lock.withLock {
                timestampValues.removeFirst()
            }
        }
    }
}
