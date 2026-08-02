// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
public import UUIDv1

#if canImport(Darwin)
    public import Foundation
#else
    public import FoundationEssentials
#endif

extension UUID {
    /// [UUID version 2](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-2).
    ///
    /// Very similar to `v1`, but embeds the domain and local id for linking to the creator
    /// if that level of audibility is needed.
    ///
    /// - Parameters:
    ///    - domain: Represents the domain that the `localID` belongs to.
    ///    - localID: Represents the unique entity within the `domain`.
    ///    - nodeStore: The type of store to be used when generating the node for the UUID.
    /// - Returns: `UUID` configured as `v2` based on inputs.
    ///
    /// - Warning: The domain and localID use up large chunks of the final value, so it increases the risk of collisions compared to `v1`.
    public static func v2(
        domain: UInt8,
        localID: UInt32,
        nodeStore: any NodeStore = .default
    ) -> UUID {
        v2(
            clockSequenceService: .default,
            dateService: .system,
            domain: domain,
            localID: localID,
            nodeStore: nodeStore
        )
    }

    static func v2(
        clockSequenceService: any ClockSequenceService,
        dateService: any DateService,
        domain: UInt8,
        localID: UInt32,
        nodeStore: any NodeStore
    ) -> UUID {
        // UUID epoch offset (1582-10-15 → 1970-01-01) in 100ns units
        let uuidEpoch: UInt64 = 0x01_B2_1D_D2_13_81_40_00

        let now = dateService.now.timeIntervalSince1970
        let timestamp = UInt64(now * 10_000_000) + uuidEpoch

        // Handle clock rollback
        let clockSequence = clockSequenceService.getClockSequence(timestamp: timestamp)

        let timeMid = UInt16((timestamp >> 32) & 0xFFFF)
        var timeHi = UInt16((timestamp >> 48) & 0x0FFF)
        // Version 2
        timeHi |= 0x2000

        var clockSeqHi = UInt8((clockSequence >> 8) & 0x3F)

        // Variant
        clockSeqHi = (clockSeqHi & 0x3F) | 0x80

        let node = nodeStore.node

        return UUID(
            uuid: (
                // local identifier
                UInt8((localID >> 24) & 0xFF),
                UInt8((localID >> 16) & 0xFF),
                UInt8((localID >> 8) & 0xFF),
                UInt8(localID & 0xFF),

                // time_mid
                UInt8((timeMid >> 8) & 0xFF),
                UInt8(timeMid & 0xFF),

                // ver & time_high
                UInt8((timeHi >> 8) & 0xFF),
                UInt8(timeHi & 0xFF),

                // var & clock_seq
                clockSeqHi,
                domain,

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
