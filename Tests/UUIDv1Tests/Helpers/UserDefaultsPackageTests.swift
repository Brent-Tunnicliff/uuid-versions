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

@Suite(
    "UserDefaults+packageTests",
    .disabled(if: !userDefaultsAvailable, "UserDefaults not available")
)
struct UserDefaultsPackageTests {
    // Sanity test that the package does not fail to be initialised.
    @Test
    func package() async throws {
        #if canImport(Darwin)
            let userDefaults = UserDefaults.package
            let key = UUID().uuidString

            userDefaults.set(true, forKey: key)
            #expect(userDefaults.bool(forKey: key) == true)
        #else
            Issue.record("Unable to test UserDefaults")
        #endif
    }
}
