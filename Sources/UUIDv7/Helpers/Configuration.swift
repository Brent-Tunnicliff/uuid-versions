// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

// MARK: - V7Configuration

/// Configuration for the generating of UUID v7.
///
/// Documented in <https://www.rfc-editor.org/rfc/rfc9562#section-6.2>.
public struct Configuration {
    let counter: Counter?
    let increasedClockPrecision: Bool

    init(
        counter: Counter? = nil,
        increasedClockPrecision: Bool = false
    ) {
        self.counter = counter
        self.increasedClockPrecision = increasedClockPrecision
    }
}

extension Configuration {
    /// Default configuration without any optional additions.
    ///
    /// Generates with milliseconds in the most significant bits and random for the remaining.
    ///
    /// If multiple values are generated within the same millisecond there is no guarantee of order between them.
    /// If you need to guarantee the order, then recommend using ``with(counter:)`` instead.
    public static let `default` = Configuration()

    /// UUID will generate with an increased clock precision.
    ///
    /// Increased clock precision means using fractions of a millisecond in place of the random bits immediately following the timestamp.
    /// Based on method 3 <https://www.rfc-editor.org/rfc/rfc9562#section-6.2>.
    ///
    /// If multiple values are generated within the same millisecond there is no guarantee of order between them.
    /// If you need to guarantee the order, then recommend using ``withIncreasedClockPrecision(counter:)`` instead.
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    public static let withIncreasedClockPrecision = Configuration(
        increasedClockPrecision: true
    )

    /// UUID will generate with an increased clock precision and a counter.
    ///
    /// Increased clock precision means using fractions of a millisecond in place of the random bits immediately following the timestamp.
    /// Based on method 3 <https://www.rfc-editor.org/rfc/rfc9562#section-6.2>.
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    public static func withIncreasedClockPrecision(counter: Counter) -> Configuration {
        Configuration(counter: counter, increasedClockPrecision: true)
    }

    /// UUID will generate with a counter.
    public static func with(counter: Counter) -> Configuration {
        Configuration(counter: counter)
    }
}

// MARK: Hashable

extension Configuration: Hashable {}

// MARK: Sendable

extension Configuration: Sendable {}

// MARK: - Configuration.Counter

extension Configuration {
    /// Type of counter to use when generating a UUID.
    public struct Counter {
        let value: Value
    }
}

extension Configuration.Counter {
    /// UUID will generate with a fixed length counter.
    ///
    /// Fixed length Counter will use a random value for generating UUID, but if the time stamp is the same as previous it will instead increment the same counter value.
    ///
    /// Based on method 1 of <https://www.rfc-editor.org/rfc/rfc9562#section-6.2>.
    public static let fixedLength = Configuration.Counter(value: .fixedLength)

    /// UUID will generate with a monotonic random counter.
    ///
    /// Monotonic Random Counter makes sure that the random values are an increment of any previous generated with the same timestamp.
    ///
    /// Based on method 2 of <https://www.rfc-editor.org/rfc/rfc9562#section-6.2>.
    public static let monotonicRandom = Configuration.Counter(value: .monotonicRandom)
}

// MARK: Hashable

extension Configuration.Counter: Hashable {}

// MARK: Sendable

extension Configuration.Counter: Sendable {}

// MARK: - Configuration.Counter.Value

extension Configuration.Counter {
    enum Value {
        case fixedLength
        case monotonicRandom
    }
}

// MARK: Hashable

extension Configuration.Counter.Value: Hashable {}

// MARK: Sendable

extension Configuration.Counter.Value: Sendable {}
