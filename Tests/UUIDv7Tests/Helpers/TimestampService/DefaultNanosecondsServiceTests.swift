// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv7

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

struct DefaultNanosecondsServiceTests {
    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func getTimestamp() async throws {
        let clock = MockClock(nowValue: .zero)
        let date = try #require(ISO8601DateFormatter().date(from: "2022-02-22T19:22:22Z"))
        let timestampService = DefaultTimestampService(
            clock: clock,
            dateService: .mock(now: date),
        )

        clock.now = clock.now.advanced(by: .microseconds(222))

        let result = timestampService.getTimestamp()
        #expect(result.milliseconds == 1645557_742_000)
        #expect(result.fraction == 909)
    }
}
