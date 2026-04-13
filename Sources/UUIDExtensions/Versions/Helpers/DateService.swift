// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

protocol DateService: Sendable {
    func now() -> Date
    func fractionNanoseconds() -> UInt16
}

extension DateService where Self == SystemDateService {
    @inlinable
    @inline(__always)
    static var `default`: Self {
        .shared
    }
}

struct SystemDateService: DateService {
    fileprivate static let shared = SystemDateService()

    private let anchorUnixNanoseconds: UInt64
    private let clockWrapper: any ClockWrapper
    private let nowSource: @Sendable () -> Date

    init() {
        self.init(
            clockWrapper: ContinuousClockWrapper(),
            nowSource: { Date() }
        )
    }

    init(
        clockWrapper: any ClockWrapper,
        nowSource: @Sendable @escaping () -> Date
    ) {
        // If we try to multiply the Double by 1_000_000_000 all at once it looses accuracy and the final timestamp is slightly off.
        // Since Date cannot be reliable sub milliseconds anyway, lets just convert to UInt64 at the milliseconds to get rid of any additional
        // fractions and only rely on the clockWrapper for sub-millisecond values.
        // Note, this means the timestamp won't be representing the real system time for sub-milliseconds, but it will stay consistent for each UUID generated.
        let anchorUnixMilliseconds = UInt64(nowSource().timeIntervalSince1970 * 1_000)
        self.anchorUnixNanoseconds = anchorUnixMilliseconds * 1_000_000
        self.clockWrapper = clockWrapper
        self.nowSource = nowSource
    }

    /// Creating a new date object might be the slowest part of UUID's being generated.
    ///
    /// A more performant way to handle this is to keep a cache of the current date object and have an
    /// async task to keep refreshing it every X amount of time, then the cached value is referenced each time.
    /// But that is way more complex than we need. That would only be worthwhile on **very** heavy workflows
    /// that probably should have their own custom implementation built for performance anyway.
    func now() -> Date {
        nowSource()
    }

    func fractionNanoseconds() -> UInt16 {
        let nanoseconds: UInt64

        // Date is not accurate enough to properly handle fractional digits beyond milliseconds,
        // plus initialising a Date object slows this process down as it might take hundreds of nanoseconds (?).
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            let duration = clockWrapper.durationSinceAnchor
            let durationSecondsAsNanoseconds = duration.components.seconds * 1_000_000_000
            let durationAttosecondsAsNanoseconds = duration.components.attoseconds / 1_000_000_000
            let elapsedNanoseconds = UInt64(durationSecondsAsNanoseconds + durationAttosecondsAsNanoseconds)
            nanoseconds = anchorUnixNanoseconds + elapsedNanoseconds
        } else {
            // In the rare cases that we don't have access to `ContinuousClock` then this is good enough.
            // This should only happen on old Darwin based platform OS versions.
            nanoseconds = UInt64(now().timeIntervalSince1970 * 1_000_000_000)
        }

        let fraction = nanoseconds % 1_000_000
        return UInt16((fraction * 4096) / 1_000_000)
    }
}

/// Wrapper of `Clock` to make using it simpler as not all OS versions support it.
///
/// A messy implementation but it works for what we need.
protocol ClockWrapper: Sendable {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    var durationSinceAnchor: Duration { get }
}

/// Wrapper of `ContinuousClock` to make using it simpler as not all OS versions support it.
///
/// A messy implementation but it works for what we need.
private struct ContinuousClockWrapper: ClockWrapper {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    var durationSinceAnchor: ContinuousClock.Duration {
        guard let clock = clock as? ContinuousClock else {
            preconditionFailure("Unexpected nil clock")
        }

        guard let anchorInstant = anchorInstant as? ContinuousClock.Instant else {
            preconditionFailure("Unexpected nil anchorInstant")
        }

        return anchorInstant.duration(to: clock.now)
    }

    private let clock: (any Sendable)?
    private let anchorInstant: (any Sendable)?

    init() {
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            let clock = ContinuousClock()
            self.clock = clock
            self.anchorInstant = clock.now
        } else {
            self.clock = nil
            self.anchorInstant = nil
        }
    }
}
