// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

@Suite("UUIDVersion+v2Tests")
struct UUIDVersionV2Tests {
    private let domain: UInt8 = 1
    private let localID: UInt32 = 2
    private let mockDateService = MockDateService()
    private let mockNodeService = MockNodeService()
    private let mockRandomNumberGenerator = MockRandomNumberGenerator(int48: 0x9E_6B_DE_CE_D8_46)
    private let clockSequenceService = ClockSequenceService(
        clockSequence: 0x33C8,
        previousTimestamp: 0
    )
    private let generator: VersionTwoUUIDGenerator

    init() {
        self.generator = VersionTwoUUIDGenerator(
            clockSequenceService: clockSequenceService,
            dateService: mockDateService,
            dataStoreType: .inMemory,
            domain: domain,
            localID: localID,
            nodeService: mockNodeService,
            randomNumberGenerator: mockRandomNumberGenerator
        )
    }

    @Test
    func matchesTheHardCodedResult() {
        let uuid = generator.new().uuidString
        #expect(uuid == "00000002-9414-21EC-B301-9F6BDECED846")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for _ in 0..<1000 {
            let version = UUIDVersion.v2(
                dataStore: .inMemory,
                domain: domain,
                localID: localID
            )
            let uuid = UUID(version: version).uuidString.lowercased()

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

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func advancesClockSequence() {
        let initialUUID = generator.new().uuidString
        #expect(initialUUID == "00000002-9414-21EC-B301-9F6BDECED846")

        // We expect that the clock was advanced since the date has gone backwards since last use.
        mockDateService.nowValue = mockDateService.nowValue.addingTimeInterval(-10)
        let advancedUUID = generator.new().uuidString.lowercased()

        // We expect `B301` to change to `B401`
        let regex = /^00000002-[0-9a-f]{4}-2[0-9a-f]{3}-b401-9f6bdeced846$/
        #expect(
            advancedUUID.wholeMatch(of: regex) != nil,
            "'\(advancedUUID)' did not advance the clockSequence as expected"
        )
    }
}

extension UUIDVersionV2Tests {
    fileprivate struct MockNodeService: NodeService {
        let node: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (0x9F, 0x6B, 0xDE, 0xCE, 0xD8, 0x46)
    }
}
