// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
import UUIDv1

#if canImport(Darwin)
    public import Foundation
#else
    public import FoundationEssentials
#endif

// MARK: - UUID

extension UUID {
    /// [UUID version 6](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-6).
    ///
    /// Similar to `v1`, but reordered the leading timestamp for improved DB locality.
    /// Also we are following the recommendation to use a new random node and clock sequence for each UUID generated.
    ///
    /// - Returns: `UUID` configured as `v6`.
    public static func v6() -> UUID {
        v6(clockSequenceGenerator: .default, dateService: .system, randomNodeGenerator: .default)
    }

    static func v6(
        clockSequenceGenerator: any ClockSequenceGenerator,
        dateService: any DateService,
        randomNodeGenerator: any RandomNodeGenerator
    ) -> UUID {
        // UUID epoch offset (1582-10-15 → 1970-01-01) in 100ns units
        let uuidEpoch: UInt64 = 0x01_B2_1D_D2_13_81_40_00

        let now = dateService.now.timeIntervalSince1970
        let timestamp = UInt64(now * 10_000_000) + uuidEpoch

        // Recommended to use a new random clock sequence each time.
        let clockSequence = clockSequenceGenerator.generateClockSequence()

        let timeHigh = UInt32((timestamp >> 28) & 0xFF_FF_FF_FF)
        let timeMid = UInt16((timestamp >> 12) & 0xFFFF)
        var timeLow = UInt16(timestamp & 0x0FFF)

        // Version 6
        timeLow |= 0x6000

        var clockSeqHi = UInt8((clockSequence >> 8) & 0x3F)

        // Variant
        clockSeqHi = (clockSeqHi & 0x3F) | 0x80

        let clockSeqLow = UInt8(clockSequence & 0xFF)

        // Recommended to use a new random node sequence each time.
        let node = randomNodeGenerator.newRandomNode()

        return UUID(
            uuid: (
                // time_high
                UInt8((timeHigh >> 24) & 0xFF),
                UInt8((timeHigh >> 16) & 0xFF),
                UInt8((timeHigh >> 8) & 0xFF),
                UInt8(timeHigh & 0xFF),

                // time_mid
                UInt8((timeMid >> 8) & 0xFF),
                UInt8(timeMid & 0xFF),

                // ver & time_low
                UInt8((timeLow >> 8) & 0xFF),
                UInt8(timeLow & 0xFF),

                // var & clock_seq
                clockSeqHi,
                clockSeqLow,

                // node
                node.rawValue.0,
                node.rawValue.1,
                node.rawValue.2,
                node.rawValue.3,
                node.rawValue.4,
                node.rawValue.5,
            )
        )
    }
}
