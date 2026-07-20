// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

/// Shared state kept in memory and referenced while generating UUIDv7 values.
final class MonotonicRandomCounterState: @unchecked Sendable {
    static let shared = MonotonicRandomCounterState()

    // We want different size values to maintain seperate caches.
    // This way the consumer can create both with and without increased precision and without them affecting each other.
    typealias Cache = [Int: (key: StateKey, value: [UInt8])]

    private var cache: Cache
    private let lock = Lock()
    private let randomNumberGenerator: any RandomNumberGenerator

    private convenience init() {
        self.init(
            cache: [:],
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

    func getMonotonicRandomCounter(
        timestamp: UInt64,
        fractionNanoseconds: UInt16,
        size: Int
    ) throws(CounterAtMaxSizeError) -> [UInt8] {
        do {
            return try lock.withLock {
                let key = StateKey(timestamp: timestamp, fractionNanoseconds: fractionNanoseconds)
                guard let element = cache[size], key <= element.key else {
                    return cacheAndReturn(
                        value: randomNumberGenerator.bytes(size: size),
                        for: key,
                        size: size
                    )
                }

                // Increment the bytes
                guard let newValue = incrementingBigEndian(bytes: element.value) else {
                    throw CounterAtMaxSizeError()
                }

                return cacheAndReturn(value: newValue, for: key, size: size)
            }
        } catch let error as CounterAtMaxSizeError {
            throw error
        } catch {
            preconditionFailure("Unexpected error: '\(error)'")
        }
    }

    private func cacheAndReturn(value: [UInt8], for key: StateKey, size: Int) -> [UInt8] {
        cache[size] = (key, value)
        return value
    }

    private func incrementingBigEndian(bytes: [UInt8]) -> [UInt8]? {
        var bytes = bytes
        // We want to skip if:
        //   - we are in the last index, because we need the next value to be difficult to guess.
        //   - or if the value is at max.
        let lastIndex = bytes.count - 1
        for index in stride(from: lastIndex, through: 0, by: -1) where index < lastIndex && bytes[index] < 0xFF {
            bytes[index] += 1

            // Randomise trailing bytes because we must not allow the new UUID to be predicable.
            if index + 1 < bytes.count {
                for trailingIndex in (index + 1)..<bytes.count {
                    bytes[trailingIndex] = randomNumberGenerator.byte
                }
            }

            return bytes
        }

        // If we reach here, overflow occurred (all bytes were 0xFF)
        return nil
    }
}
