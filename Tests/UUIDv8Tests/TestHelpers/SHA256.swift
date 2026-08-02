// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import CryptoKit
    import Foundation
    typealias Hasher = CryptoKit.SHA256
#else
    import Crypto
    import FoundationEssentials
    typealias Hasher = Crypto.SHA256
#endif

enum SHA256 {
    static func hash(data: Data) -> Data {
        Hasher.hash(data: data).withUnsafeBytes { Data($0) }
    }
}
