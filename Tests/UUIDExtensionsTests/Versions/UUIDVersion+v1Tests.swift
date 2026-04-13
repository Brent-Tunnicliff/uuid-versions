// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

@Suite("UUIDVersion+v1Tests")
struct UUIDVersionV1Tests {
    private let mockDateService = MockDateService()
    private let mockNodeService = MockNodeService()
    private let mockRandomNumberGenerator = MockRandomNumberGenerator(int48: 0x9E_6B_DE_CE_D8_46)
    private let clockSequenceService = ClockSequenceService(
        clockSequence: 0x33C8,
        previousTimestamp: 0
    )
    private let generator: VersionOneUUIDGenerator

    init() {
        self.generator = VersionOneUUIDGenerator(
            clockSequenceService: clockSequenceService,
            dateService: mockDateService,
            dataStoreType: .inMemory,
            nodeService: mockNodeService,
            randomNumberGenerator: mockRandomNumberGenerator
        )
    }

    // https://www.rfc-editor.org/rfc/rfc9562#name-example-of-a-uuidv1-value
    @Test
    func matchesTheStandardExample() {
        let uuid = generator.new().uuidString
        #expect(uuid == "C232AB00-9414-11EC-B3C8-9F6BDECED846")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for _ in 0..<1000 {
            let uuid = UUID(version: .v1(dataStore: .inMemory)).uuidString.lowercased()

            // With the version and variant position we expect one of the following formats:
            //  - xxxxxxxx-xxxx-1xxx-8xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-1xxx-9xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-1xxx-axxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-1xxx-bxxx-xxxxxxxxxxxx
            let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

            #expect(
                uuid.wholeMatch(of: regex) != nil,
                "'\(uuid)' does not match the expected UUIDv1 regex pattern"
            )
        }
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func advancesClockSequence() {
        _ = generator.new()

        // We expect that the clock was advanced since the date has gone backwards since last use.
        mockDateService.nowValue = mockDateService.nowValue.addingTimeInterval(-10)
        let uuid = generator.new().uuidString.lowercased()
        // The main point we want to test is the value `b3c9`.
        let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-b3c9-[0-9a-f]{12}$/
        #expect(
            uuid.wholeMatch(of: regex) != nil,
            "'\(uuid)' did not advance the clockSequence as expected"
        )
    }

    // Sanity check to see which platforms can actually use `FoundationEssentials`. Will delete afterwards.
    @Test
    func canImportFoundationEssentials() {
        #if canImport(FoundationEssentials)
            Issue.record("FoundationEssentials")
        #endif
    }
}
