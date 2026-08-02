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

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    convenience init() throws {
        // Example date from [Appendix A. Test Vectors](https://www.rfc-editor.org/rfc/rfc9562#name-test-vectors).
        let date = try Date.ISO8601FormatStyle().parse("2022-02-22T19:22:22Z")
        self.init(now: date)
    }

    init(now: Date) {
        self._now = now
    }
}

extension DateService where Self == MockDateService {
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func mock() throws -> Self {
        try Self()
    }

    static func mock(now: Date) -> Self {
        Self(now: now)
    }
}
