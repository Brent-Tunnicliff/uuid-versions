// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
import UUIDv1

final class MockRandomNodeGenerator: RandomNodeGenerator, @unchecked Sendable {
    private var nodeValues: [Node]
    private let lock = Lock()

    init(nodeValues: [Node]) {
        precondition(!nodeValues.isEmpty)
        self.nodeValues = nodeValues
    }

    func newRandomNode() -> Node {
        lock.withLock {
            nodeValues.removeFirst()
        }
    }
}

extension RandomNodeGenerator where Self == MockRandomNodeGenerator {
    static func mock(nodeValues: [Node]) -> Self {
        Self(nodeValues: nodeValues)
    }
}
