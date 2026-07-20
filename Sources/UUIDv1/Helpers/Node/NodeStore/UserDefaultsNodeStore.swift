// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import Foundation
    import InternalHelpers

    extension NodeStore where Self == UserDefaultsNodeStore {
        /// Singleton that generates a random ``Node`` and stores it in `UserDefaults` for all following `UUID` values generated.
        public static var randomUserDefaults: Self {
            .shared
        }
    }

    /// Store for managing the ``Node`` object used to generate `UUID` values.
    ///
    /// Stores ``Node`` in `UserDefaults`. If missing generates a new random value.
    public final class UserDefaultsNodeStore {
        /// Singleton that generates a random ``Node`` and stores it in `UserDefaults` for all following `UUID` values generated.
        public static let shared = UserDefaultsNodeStore()

        private let lock = NSLock()
        private let randomNodeGenerator: any RandomNodeGenerator
        private let userDefaults: UserDefaults

        init(
            randomNodeGenerator: any RandomNodeGenerator,
            userDefaults: UserDefaults
        ) {
            self.randomNodeGenerator = randomNodeGenerator
            self.userDefaults = userDefaults
        }

        private convenience init() {
            self.init(
                randomNodeGenerator: .default,
                userDefaults: .package
            )
        }
    }

    extension UserDefaultsNodeStore: @unchecked Sendable {}

    extension UserDefaultsNodeStore: NodeStore {
        /// The ``Node`` value used for generating `UUID` values.
        public var node: Node {
            lock.withLock {
                if let cachedNode = userDefaults.node {
                    return cachedNode
                }

                let newNode = randomNodeGenerator.newRandomNode()
                userDefaults.node = newNode
                return newNode
            }
        }
    }
#else
    // FoundationEssentials does not contain UserDefaults.
#endif
