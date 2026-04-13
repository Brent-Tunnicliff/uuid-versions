// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

final class MockSleepService: SleepService, @unchecked Sendable {
    private let lock = NSLock()

    private var _waitUntilNextTimestampCompletionHandler: @Sendable (UInt64, UInt16) -> Void = { _, _ in }
    var waitUntilNextTimestampCompletionHandler: @Sendable (UInt64, UInt16) -> Void {
        get { lock.withLock { _waitUntilNextTimestampCompletionHandler } }
        set { lock.withLock { _waitUntilNextTimestampCompletionHandler = newValue } }
    }

    func waitUntilNextTimestamp(millisecondsSince1970: UInt64, fractionNanoseconds: UInt16) {
        waitUntilNextTimestampCompletionHandler(millisecondsSince1970, fractionNanoseconds)
    }
}
