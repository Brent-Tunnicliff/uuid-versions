// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

extension UInt16 {
    package static var randomClockSequence: UInt16 {
        random(in: 0..<16384)
    }
}
