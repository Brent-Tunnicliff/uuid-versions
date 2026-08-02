// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
final class DefaultTimestampService: TimestampService {
    static let shared = DefaultTimestampService()

    private let anchorUnixNanoseconds: UInt64
    private let clock: AnyClock<Duration>
    private let anchorInstant: AnyClock<Duration>.Instant

    convenience init() {
        self.init(
            clock: ContinuousClock(),
            dateService: .system
        )
    }

    init<ClockType>(
        clock: ClockType,
        dateService: any DateService
    ) where ClockType: Clock, ClockType.Duration == Duration {
        // If we try to multiply the Double by 1_000_000_000 all at once it looses accuracy and the final timestamp is slightly off.
        // Since Date cannot be reliable sub milliseconds anyway, lets just convert to UInt64 at the milliseconds to get rid of any additional
        // fractions and only rely on the clock for sub-millisecond values.
        // Note, this means the timestamp won't be representing the real system time for sub-milliseconds, but it will stay consistent for each UUID generated.
        let anchorUnixMilliseconds = UInt64(dateService.now.timeIntervalSince1970 * 1_000)
        self.anchorUnixNanoseconds = anchorUnixMilliseconds * 1_000_000
        self.clock = AnyClock(clock)
        self.anchorInstant = self.clock.now
    }

    func getTimestamp() -> Timestamp {
        // Date is not accurate enough to properly handle fractional digits beyond milliseconds.
        let duration = anchorInstant.duration(to: clock.now)

        // We assume neither of these are negative.
        precondition(duration.components.seconds >= 0)
        precondition(duration.components.attoseconds >= 0)

        let elapsedNanoseconds =
            UInt64(duration.components.seconds) * 1_000_000_000
            + UInt64(duration.components.attoseconds / 1_000_000_000)

        let nanoseconds = anchorUnixNanoseconds + elapsedNanoseconds
        let milliseconds = nanoseconds / 1_000_000
        let fraction = UInt16(((nanoseconds % 1_000_000) * 4096) / 1_000_000)
        return Timestamp(milliseconds: milliseconds, fraction: fraction)
    }
}

// I just copied this from <https://github.com/pointfreeco/swift-clocks/blob/87d76a134fdb5a902e45f61f61d19d191c28ba7d/Sources/Clocks/AnyClock.swift>.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
private struct AnyClock<Duration>: Clock where Duration: DurationProtocol & Hashable {
    struct Instant: InstantProtocol {
        fileprivate let offset: Duration

        func advanced(by duration: Duration) -> Self {
            Self(offset: offset + duration)
        }

        func duration(to other: Self) -> Duration {
            other.offset - offset
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.offset < rhs.offset
        }
    }

    private let _minimumResolution: @Sendable () -> Duration
    private let _now: @Sendable () -> Instant
    private let _sleep: @Sendable (Instant, Duration?) async throws -> Void

    init<ClockType>(_ clock: ClockType) where ClockType: Clock, ClockType.Instant.Duration == Duration {
        let start = clock.now
        self._now = { Instant(offset: start.duration(to: clock.now)) }
        self._minimumResolution = { clock.minimumResolution }
        self._sleep = { try await clock.sleep(until: start.advanced(by: $0.offset), tolerance: $1) }
    }

    var minimumResolution: Duration {
        self._minimumResolution()
    }

    var now: Instant {
        self._now()
    }

    func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws {
        try await self._sleep(deadline, tolerance)
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension AnyClock: Sendable where Duration: Sendable {}
