// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

@Suite("UUIDVersion+v3Tests")
struct UUIDVersionV3Tests {
    private let name = "www.example.com"
    private let namespace = UUID.dns
    private let mockRandomNumberGenerator = MockRandomNumberGenerator()
    private let generator: VersionThreeUUIDGenerator

    init() {
        self.generator = VersionThreeUUIDGenerator(
            name: name,
            namespace: namespace,
            randomNumberGenerator: mockRandomNumberGenerator
        )
    }

    // https://www.rfc-editor.org/rfc/rfc9562#name-example-of-a-uuidv3-value
    @Test
    func matchesTheStandardExample() {
        let uuid = generator.new().uuidString.lowercased()
        #expect(uuid == "5df41881-3aed-3515-88a7-2f4a814cf09e")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for number in 0..<1000 {
            let name = (0...number).map { _ in
                "\("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement(), default: "nil")"
            }.joined(separator: "")

            let version = UUIDVersion.v3(namespace: UUID(), name: name)
            let uuid = UUID(version: version).uuidString.lowercased()

            // With the version and variant position we expect one of the following formats:
            //  - xxxxxxxx-xxxx-3xxx-8xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-3xxx-9xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-3xxx-axxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-3xxx-bxxx-xxxxxxxxxxxx
            let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-3[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

            #expect(
                uuid.wholeMatch(of: regex) != nil,
                "'\(uuid)' does not match the expected UUIDv3 regex pattern, name: \(name)"
            )
        }
    }
}
