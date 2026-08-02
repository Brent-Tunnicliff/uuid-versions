// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv7

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

@Suite("Date+millisecondsSince1970Tests")
struct DateMillisecondsSince1970Tests {
    @Test
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func millisecondsSince1970() throws {
        let strategy = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        let date = try strategy.parse("2000-01-01T00:00:00.123Z")

        // Sanity check that the `timeIntervalSince1970` is the expected value.
        #expect(date.timeIntervalSince1970 == 946_684_800.123)

        #expect(date.millisecondsSince1970 == 946_684_800_123)
    }
}
