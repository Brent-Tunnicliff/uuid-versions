// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import CryptoKit
    import Foundation
#else
    import Crypto
    import FoundationEssentials
#endif

enum SHA1 {
    static func hash(data: Data) -> Data {
        Insecure.SHA1.hash(data: data).withUnsafeBytes { Data($0) }
    }
}
