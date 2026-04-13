// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

@Suite("UUIDVersion+v4Tests")
struct UUIDVersionV4Tests {
    // UUID v4 wraps the default system implementation.
    // So this test is a sanity check that will fail if the system default ever changes.
    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for _ in 0..<1000 {
            let uuid = UUID(version: .v4).uuidString.lowercased()

            // With the version and variant position we expect one of the following formats:
            //  - xxxxxxxx-xxxx-4xxx-8xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-4xxx-9xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-4xxx-axxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-4xxx-bxxx-xxxxxxxxxxxx
            let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

            #expect(
                uuid.wholeMatch(of: regex) != nil,
                "'\(uuid)' does not match the expected UUIDv4 regex pattern"
            )
        }
    }
}
