// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv1

struct DefaultRandomNodeGeneratorTests {
    @Test
    func getRandomNode() {
        let randomValue: UInt64 = 0x9E_6B_DE_CE_D8_46
        let randomNodeGenerator = DefaultRandomNodeGenerator(randomNumberGenerator: .mock(int48: randomValue))

        // We expect that the least significant bit of the first octet is set to a value of 1
        let expectedNode = Node(rawValue: (0x9F, 0x6B, 0xDE, 0xCE, 0xD8, 0x46))

        let node = randomNodeGenerator.newRandomNode()

        #expect(node == expectedNode)
    }

    // Rough sanity test that the shared instance return changing values.
    @Test
    func getRandomNodeInSharedInstanceReturnsChangingValues() {
        let randomNodeGenerator = DefaultRandomNodeGenerator.default

        var results: Set<Node> = []
        for _ in 0..<100_000 {
            results.insert(randomNodeGenerator.newRandomNode())
        }

        // If there is only one unique value, then there is probably a constant being referenced somewhere.
        #expect(results.count > 1)
    }
}
