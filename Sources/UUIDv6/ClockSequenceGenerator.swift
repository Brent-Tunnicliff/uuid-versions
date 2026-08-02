// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import UUIDv1

protocol ClockSequenceGenerator: Sendable {
    func generateClockSequence() -> UInt16
}

extension ClockSequenceGenerator where Self == DefaultClockSequenceGenerator {
    static var `default`: Self {
        .shared
    }
}

final class DefaultClockSequenceGenerator: ClockSequenceGenerator {
    static let shared = DefaultClockSequenceGenerator()

    func generateClockSequence() -> UInt16 {
        .randomClockSequence
    }
}
