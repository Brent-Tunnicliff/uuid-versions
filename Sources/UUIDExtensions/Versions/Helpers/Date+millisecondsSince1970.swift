// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(FoundationEssentials)
    public import FoundationEssentials
#else
    public import Foundation
#endif

extension Date {
    @inlinable
    @inline(__always)
    var millisecondsSince1970: UInt64 {
        UInt64(timeIntervalSince1970 * 1000)
    }
}
