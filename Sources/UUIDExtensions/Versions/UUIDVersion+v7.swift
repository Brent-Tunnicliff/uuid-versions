// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

// MARK: - UUIDVersion

extension UUIDVersion {
    /// [UUID version 7](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-7).
    ///
    /// Time-ordered UUID, useful when the wanting the UUID value to increment with each new one.
    ///
    /// Uses default configuration. Generates with milliseconds in the most significant bits and random for the remaining.
    ///
    /// - warning: If multiple values are generated within the same millisecond there is no guarantee of order between them.
    ///   If you need to guarantee then recommend using ``v7(configuration:)`` instead to set another configuration.
    public static var v7: UUIDVersion {
        v7(configuration: .default)
    }

    /// [UUID version 7](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-7).
    ///
    /// Time-ordered UUID.
    ///
    /// - Parameter configuration: Sets the configuration to use when generating the UUID.
    /// - Returns: ``UUIDVersion`` configured as `v7` based on the input configuration.
    public static func v7(configuration: V7Configuration) -> UUIDVersion {
        UUIDVersion(generator: VersionSevenUUIDGenerator(configuration: configuration))
    }
}

// MARK: - VersionSevenUUIDGenerator

struct VersionSevenUUIDGenerator {
    let id = 7
    private let configuration: V7Configuration
    private let dateService: any DateService
    private let fixedLengthCounterState: FixedLengthCounterState
    private let maxSize = 16
    private let monotonicRandomCounterState: MonotonicRandomCounterState
    private let randomNumberGenerator: any RandomNumberGenerator
    private let sleepService: any SleepService

    fileprivate init(configuration: V7Configuration) {
        self.init(
            configuration: configuration,
            dateService: .default,
            fixedLengthCounterState: .shared,
            monotonicRandomCounterState: .shared,
            randomNumberGenerator: .default,
            sleepService: .default,
        )
    }

    init(
        configuration: V7Configuration,
        dateService: any DateService,
        fixedLengthCounterState: FixedLengthCounterState,
        monotonicRandomCounterState: MonotonicRandomCounterState,
        randomNumberGenerator: any RandomNumberGenerator,
        sleepService: any SleepService
    ) {
        self.configuration = configuration
        self.dateService = dateService
        self.fixedLengthCounterState = fixedLengthCounterState
        self.monotonicRandomCounterState = monotonicRandomCounterState
        self.randomNumberGenerator = randomNumberGenerator
        self.sleepService = sleepService
    }
}

// MARK: - Equatable

extension VersionSevenUUIDGenerator: Equatable {
    static func == (lhs: VersionSevenUUIDGenerator, rhs: VersionSevenUUIDGenerator) -> Bool {
        lhs.configuration == rhs.configuration
    }
}

// MARK: - Hashable

extension VersionSevenUUIDGenerator: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(configuration)
        hasher.combine(id)
    }
}

// MARK: UUIDGenerator

extension VersionSevenUUIDGenerator: UUIDGenerator {
    func new() -> UUID {
        let date = dateService.now()

        var bytes = [UInt8](repeating: 0, count: maxSize)

        // The index of where to add each can change depending on configuration.
        // So lets keep it as a dynamic count.
        var currentIndexValue = 0
        var index: Int {
            let currentIndex = currentIndexValue
            precondition(currentIndex < maxSize, "Index out of bounds '\(currentIndex)'")
            currentIndexValue += 1
            return currentIndex
        }

        // Timestamp (48-bit, milliseconds since Unix epoch)
        let timestamp = date.millisecondsSince1970
        bytes[index] = UInt8((timestamp >> 40) & 0xFF)
        bytes[index] = UInt8((timestamp >> 32) & 0xFF)
        bytes[index] = UInt8((timestamp >> 24) & 0xFF)
        bytes[index] = UInt8((timestamp >> 16) & 0xFF)
        bytes[index] = UInt8((timestamp >> 8) & 0xFF)
        bytes[index] = UInt8(timestamp & 0xFF)

        let fractionNanoseconds: UInt16
        if configuration.increasedClockPrecision {
            fractionNanoseconds = dateService.fractionNanoseconds()
            bytes[index] = UInt8((fractionNanoseconds >> 8) & 0x0F)
            bytes[index] = UInt8(fractionNanoseconds & 0xFF)
        } else {
            fractionNanoseconds = 0
        }

        let randomBytes: [UInt8]
        do {
            switch configuration.counter?.value {
            case nil:
                randomBytes = generateRandomBytes(currentIndex: currentIndexValue)
            case .fixedLength:
                // Add the counter then had the rest with random values.
                let fixedLength = try fixedLengthCounterState.getFixedLengthCounter(
                    timestamp: timestamp,
                    fractionNanoseconds: fractionNanoseconds
                )
                bytes[index] = UInt8((fixedLength >> 8) & 0xFF)
                bytes[index] = UInt8(fixedLength & 0xFF)
                randomBytes = generateRandomBytes(currentIndex: currentIndexValue)
            case .monotonicRandom:
                // The random values are the counter as they always go up for the same.
                randomBytes = try monotonicRandomCounterState.getMonotonicRandomCounter(
                    timestamp: timestamp,
                    fractionNanoseconds: fractionNanoseconds,
                    size: maxSize - currentIndexValue
                )
            }
        } catch {
            // Wait until the next timestamp.
            // The only way that this can fail is in the unlikely case that the counter was at the limit and could no longer increment.
            // If that happens the only solution is to wait until the next timestamp before we can try again.
            sleepService.waitUntilNextTimestamp(
                millisecondsSince1970: timestamp,
                fractionNanoseconds: fractionNanoseconds
            )
            return new()
        }

        precondition(
            currentIndexValue + randomBytes.count == maxSize,
            "Incorrect size of UUID bytes"
        )

        for byte in randomBytes {
            bytes[index] = byte
        }

        // Version 7
        bytes[6] = (bytes[6] & 0x0F) | 0x70

        // Variant
        bytes[8] = (bytes[8] & 0x3F) | 0x80

        return UUID(
            uuid: (
                bytes[0],
                bytes[1],
                bytes[2],
                bytes[3],
                bytes[4],
                bytes[5],
                bytes[6],
                bytes[7],
                bytes[8],
                bytes[9],
                bytes[10],
                bytes[11],
                bytes[12],
                bytes[13],
                bytes[14],
                bytes[15],
            )
        )
    }

