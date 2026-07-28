// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

struct MockDateService: DateService {
    let now: Date

    init() throws {
        // Example date from [Appendix A. Test Vectors](https://www.rfc-editor.org/rfc/rfc9562#name-test-vectors).
        let date = try Date.ISO8601FormatStyle().parse("2022-02-22T19:22:22Z")
        self.init(now: date)
    }

    init(now: Date) {
        self.now = now
    }
}

extension DateService where Self == MockDateService {
    static func mock() throws -> Self {
        try Self()
    }
}
