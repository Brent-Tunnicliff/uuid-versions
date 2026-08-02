// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv1

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

@Suite("UUID+v1Tests")
struct UUIDV1Tests {
    // https://www.rfc-editor.org/rfc/rfc9562#name-example-of-a-uuidv1-value
    @Test
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func matchesTheStandardExample() throws {
        let uuid = UUID.v1(
            clockSequenceService: .mock(clockSequence: 0x33C8),
            dateService: try .mock(),
            nodeStore: .mock()
        ).uuidString
        #expect(uuid == "C232AB00-9414-11EC-B3C8-9F6BDECED846")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for _ in 0..<1000 {
            let uuid = UUID.v1(nodeStore: .randomInMemory).uuidString.lowercased()

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
}