    private func generateRandomBytes(currentIndex: Int) -> [UInt8] {
        let size = maxSize - currentIndex
        return randomNumberGenerator.bytes(size: size)
    }
}

// MARK: - State

extension VersionSevenUUIDGenerator {
    /// Shared state kept in memory and referenced while generating UUIDv7 values.
    final class FixedLengthCounterState: @unchecked Sendable {
        static let shared = FixedLengthCounterState()
        private let lock = NSLock()
        private let randomNumberGenerator: any RandomNumberGenerator

        private var fixedLengthCounterCache: (key: Key, value: UInt16)?

        // We want different size values to maintain seperate caches.
        // This way the consumer can create both increased precision and not without them affecting each other.
        private var monotonicRandomCounterCache: [Int: (key: Key, value: [UInt8])] = [:]

        private convenience init() {
            self.init(randomNumberGenerator: .default)
        }

        init(randomNumberGenerator: any RandomNumberGenerator) {
            self.randomNumberGenerator = randomNumberGenerator
        }

        func getFixedLengthCounter(timestamp: UInt64, fractionNanoseconds: UInt16) throws -> UInt16 {
            try lock.withLock {
                let key = Key(timestamp: timestamp, fractionNanoseconds: fractionNanoseconds)
                let max: UInt16 = 0x0FFF
                guard let cache = fixedLengthCounterCache, key <= cache.key else {
                    return cacheAndReturnFixedLengthCounter(randomNumberGenerator.of(size: max), for: key)
                }

                let matchingCounter = cache.value

                guard matchingCounter < max else {
                    throw CounterAtMaxSizeError()
                }

                // We are allowed to increment by one because the remaining bits of the UUID are random.
                return cacheAndReturnFixedLengthCounter(matchingCounter + 1, for: key)
            }
        }

        private func cacheAndReturnFixedLengthCounter(_ value: UInt16, for key: Key) -> UInt16 {
            fixedLengthCounterCache = (key, value)
            return value
        }
    }

    /// Shared state kept in memory and referenced while generating UUIDv7 values.
    final class MonotonicRandomCounterState: @unchecked Sendable {
        static let shared = MonotonicRandomCounterState()
        private let lock = NSLock()
        private let randomNumberGenerator: any RandomNumberGenerator

        // We want different size values to maintain seperate caches.
        // This way the consumer can create both increased precision and not without them affecting each other.
        private var monotonicRandomCounterCache: [Int: (key: Key, value: [UInt8])] = [:]

        private convenience init() {
            self.init(randomNumberGenerator: .default)
        }

        init(randomNumberGenerator: any RandomNumberGenerator) {
            self.randomNumberGenerator = randomNumberGenerator
        }

        func getMonotonicRandomCounter(timestamp: UInt64, fractionNanoseconds: UInt16, size: Int) throws -> [UInt8] {
            try lock.withLock {
                let key = Key(timestamp: timestamp, fractionNanoseconds: fractionNanoseconds)
                guard let cache = monotonicRandomCounterCache[size], key <= cache.key else {
                    return cacheAndReturnMonotonicRandomCounter(
                        randomNumberGenerator.bytes(size: size),
                        for: key,
                        size: size
                    )
                }

                // Increment the bytes
                guard let newValue = incrementingBigEndian(bytes: cache.value) else {
                    throw CounterAtMaxSizeError()
                }

                return cacheAndReturnMonotonicRandomCounter(newValue, for: key, size: size)
            }
        }

        private func cacheAndReturnMonotonicRandomCounter(_ value: [UInt8], for key: Key, size: Int) -> [UInt8] {
            monotonicRandomCounterCache[size] = (key, value)
            return value
        }

        private func incrementingBigEndian(bytes: [UInt8]) -> [UInt8]? {
            var bytes = bytes
            // We want to skip if:
            //   - we are in the last index, because we need the next value to be difficult to guess.
            //   - or if the value is less than max.
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
}

extension VersionSevenUUIDGenerator {
    private struct Key: Comparable, Hashable {
        let timestamp: UInt64
        let fractionNanoseconds: UInt16

        static func < (lhs: VersionSevenUUIDGenerator.Key, rhs: VersionSevenUUIDGenerator.Key) -> Bool {
            guard lhs.timestamp == rhs.timestamp else {
                return lhs.timestamp < rhs.timestamp
            }

            return lhs.fractionNanoseconds < rhs.fractionNanoseconds
        }
    }

    private struct CounterAtMaxSizeError: Swift.Error {}
}
