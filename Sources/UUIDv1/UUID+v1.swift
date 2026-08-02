// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    public import Foundation
#else
    public import FoundationEssentials
#endif

extension UUID {
    /// [UUID version 1](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-1).
    ///
    /// Generates using the current system time and a node of random values.
    /// Typically the node is the MAC address of the machine, but it is not being used here due to
    /// the complexity of getting that value across different platforms.
    ///
    /// - Parameter nodeStore: The type of store to be used when generating the node for the UUID.
    /// - Returns: `UUID` configured as `v1`.
    public static func v1(nodeStore: any NodeStore = .default) -> UUID {
        v1(
            clockSequenceService: .default,
            dateService: .system,
            nodeStore: nodeStore
        )
    }

    static func v1(
        clockSequenceService: any ClockSequenceService,
        dateService: any DateService,
        nodeStore: any NodeStore
    ) -> UUID {
        // UUID epoch offset (1582-10-15 → 1970-01-01) in 100ns units
        let uuidEpoch: UInt64 = 0x01_B2_1D_D2_13_81_40_00

        let now = dateService.now.timeIntervalSince1970
        let timestamp = UInt64(now * 10_000_000) + uuidEpoch

        // Handle clock rollback
        let clockSequence = clockSequenceService.getClockSequence(timestamp: timestamp)

        let timeLow = UInt32(timestamp & 0xFF_FF_FF_FF)
        let timeMid = UInt16((timestamp >> 32) & 0xFFFF)
        var timeHi = UInt16((timestamp >> 48) & 0x0FFF)
        // Version 1
        timeHi |= 0x1000

        // Variant
        let clockSeqHi = UInt8((clockSequence >> 8) & 0x3F) | 0x80

        let clockSeqLow = UInt8(clockSequence & 0xFF)
        let node = nodeStore.node

        return UUID(
            uuid: (
                // time_low
                UInt8((timeLow >> 24) & 0xFF),
                UInt8((timeLow >> 16) & 0xFF),
                UInt8((timeLow >> 8) & 0xFF),
                UInt8(timeLow & 0xFF),

                // time_mid
                UInt8((timeMid >> 8) & 0xFF),
                UInt8(timeMid & 0xFF),

                // ver & time_high
                UInt8((timeHi >> 8) & 0xFF),
                UInt8(timeHi & 0xFF),

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
