// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

@Suite("UUIDVersion+v5Tests")
struct UUIDVersionV5Tests {
    private let name = "www.example.com"
    private let namespace = UUID.dns
    private let mockRandomNumberGenerator = MockRandomNumberGenerator()
    private let generator: VersionFiveUUIDGenerator

    init() {
        self.generator = VersionFiveUUIDGenerator(
            name: name,
            namespace: namespace,
            randomNumberGenerator: mockRandomNumberGenerator
        )
    }

    // https://www.rfc-editor.org/rfc/rfc9562#name-example-of-a-uuidv5-value
    @Test
    func matchesTheStandardExample() {
        let uuid = generator.new().uuidString.lowercased()
        #expect(uuid == "2ed6657d-e927-568b-95e1-2665a8aea6a2")
    }

    @Test
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func isValid() {
        for number in 0..<1000 {
            let name = (0...number).map { _ in
                "\("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement(), default: "nil")"
            }.joined(separator: "")

            let version = UUIDVersion.v5(namespace: UUID(), name: name)
            let uuid = UUID(version: version).uuidString.lowercased()

            // With the version and variant position we expect one of the following formats:
            //  - xxxxxxxx-xxxx-5xxx-8xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-5xxx-9xxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-5xxx-axxx-xxxxxxxxxxxx
            //  - xxxxxxxx-xxxx-5xxx-bxxx-xxxxxxxxxxxx
            let regex = /^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

            #expect(
                uuid.wholeMatch(of: regex) != nil,
                "'\(uuid)' does not match the expected UUIDv5 regex pattern, name: \(name)"
            )
        }
    }
}
