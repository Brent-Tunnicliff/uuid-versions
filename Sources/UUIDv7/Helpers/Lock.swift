// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import Foundation
    private typealias LockType = NSLock
#else
    import NIOConcurrencyHelpers
    private typealias LockType = NIOLock
#endif

/// Wrapper of NSLock if platform is Darwin based, or NIOLock if not.
struct Lock: Sendable {
    private let lock = LockType()

    init() {}

    @inlinable
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        try lock.withLock(body)
    }
}
