// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv1

#if canImport(Darwin)
    import Foundation
    private let userDefaultsAvailable = true
#else
    // FoundationEssentials does not contain UserDefaults.
    private let userDefaultsAvailable = false
#endif

@Suite(.disabled(if: !userDefaultsAvailable, "UserDefaults not available"))
struct UserDefaultsNodeStoreTests {
    let cachedNode = Node(rawValue: (0x9F, 0x6B, 0xDE, 0xCE, 0xD8, 0x46))
    let nodeStore: UserDefaultsNodeStore
    let randomNode = Node.mock()
    let userDefaults: UserDefaults

    init() throws {
        self.userDefaults = try #require(TestUserDefaults())
        self.nodeStore = UserDefaultsNodeStore(
            randomNodeGenerator: .mock(nodeValue: randomNode),
            userDefaults: userDefaults
        )
    }

    @Test
    func nodeReturnsCache() {
        userDefaults.node = cachedNode
        #expect(nodeStore.node == cachedNode)
    }

    @Test
    func nodeDoesNotEditCacheAfterReturningIt() {
        userDefaults.node = cachedNode
        _ = nodeStore.node
        #expect(userDefaults.node == cachedNode)
    }

    @Test
    func nodeReturnsRandomWhenNoCache() {
        #expect(nodeStore.node == randomNode)
    }

    @Test
    func nodeStoresRandomNodeInCacheAfterReturningIt() {
        _ = nodeStore.node
        #expect(userDefaults.node == randomNode)
    }

    // Sanity test that getting and setting the value many times concurrently doesn't cause issues.
    @Test
    func concurrency() async {
        let counter = Counter()
        let numberOfConcurrentGroups = 10_000
        // Setting two nodes just to make sure only the first one was ever used.
        let nodeStore = UserDefaultsNodeStore(
            randomNodeGenerator: .mutableMock(
                nodeValues: [
                    randomNode,
                    cachedNode,
                ]
            ),
            userDefaults: userDefaults
        )

        await checkConcurrency(numberOfConcurrentGroups: numberOfConcurrentGroups) { [nodeStore, randomNode] in
            #expect(nodeStore.node == randomNode)
            await counter.increment()
        }

        // Make sure the test actually ran.
        await #expect(counter.value == numberOfConcurrentGroups)
    }
}
