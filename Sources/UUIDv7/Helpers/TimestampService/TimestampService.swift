// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

protocol TimestampService: Sendable {
    func getTimestamp() -> Timestamp
}

extension TimestampService where Self == AnyTimestampService {
    static var `default`: Self {
        .shared
    }
}
