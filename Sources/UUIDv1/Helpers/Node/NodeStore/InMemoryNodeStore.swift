// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

extension NodeStore where Self == InMemoryNodeStore {
    /// Initialise with the ``Node`` as the provided constant.
    public static func constantInMemory(_ node: Node) -> Self {
        InMemoryNodeStore(node: node)
    }

    /// Singleton that generates a random ``Node`` and holds it in memory for all following `UUID` values generated.
    public static var randomInMemory: Self {
        .shared
    }
}

/// Store for managing the ``Node`` object used to generate UUID values.
///
/// Maintains the ``Node`` in memory only.
public final class InMemoryNodeStore: NodeStore {
    /// Singleton that generates a random ``Node``  and holds it in memory for all following `UUID` values generated.
    public static let shared = InMemoryNodeStore()

    /// The ``Node`` value used for generating `UUID` values.
    public let node: Node

    /// Initialise with the ``Node`` as the provided constant.
    public init(node: Node) {
        self.node = node
    }

    /// Initialise with a random ``Node``.
    public convenience init() {
        self.init(randomNodeGenerator: .default)
    }

    init(randomNodeGenerator: any RandomNodeGenerator) {
        self.node = randomNodeGenerator.newRandomNode()
    }
}
