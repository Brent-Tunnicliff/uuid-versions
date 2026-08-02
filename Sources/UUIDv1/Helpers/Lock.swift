// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import Foundation
    private typealias LockType = NSLock
#else
    import NIOConcurrencyHelpers
    private typealias LockType = NIOLock
#endif

/// Wrapper of NSLock if platform is Darwin based, or NIOLock if not.
package struct Lock: Sendable {
    private let lock = LockType()

    package init() {}

    @inlinable
    package func withLock<T>(_ body: () throws -> T) rethrows -> T {
        try lock.withLock(body)
    }
}
