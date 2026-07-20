// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
import UUIDv1
@testable import UUIDv2

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

@Suite("UUID+v2Tests")
struct UUIDV2Tests {
    private let domain: UInt8 = 1
    private let localID: UInt32 = 2

    @Test
    func matchesTheHardCodedResult() {
        let uuid = UUID.v2(
            clockSequenceService: .mock(clockSequence: 0x33C8),
            dateService: .mock(),
            domain: domain,
            localID: localID,
            nodeStore: .mock()
        ).uuidString
        #expect(uuid == "00000002-9414-21EC-B301-9F6BDECED846")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for _ in 0..<1000 {
            let uuid = UUID.v2(domain: domain, localID: localID, nodeStore: .randomInMemory).uuidString.lowercased()

            // With the version and variant position we expect one of the following formats:
            //  - xxxxxxxx-xxxx-2xxx-8xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-2xxx-9xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-2xxx-axxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-2xxx-bxxx-xxxxxxxxxxxx
            let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-2[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

            #expect(
                uuid.wholeMatch(of: regex) != nil,
                "'\(uuid)' does not match the expected UUIDv2 regex pattern"
            )
        }
    }
}
