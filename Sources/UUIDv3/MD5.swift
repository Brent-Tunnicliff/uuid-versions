// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import CryptoKit
    import Foundation
#else
    import Crypto
    import FoundationEssentials
#endif

enum MD5 {
    static func hash(data: Data) -> Data {
        Insecure.MD5.hash(data: data).withUnsafeBytes { Data($0) }
    }
}
