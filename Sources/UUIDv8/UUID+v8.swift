// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    public import Foundation
#else
    public import FoundationEssentials
#endif

// MARK: - UUIDVersion

extension UUID {
    /// [UUID version 8](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-8).
    ///
    /// Provides a format for experimental or vendor-specific use cases.
    /// This just wraps the input but sets the correct version and variant values.
    ///
    /// - Parameter uuid: The `uuid_t` value to wrap with the standard v8 version and variant.
    /// - Returns: ``UUID`` configured as `v8` based on the input configuration.
    /// - Warning: It is the consumers responsibility to make sure the implementation is unique to their need.
    public static func v8(uuid: uuid_t) -> UUID {
        var bytes = uuid

        // Version 8
        bytes.6 = (bytes.6 & 0x0F) | 0x80

        // Variant
        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return UUID(
            uuid: (
                bytes.0,
                bytes.1,
                bytes.2,
                bytes.3,
                bytes.4,
                bytes.5,
                bytes.6,
                bytes.7,
                bytes.8,
                bytes.9,
                bytes.10,
                bytes.11,
                bytes.12,
                bytes.13,
                bytes.14,
                bytes.15,
            )
        )
    }

    /// [UUID version 8](https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-8).
    ///
    /// Provides a format for experimental or vendor-specific use cases.
    /// This maps the input data directly into the UUID with the correct version and variant values.
    ///
    /// - Parameter data: The data to be converted into the UUID. We will take the leading 128 bits and pad with `0` if smaller than needed.
    /// - Returns: ``UUID`` configured as `v8` based on the input configuration.
    /// - Warning: It is the consumers responsibility to make sure the implementation is unique to their need.
    public static func v8(data: Data) -> UUID {
        var bytes = Array(data.prefix(16))

        while bytes.count < 16 {
            bytes.append(0)
        }

        return v8(
            uuid: (
                bytes[0],
                bytes[1],
                bytes[2],
                bytes[3],
                bytes[4],
                bytes[5],
                bytes[6],
                bytes[7],
                bytes[8],
                bytes[9],
                bytes[10],
                bytes[11],
                bytes[12],
                bytes[13],
                bytes[14],
                bytes[15]
            )
        )
    }
}
