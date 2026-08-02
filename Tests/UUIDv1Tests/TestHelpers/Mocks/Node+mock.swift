// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import UUIDv1

extension Node {
    static func mock(rawValue: RawValue = (0x01, 0x02, 0x03, 0x04, 0x05, 0x06)) -> Node {
        Node(rawValue: rawValue)
    }
}
