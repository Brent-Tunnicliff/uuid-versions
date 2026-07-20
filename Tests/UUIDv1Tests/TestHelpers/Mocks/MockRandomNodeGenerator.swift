// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
@testable import UUIDv1

struct MockRandomNodeGenerator: RandomNodeGenerator {
    let nodeValue: Node

    func newRandomNode() -> Node {
        nodeValue
    }
}

extension RandomNodeGenerator where Self == MockRandomNodeGenerator {
    static func mock(nodeValue: Node = .mock()) -> Self {
        Self(nodeValue: nodeValue)
    }
}

final class MutableMockRandomNodeGenerator: RandomNodeGenerator, @unchecked Sendable {
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

extension RandomNodeGenerator where Self == MutableMockRandomNodeGenerator {
    static func mutableMock(nodeValues: [Node]) -> Self {
        Self(nodeValues: nodeValues)
    }
}
