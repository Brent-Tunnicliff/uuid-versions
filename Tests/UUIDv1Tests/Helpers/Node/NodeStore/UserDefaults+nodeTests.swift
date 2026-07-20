// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv1

#if canImport(Darwin)
    import Foundation
    private let userDefaultsAvailable = true
#else
    // FoundationEssentials does not contain UserDefaults.
    private let userDefaultsAvailable = false
#endif

@Suite("UserDefaults+nodeTests", .disabled(if: !userDefaultsAvailable, "UserDefaults not available"))
struct UserDefaultsNodeTests {
    // Sanity test that setting then getting returns the same value.
    @Test
    func node() throws {
        #if canImport(Darwin)
            let userDefaults = try #require(TestUserDefaults())
            let originalValue = Node.mock()
            userDefaults.node = originalValue
            #expect(userDefaults.node == originalValue)
            userDefaults.node = nil
            #expect(userDefaults.node == nil)
        #else
            Issue.record("Unable to test UserDefaults")
        #endif
    }
}
