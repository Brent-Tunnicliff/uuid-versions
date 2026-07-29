// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv6

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

@Suite("UUID+v6Tests")
struct UUIDV6Tests {
    private let mockRandomNumberGenerator = MockRandomNodeGenerator(
        nodeValues: [
            // Example node from [Appendix A. Test Vectors](https://www.rfc-editor.org/rfc/rfc9562#name-test-vectors).
            .mock(rawValue: (0x9F, 0x6B, 0xDE, 0xCE, 0xD8, 0x46)),
            .mock(rawValue: (0x1a, 0x2b, 0x3c, 0x4d, 0x5e, 0x6f)),
        ]
    )

    // https://www.rfc-editor.org/rfc/rfc9562#name-example-of-a-uuidv6-value
    @Test
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func matchesTheStandardExample() throws {
        let uuid = UUID.v6(
            clockSequenceGenerator: .mock(),
            dateService: try .mock(),
            randomNodeGenerator: mockRandomNumberGenerator
        ).uuidString
        #expect(uuid == "1EC9414C-232A-6B00-B3C8-9F6BDECED846")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for _ in 0..<1000 {
            let uuid = UUID.v6().uuidString.lowercased()

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
    func newNodeAndClockSequenceOnSubsequentCalls() throws {
        var mockDateService = try MockDateService()
        var mockClockSequenceGenerator = MockClockSequenceGenerator.mock()
        let firstValue = UUID.v6(
            clockSequenceGenerator: mockClockSequenceGenerator,
            dateService: mockDateService,
            randomNodeGenerator: mockRandomNumberGenerator
        ).uuidString
        #expect(firstValue == "1EC9414C-232A-6B00-B3C8-9F6BDECED846")

        mockDateService.now.addTimeInterval(10)
        mockClockSequenceGenerator.clockSequence = 0x22b7
        let secondValue = UUID.v6(
            clockSequenceGenerator: mockClockSequenceGenerator,
            dateService: mockDateService,
            randomNodeGenerator: mockRandomNumberGenerator
        ).uuidString
        #expect(secondValue == "1EC9414C-8288-6C00-A2B7-1A2B3C4D5E6F")
    }
}
