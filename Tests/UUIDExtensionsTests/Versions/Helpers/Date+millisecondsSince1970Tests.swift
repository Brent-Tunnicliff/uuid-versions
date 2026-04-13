// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

@Suite("Date+millisecondsSince1970Tests")
struct DateMillisecondsSince1970Tests {
    @Test()
    func millisecondsSince1970() throws {
        let dateValue = "2000-01-01T00:00:00.1234567Z"

        // Using `DateFormatter` as `ISO8601DateFormatter` does not handle enough fraction digits for this test.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"

        let date = try #require(formatter.date(from: dateValue))

        // Sanity check that the `timeIntervalSince1970` is the expected value.
        #expect(date.timeIntervalSince1970 == 946_684_800.123)

        #expect(date.millisecondsSince1970 == 946_684_800_123)
    }
}
