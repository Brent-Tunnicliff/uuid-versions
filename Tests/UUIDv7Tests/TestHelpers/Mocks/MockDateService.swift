// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
@testable import UUIDv7

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

final class MockDateService: DateService, @unchecked Sendable {
    private let lock = Lock()
    private var _now: Date
    var now: Date {
        get {
            lock.withLock {
                _now
            }
        }
        set {
            lock.withLock {
                _now = newValue
            }
        }
    }

    convenience init() {
        // Example date from [Appendix A. Test Vectors](https://www.rfc-editor.org/rfc/rfc9562#name-test-vectors).
        let exampleDate = "2022-02-22T19:22:22Z"
        guard let date = ISO8601DateFormatter().date(from: exampleDate) else {
            preconditionFailure("Unable to convert to date: \(exampleDate)")
        }

        self.init(now: date)
    }

    init(now: Date) {
        self._now = now
    }
}

extension DateService where Self == MockDateService {
    static func mock() -> Self {
        Self()
    }

    static func mock(now: Date) -> Self {
        Self(now: now)
    }
}
