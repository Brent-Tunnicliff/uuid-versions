// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// Store for managing the ``Node`` object used to generate `UUID` values.
public protocol NodeStore: Sendable {
    var node: Node { get }
}
