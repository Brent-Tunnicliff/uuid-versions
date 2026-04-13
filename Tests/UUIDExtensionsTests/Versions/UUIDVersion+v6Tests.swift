// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

@Suite("UUIDVersion+v6Tests")
struct UUIDVersionV6Tests {
    private let mockDateService = MockDateService()
    private let mockNodeService = MockNodeService()
    private let mockRandomNumberGenerator = MockRandomNumberGenerator(
        clockSequence: 0x33C8,
        int48: 0x9E_6B_DE_CE_D8_46
    )
    private let generator: VersionSixUUIDGenerator

    init() {
        self.generator = VersionSixUUIDGenerator(
            dateService: mockDateService,
            nodeService: mockNodeService,
            randomNumberGenerator: mockRandomNumberGenerator
        )
    }

    // https://www.rfc-editor.org/rfc/rfc9562#name-example-of-a-uuidv6-value
    @Test
    func matchesTheStandardExample() {
        let uuid = generator.new().uuidString
        #expect(uuid == "1EC9414C-232A-6B00-B3C8-9F6BDECED846")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for _ in 0..<1000 {
            let uuid = UUID(version: .v6).uuidString.lowercased()

            // With the version and variant position we expect one of the following formats:
            //  - xxxxxxxx-xxxx-6xxx-8xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-6xxx-9xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-6xxx-axxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-6xxx-bxxx-xxxxxxxxxxxx
            let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-6[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

            #expect(
                uuid.wholeMatch(of: regex) != nil,
                "'\(uuid)' does not match the expected UUIDv6 regex pattern"
            )
        }
    }

    /// We expect v6 to not have the caching that existed in v1.
    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func newNodeAndClockSequenceOnSubsequentCalls() {
        let firstValue = generator.new().uuidString
        #expect(firstValue == "1EC9414C-232A-6B00-B3C8-9F6BDECED846")

        mockDateService.nowValue = mockDateService.nowValue.addingTimeInterval(10)
        mockNodeService.node = (0x1a, 0x2b, 0x3c, 0x4d, 0x5e, 0x6f)
        mockRandomNumberGenerator.clockSequence = 0x22b7
        let secondValue = generator.new().uuidString
        #expect(secondValue == "1EC9414C-8288-6C00-A2B7-1A2B3C4D5E6F")
    }
}
