// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

package protocol RandomNodeGenerator: Sendable {
    func newRandomNode() -> Node
}

extension RandomNodeGenerator where Self == DefaultRandomNodeGenerator {
    package static var `default`: Self {
        Self.shared
    }
}

package struct DefaultRandomNodeGenerator: RandomNodeGenerator {
    static let shared = DefaultRandomNodeGenerator()

    private let randomNumberGenerator: any RandomNumberGenerator

    private init() {
        self.init(randomNumberGenerator: .default)
    }

    init(randomNumberGenerator: any RandomNumberGenerator) {
        self.randomNumberGenerator = randomNumberGenerator
    }

    package func newRandomNode() -> Node {
        let node = randomNumberGenerator.int48

        // Section [6.10](https://www.rfc-editor.org/rfc/rfc9562#unidentifiable) of rRFC9562
        // says we "MUST set the least significant bit of the first octet of the Node ID to 1".
        var firstOctet = generateOctet(node: node, index: 0)
        firstOctet |= 0x01

        let rawValue = (
            firstOctet,
            generateOctet(node: node, index: 1),
            generateOctet(node: node, index: 2),
            generateOctet(node: node, index: 3),
            generateOctet(node: node, index: 4),
            generateOctet(node: node, index: 5)
        )

        return Node(rawValue: rawValue)
    }

    private func generateOctet(node: UInt64, index: Int) -> UInt8 {
        UInt8((node >> (8 * (5 - index))) & 0xFF)
    }
}
