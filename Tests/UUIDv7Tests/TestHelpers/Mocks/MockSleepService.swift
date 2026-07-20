// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import UUIDv7

struct MockSleepService: SleepService {
    let waitUntilNextTimestampCompletionHandler: @Sendable (UInt64, UInt16) -> Void

    func waitUntilNextTimestamp(millisecondsSince1970: UInt64, fractionNanoseconds: UInt16) {
        waitUntilNextTimestampCompletionHandler(millisecondsSince1970, fractionNanoseconds)
    }
}

extension SleepService where Self == MockSleepService {
    static func mock(
        waitUntilNextTimestampCompletionHandler: @escaping @Sendable (UInt64, UInt16) -> Void = { _, _ in }
    ) -> Self {
        Self(waitUntilNextTimestampCompletionHandler: waitUntilNextTimestampCompletionHandler)
    }
}
