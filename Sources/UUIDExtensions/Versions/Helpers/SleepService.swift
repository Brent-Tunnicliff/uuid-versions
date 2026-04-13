// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

protocol SleepService: Sendable {
    func waitUntilNextTimestamp(millisecondsSince1970: UInt64, fractionNanoseconds: UInt16)
}

extension SleepService where Self == DefaultSleepService {
    @inlinable
    @inline(__always)
    static var `default`: Self {
        .shared
    }
}

struct DefaultSleepService: SleepService {
    fileprivate static let shared = DefaultSleepService()

    private let calendar = Calendar.iso8601
    private let dateService: any DateService

    init() {
        self.init(
            dateService: .default
        )
    }

    init(dateService: any DateService) {
        self.dateService = dateService
    }

    /// Wait until the next timestamp.
    ///
    /// - Warning: This uses a busy loop instead of sleep so we only wait for as long as needed. For most this will never be used, but those that do hit this will want to stop asap.
    func waitUntilNextTimestamp(millisecondsSince1970: UInt64, fractionNanoseconds: UInt16) {
        var currentMillisecondsSince1970: UInt64
        var currentFractionNanoseconds: UInt16

        repeat {
            let now = dateService.now()
            currentMillisecondsSince1970 = now.millisecondsSince1970
            currentFractionNanoseconds = dateService.fractionNanoseconds()
        } while currentMillisecondsSince1970 == millisecondsSince1970
            && currentFractionNanoseconds <= fractionNanoseconds
    }
}
