// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    public import Foundation
#else
    public import FoundationEssentials
#endif

extension UUID {
    /// [UUID version 7](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-7).
    ///
    /// Time-ordered UUID.
    ///
    /// - Parameter configuration: Sets the configuration to use when generating the UUID.
    /// - Returns: `UUID` configured as `v7` based on the input configuration.
    public static func v7(configuration: Configuration = .default) -> UUID {
        v7(
            configuration: configuration,
            fixedLengthCounterState: .shared,
            monotonicRandomCounterState: .shared,
            randomNumberGenerator: .default,
            sleepService: .default,
            timestampService: .default
        )
    }

    static func v7(
        configuration: Configuration,
        fixedLengthCounterState: @autoclosure () -> FixedLengthCounterState,
        monotonicRandomCounterState: @autoclosure () -> MonotonicRandomCounterState,
        randomNumberGenerator: any RandomNumberGenerator,
        sleepService: @autoclosure () -> any SleepService,
        timestampService: any TimestampService
    ) -> UUID {
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
        let calculatedTimestamp = timestampService.getTimestamp()

        let timestamp = calculatedTimestamp.milliseconds
        bytes[index] = UInt8((timestamp >> 40) & 0xFF)
        bytes[index] = UInt8((timestamp >> 32) & 0xFF)
        bytes[index] = UInt8((timestamp >> 24) & 0xFF)
        bytes[index] = UInt8((timestamp >> 16) & 0xFF)
        bytes[index] = UInt8((timestamp >> 8) & 0xFF)
        bytes[index] = UInt8(timestamp & 0xFF)

        let fractionNanoseconds: UInt16
        if configuration.increasedClockPrecision {
            fractionNanoseconds = calculatedTimestamp.fraction
            bytes[index] = UInt8((fractionNanoseconds >> 8) & 0x0F)
            bytes[index] = UInt8(fractionNanoseconds & 0xFF)
        } else {
            fractionNanoseconds = 0
        }

        let randomBytes: [UInt8]
        do {
            switch configuration.counter?.value {
            case nil:
                randomBytes = generateRandomBytes(
                    currentIndex: currentIndexValue,
                    randomNumberGenerator: randomNumberGenerator
                )
            case .fixedLength:
                // Add the counter then had the rest with random values.
                let fixedLength = try fixedLengthCounterState().getFixedLengthCounter(
                    timestamp: timestamp,
                    fractionNanoseconds: fractionNanoseconds
                )
                bytes[index] = UInt8((fixedLength >> 8) & 0xFF)
                bytes[index] = UInt8(fixedLength & 0xFF)
                randomBytes = generateRandomBytes(
                    currentIndex: currentIndexValue,
                    randomNumberGenerator: randomNumberGenerator
                )
            case .monotonicRandom:
                // The random values are the counter as they always go up for the same.
                randomBytes = try monotonicRandomCounterState().getMonotonicRandomCounter(
                    timestamp: timestamp,
                    fractionNanoseconds: fractionNanoseconds,
                    size: maxSize - currentIndexValue
                )
            }
        } catch {
            // We only ever expect the `CounterAtMaxSizeError` error to be thrown in this case.
            precondition(error is CounterAtMaxSizeError, "Unexpected error: \(error)")

            // Wait until the next timestamp.
            // The only way that this can fail is in the unlikely case that the counter was at the limit and could no longer increment.
            // If that happens the only solution is to wait until the next timestamp before we can try again.
            sleepService().waitUntilNextTimestamp(
                millisecondsSince1970: timestamp,
                fractionNanoseconds: fractionNanoseconds
            )
            return v7(
                configuration: configuration,
                fixedLengthCounterState: fixedLengthCounterState(),
                monotonicRandomCounterState: monotonicRandomCounterState(),
                randomNumberGenerator: randomNumberGenerator,
                sleepService: sleepService(),
                timestampService: timestampService
            )
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

    private static let maxSize = 16
    private static func generateRandomBytes(
        currentIndex: Int,
        randomNumberGenerator: any RandomNumberGenerator
    ) -> [UInt8] {
        let size = maxSize - currentIndex
        return randomNumberGenerator.bytes(size: size)
    }
}
