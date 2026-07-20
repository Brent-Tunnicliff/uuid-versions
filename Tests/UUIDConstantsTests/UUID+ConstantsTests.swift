// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
import UUIDConstants

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

@Suite("UUID+ConstantsTests")
struct UUIDConstantsTests {
    @Test
    func `nil`() {
        #expect(UUID.nil.uuidString == "00000000-0000-0000-0000-000000000000")
    }

    @Test
    func max() {
        #expect(UUID.max.uuidString == "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")
    }

    @Test
    func namespaceDNS() {
        #expect(UUID.dns.uuidString.lowercased() == "6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    }

    @Test
    func namespaceOID() {
        #expect(UUID.oid.uuidString.lowercased() == "6ba7b812-9dad-11d1-80b4-00c04fd430c8")
    }

    @Test
    func namespaceURL() {
        #expect(UUID.url.uuidString.lowercased() == "6ba7b811-9dad-11d1-80b4-00c04fd430c8")
    }

    @Test
    func namespaceX500() {
        #expect(UUID.x500.uuidString.lowercased() == "6ba7b814-9dad-11d1-80b4-00c04fd430c8")
    }
}
