// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDv1

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

struct NodeTests {
    // MARK: - asArray

    @Test
    func asArray() {
        let nodeValues: Node.RawValue = (0x00, 0x01, 0x02, 0x03, 0x04, 0x05)
        let node = Node(rawValue: nodeValues)
        let expectedValue: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05]
        #expect(node.asArray == expectedValue)
    }

    // MARK: - Codable

    // Check that encoding and decoding returns a value equatable to original value.
    @Test
    func codable() throws {
        let node = Node(rawValue: (0x00, 0x01, 0x02, 0x03, 0x04, 0x05))
        let encodedData = try JSONEncoder().encode(node)
        let decodedNode = try JSONDecoder().decode(Node.self, from: encodedData)
        #expect(node == decodedNode)
    }

    // MARK: - description

    @Test
    func description() {
        let node = Node(rawValue: (0x00, 0x01, 0x74, 0x10, 0xbd, 0xff))
        #expect(node.description == "(00, 01, 74, 10, bd, ff)")
    }

    // MARK: - Equatable

    @Test
    func equatable() {
        let nodeA: Node.RawValue = (0x00, 0x01, 0x02, 0x03, 0x04, 0x05)
        let nodeB: Node.RawValue = (0x00, 0x01, 0x02, 0x03, 0x04, 0x06)
        #expect(Node(rawValue: nodeA) == Node(rawValue: nodeA))
        #expect(Node(rawValue: nodeA) != Node(rawValue: nodeB))
    }

    // MARK: - Hashable

    @Test
    func hashable() {
        let nodeA: Node.RawValue = (0x00, 0x01, 0x02, 0x03, 0x04, 0x05)
        let nodeB: Node.RawValue = (0x00, 0x01, 0x02, 0x03, 0x04, 0x06)
        #expect(Node(rawValue: nodeA).hashValue == Node(rawValue: nodeA).hashValue)
        #expect(Node(rawValue: nodeA).hashValue != Node(rawValue: nodeB).hashValue)
    }

    // MARK: - init(values:)

    @Test(
        arguments: [
            [0x00, 0x01, 0x02, 0x03, 0x04, 0x05],
            [0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
            [0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
            [0xff, 0x26, 0x35, 0x00, 0xb3, 0x26],
        ] as [[UInt8]]
    )
    func initValuesSuccess(values: [UInt8]) throws {
        let node = try Node(values: values)
        #expect(node.rawValue.0 == values[0])
        #expect(node.rawValue.1 == values[1])
        #expect(node.rawValue.2 == values[2])
        #expect(node.rawValue.3 == values[3])
        #expect(node.rawValue.4 == values[4])
        #expect(node.rawValue.5 == values[5])
    }

    @Test(
        arguments: [
            [],
            [0x00, 0x01, 0x02, 0x03, 0x04],
            [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06],
        ] as [[UInt8]]
    )
    func initValuesFailure(values: [UInt8]) throws {
        let error = #expect(throws: Node.Error.self) {
            try Node(values: values)
        }

        switch error {
        case let .invalidLength(length):
            #expect(length == values.count)
        case .none:
            Issue.record("Unexpected error: \(error)")
        }
    }
}
