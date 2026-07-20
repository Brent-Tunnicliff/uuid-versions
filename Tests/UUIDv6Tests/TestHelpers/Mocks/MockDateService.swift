// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

struct MockDateService: DateService {
    var now: Date

    init() {
        // Example date from [Appendix A. Test Vectors](https://www.rfc-editor.org/rfc/rfc9562#name-test-vectors).
        let exampleDate = "2022-02-22T19:22:22Z"
        guard let date = ISO8601DateFormatter().date(from: exampleDate) else {
            preconditionFailure("Unable to convert to date: \(exampleDate)")
        }

        self.init(now: date)
    }

    init(now: Date) {
        self.now = now
    }
}

extension DateService where Self == MockDateService {
    static func mock() -> Self {
        Self()
    }
}
