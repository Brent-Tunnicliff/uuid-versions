// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if canImport(Darwin)
    import Foundation
    import InternalHelpers

    extension UserDefaults {
        private static let nodeKey = "node"

        var node: Node? {
            get {
                guard let value = object(forKey: Self.nodeKey) else {
                    return nil
                }

                guard let data = value as? Data else {
                    return nil
                }

                do {
                    return try Node(values: [UInt8](data))
                } catch {
                    preconditionFailure("Unexpected error getting Node: '\(error)'")
                }
            }
            set {
                guard let newValue else {
                    removeObject(forKey: Self.nodeKey)
                    return
                }

                // We need to convert the node into Data type to store it.
                let data = Data(newValue.asArray)
                set(data, forKey: Self.nodeKey)
            }
        }
    }
#else
    // FoundationEssentials does not contain UserDefaults.
#endif
