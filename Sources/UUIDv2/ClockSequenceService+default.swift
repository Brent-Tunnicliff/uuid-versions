// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import UUIDv1

extension ClockSequenceService where Self == DefaultClockSequenceService {
    static var `default`: Self {
        .shared
    }
}

extension DefaultClockSequenceService {
    // Needs a different increment to UUIDv1 as it is represented in a smaller space.
    static let shared = DefaultClockSequenceService(clockSequenceIncrement: 0x0100)
}
