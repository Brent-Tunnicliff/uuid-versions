// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    import Foundation

    extension UserDefaults {
        static var package: UserDefaults {
            let suiteName = Package.fullName
            guard let userDefaults = UserDefaults(suiteName: suiteName) else {
                preconditionFailure("Unable to create UserDefaults with suite name '\(suiteName)'")
            }

            return userDefaults
        }
    }
#else
    // FoundationEssentials does not contain UserDefaults.
#endif
