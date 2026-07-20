// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// Wrapper of the `TimestampService` to be used to simplify the `#available` logic.
final class AnyTimestampService: TimestampService {
    static let shared: AnyTimestampService = {
        #if canImport(Darwin)
            if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
                DefaultTimestampService.shared.asAny()
            } else {
                FallbackTimestampService.shared.asAny()
            }
        #else
            DefaultTimestampService.shared.asAny()
        #endif
    }()

    init<Wrapped>(wrapped: Wrapped) where Wrapped: TimestampService {
        self._getTimestamp = { wrapped.getTimestamp() }
    }

    private let _getTimestamp: @Sendable () -> Timestamp
    func getTimestamp() -> Timestamp {
        _getTimestamp()
    }
}

extension TimestampService {
    func asAny() -> AnyTimestampService {
        AnyTimestampService(wrapped: self)
    }
}
