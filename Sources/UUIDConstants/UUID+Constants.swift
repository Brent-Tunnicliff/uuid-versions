// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    public import Foundation
#else
    public import FoundationEssentials
#endif

extension UUID {
    /// Nil UUID has all 128 bits set to 0.
    ///
    /// It is the uuid value of "00000000-0000-0000-0000-000000000000"
    ///
    /// <https://www.rfc-editor.org/rfc/rfc9562#section-5.9>
    public static let `nil` = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))

    /// Max UUID has all 128 bits set to 1.
    ///
    /// It is the maximum uuid value of "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    ///
    /// <https://www.rfc-editor.org/rfc/rfc9562#section-5.10>.
    public static let max = UUID(
        uuid: (
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff,
            0xff
        )
    )
}

// MARK: - Namespaces

extension UUID {
    /// DNS namespace ID for v3 and v5 UUID's.
    ///
    /// <https://www.rfc-editor.org/rfc/rfc9562#section-6.6>
    public static let dns = UUID(
        uuid: (
            0x6b,
            0xa7,
            0xb8,
            0x10,
            0x9d,
            0xad,
            0x11,
            0xd1,
            0x80,
            0xb4,
            0x00,
            0xc0,
            0x4f,
            0xd4,
            0x30,
            0xc8
        )
    )

    /// URL namespace ID for v3 and v5 UUID's.
    ///
    /// <https://www.rfc-editor.org/rfc/rfc9562#section-6.6>
    public static let url = UUID(
        uuid: (
            0x6b,
            0xa7,
            0xb8,
            0x11,
            0x9d,
            0xad,
            0x11,
            0xd1,
            0x80,
            0xb4,
            0x00,
            0xc0,
            0x4f,
            0xd4,
            0x30,
            0xc8
        )
    )

    /// OID namespace ID for v3 and v5 UUID's.
    ///
    /// <https://www.rfc-editor.org/rfc/rfc9562#section-6.6>
    public static let oid = UUID(
        uuid: (
            0x6b,
            0xa7,
            0xb8,
            0x12,
            0x9d,
            0xad,
            0x11,
            0xd1,
            0x80,
            0xb4,
            0x00,
            0xc0,
            0x4f,
            0xd4,
            0x30,
            0xc8
        )
    )

    /// X500 namespace ID for v3 and v5 UUID's.
    ///
    /// <https://www.rfc-editor.org/rfc/rfc9562#section-6.6>
    public static let x500 = UUID(
        uuid: (
            0x6b,
            0xa7,
            0xb8,
            0x14,
            0x9d,
            0xad,
            0x11,
            0xd1,
            0x80,
            0xb4,
            0x00,
            0xc0,
            0x4f,
            0xd4,
            0x30,
            0xc8
        )
    )
}
