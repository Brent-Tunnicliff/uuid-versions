// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import UUIDv7

@available(iOS 16.0, *)
final class MockClock: Clock, @unchecked Sendable {
    private var _now: Instant
    var now: Instant {
        get {
            lock.withLock { _now }
        }
        set {
            lock.withLock { _now = newValue }
        }
    }

    let minimumResolution: Duration

    private let lock = Lock()

    init(nowValue: Duration) {
        self._now = Instant(value: nowValue)
        self.minimumResolution = Duration(secondsComponent: 0, attosecondsComponent: 0)
    }

    func sleep(until deadline: Instant, tolerance: Duration?) async throws {}
}

@available(iOS 16.0, *)
extension MockClock {
    struct Instant: InstantProtocol {
        typealias Duration = Swift.Duration
        let value: Duration

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.value < rhs.value
        }

        func advanced(by duration: Duration) -> MockClock.Instant {
            Instant(value: value + duration)
        }

        func duration(to other: MockClock.Instant) -> Duration {
            other.value - value
        }
    }
}
