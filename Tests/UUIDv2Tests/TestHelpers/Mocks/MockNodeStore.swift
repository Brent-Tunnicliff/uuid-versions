// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import UUIDv1

struct MockNodeStore: NodeStore {
    // Example node from [Appendix A. Test Vectors](https://www.rfc-editor.org/rfc/rfc9562#name-test-vectors).
    let node = Node(rawValue: (0x9F, 0x6B, 0xDE, 0xCE, 0xD8, 0x46))
}

extension NodeStore where Self == MockNodeStore {
    static func mock() -> Self {
        Self()
    }
}
