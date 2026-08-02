// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import Foundation

    final class TestUserDefaults: UserDefaults {
        init?(name: String = #function) {
            super.init(suiteName: "\(name)-\(UUID().uuidString)")
        }

        deinit {
            // Clean up values when done.
            for key in dictionaryRepresentation().keys {
                removeObject(forKey: key)
            }
        }
    }
#else
    // FoundationEssentials does not contain UserDefaults.
#endif
