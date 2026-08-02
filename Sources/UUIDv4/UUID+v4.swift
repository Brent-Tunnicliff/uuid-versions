// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    public import Foundation
#else
    public import FoundationEssentials
#endif

extension UUID {
    /// [UUID version 4](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-4).
    ///
    /// This is just wrapping the default UUID creation as Foundation uses that by default.
    ///
    /// - Returns: `UUID` configured as `v4`.
    /// - Warning: Technically, Foundation uses RFC 4122 and we are following the later RFC 9562 for the other versions.
    public static func v4() -> UUID {
        UUID()
    }
}
