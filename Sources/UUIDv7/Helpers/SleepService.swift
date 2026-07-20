// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

protocol SleepService: Sendable {
    func waitUntilNextTimestamp(millisecondsSince1970: UInt64, fractionNanoseconds: UInt16)
}

extension SleepService where Self == DefaultSleepService {
    @inlinable
    static var `default`: Self {
        .shared
    }
}

final class DefaultSleepService: SleepService {
    static let shared = DefaultSleepService()

    private let timestampService: any TimestampService

    convenience init() {
        self.init(timestampService: .default)
    }

    init(timestampService: any TimestampService) {
        self.timestampService = timestampService
    }

    /// Wait until the next timestamp.
    ///
    /// - Warning: This uses a busy loop instead of sleep so we only wait for as long as needed. For most this will never be used, but those that do hit this will want to stop asap.
    func waitUntilNextTimestamp(millisecondsSince1970: UInt64, fractionNanoseconds: UInt16) {
        let startTimestamp = Timestamp(milliseconds: millisecondsSince1970, fraction: fractionNanoseconds)
        while timestampService.getTimestamp() <= startTimestamp {}
    }
}
