// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    package import Foundation
#else
    package import FoundationEssentials
#endif

package protocol DateService: Sendable {
    var now: Date { get }
}

extension DateService where Self == SystemDateService {
    package static var system: Self {
        .shared
    }
}

package final class SystemDateService: DateService {
    package static let shared = SystemDateService()

    /// Creating a new date object might be the slowest part of UUID's being generated.
    ///
    /// A more performant way to handle this is to keep a cache of the current date object and have an
    /// async task to keep refreshing it every X amount of time, then the cached value is referenced each time.
    /// But that is way more complex than we need. That would only be worthwhile on **very** heavy workflows
    /// that probably should have their own custom implementation built for performance anyway.
    package var now: Date {
        Date()
    }
}
