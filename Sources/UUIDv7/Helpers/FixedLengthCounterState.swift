// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

/// Shared state kept in memory and referenced while generating UUIDv7 values.
final class FixedLengthCounterState: @unchecked Sendable {
    static let shared = FixedLengthCounterState()
    typealias Cache = (key: StateKey, value: UInt16)?

    private var cache: Cache
    private let lock = Lock()
    private let maxSize: UInt16 = 0x0FFF
    private let randomNumberGenerator: any RandomNumberGenerator

    private convenience init() {
        self.init(
            cache: nil,
            randomNumberGenerator: .default
        )
    }

    init(
        cache: Cache,
        randomNumberGenerator: any RandomNumberGenerator
    ) {
        self.cache = cache
        self.randomNumberGenerator = randomNumberGenerator
    }

    func getFixedLengthCounter(timestamp: UInt64, fractionNanoseconds: UInt16) throws -> UInt16 {
        try lock.withLock {
            let key = StateKey(timestamp: timestamp, fractionNanoseconds: fractionNanoseconds)
            guard let element = cache, key <= element.key else {
                return cacheAndReturn(value: randomNumberGenerator.of(size: maxSize), for: key)
            }

            let matchingCounter = element.value

            guard matchingCounter < maxSize else {
                throw CounterAtMaxSizeError()
            }

            // We are allowed to increment by one because the remaining bits of the UUID are random.
            return cacheAndReturn(value: matchingCounter + 1, for: key)
        }
    }

    private func cacheAndReturn(value: UInt16, for key: StateKey) -> UInt16 {
        cache = (key, value)
        return value
    }
}
