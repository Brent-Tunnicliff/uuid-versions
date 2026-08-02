// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv1

struct InMemoryNodeStoreTests {
    let originalValue = Node.mock()

    @Test
    func randomNode() throws {
        let nodeStore = InMemoryNodeStore(randomNodeGenerator: .mock(nodeValue: originalValue))

        // Calling the get again returns the same value.
        #expect(nodeStore.node == originalValue)
    }

    @Test
    func constantInMemory() throws {
        let nodeStore = InMemoryNodeStore.constantInMemory(originalValue)

        // Calling the get again returns the same value.
        #expect(nodeStore.node == originalValue)
    }
}
