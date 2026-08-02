// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

extension Date {
    var millisecondsSince1970: UInt64 {
        UInt64(timeIntervalSince1970 * 1000)
    }
}
