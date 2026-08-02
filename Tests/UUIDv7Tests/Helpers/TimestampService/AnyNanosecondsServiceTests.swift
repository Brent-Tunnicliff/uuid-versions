// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv7

struct AnyNanosecondsServiceTests {
    @Test
    func fractionNanosecondsReturnsWrappedValue() async throws {
        let mockTimestampService = MockTimestampService.mock()
        let anyTimestampService: AnyTimestampService = mockTimestampService.asAny()

        for value in [
            Timestamp(milliseconds: 1, fraction: 1),
            Timestamp(milliseconds: 1, fraction: 2),
            Timestamp(milliseconds: 2, fraction: 2),
            Timestamp(milliseconds: 3, fraction: 0),
        ] {
            mockTimestampService.setMock(timestamp: value)
            #expect(anyTimestampService.getTimestamp() == value)
        }
    }
}
