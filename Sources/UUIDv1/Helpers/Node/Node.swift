// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

/// 48-bit spatially unique identifier used for generating UUID v1, v2 & v6.
///
/// Typically derived from the MAC address, but can be randomly generated instead.
public struct Node: RawRepresentable, Sendable {
    /// The raw 48-bits value type.
    public typealias RawValue = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    /// The raw 48-bits value.
    public let rawValue: RawValue

    /// Initialise an instance of ``Node`` with the raw 48-bits value.
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    var asArray: [UInt8] {
        [
            rawValue.0,
            rawValue.1,
            rawValue.2,
            rawValue.3,
            rawValue.4,
            rawValue.5,
        ]
    }

    init(values: [UInt8]) throws {
        guard values.count == 6 else {
            throw Error.invalidLength(values.count)
        }

        let rawValue: RawValue = (
            values[0],
            values[1],
            values[2],
            values[3],
            values[4],
            values[5],
        )
        self.init(rawValue: rawValue)
    }
}

extension Node: Codable {
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode([UInt8].self)
        try self.init(values: values)
    }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty keyed container in its place.
    ///
    /// - Throws: This function throws an error if any values are invalid for the given encoder's format.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(asArray)
    }
}

extension Node: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        let values: [String] = asArray.map {
            // FoundationEssentials does not support `String(format: "0x%02x", $0)`.
            // So just manually formatting the values instead.
            var value = String($0, radix: 16)

            while value.count < 2 {
                value = "0" + value
            }

            return value
        }

        return "(" + values.map(\.description).joined(separator: ", ") + ")"
    }
}

extension Node: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.asArray == rhs.asArray
    }
}

extension Node: Hashable {
    /// Hashes the essential components of this value by feeding them into the given hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(asArray)
    }
}

extension Node {
    enum Error: Swift.Error, CustomStringConvertible {
        case invalidLength(Int)

        var description: String {
            switch self {
            case let .invalidLength(length): "Node invalid length: '\(length)'"
            }
        }
    }
}
