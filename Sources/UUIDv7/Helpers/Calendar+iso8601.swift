// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
}
