// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import Foundation
    import InternalHelpers

    /// If the platform is too old and cannot use Clock, then just use a simpler Date based one instead.
    ///
    /// This is only needed for Darwin platforms where their platform is too old to use `Clock`.
    /// - Warning: We cannot reliably calculate fraction with Date so it is hard coded as 0.
    @available(iOS, deprecated: 16.0, message: "Use DefaultTimestampService instead.")
    @available(macOS, deprecated: 13.0, message: "Use DefaultTimestampService instead.")
    @available(tvOS, deprecated: 16.0, message: "Use DefaultTimestampService instead.")
    @available(visionOS, deprecated, message: "Use DefaultTimestampService instead.")
    @available(watchOS, deprecated: 9.0, message: "Use DefaultTimestampService instead.")
    final class FallbackTimestampService: TimestampService {
        static let shared = FallbackTimestampService()

        func getTimestamp() -> Timestamp {
            Timestamp(
                milliseconds: Date().millisecondsSince1970,
                fraction: 0
            )
        }
    }
#endif
