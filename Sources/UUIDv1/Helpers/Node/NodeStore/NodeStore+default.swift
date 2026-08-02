// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    extension NodeStore where Self == UserDefaultsNodeStore {
        /// Default instance of ``NodeStore``.
        ///
        /// Returns the singleton of ``UserDefaultsNodeStore``.
        public static var `default`: Self {
            .randomUserDefaults
        }
    }
#else
    extension NodeStore where Self == InMemoryNodeStore {
        /// Default instance of ``NodeStore``.
        ///
        /// Returns the singleton of ``InMemoryNodeStore``.
        public static var `default`: Self {
            .randomInMemory
        }
    }
#endif
