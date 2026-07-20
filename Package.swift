// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import CompilerPluginSupport
import PackageDescription

// MARK: - Package

let nonDarwinDependencyCondition = TargetDependencyCondition.when(
    platforms: [
        .android,
        .linux,
        .openbsd,
        .wasi,
        .windows,
    ]
)

let package = Package(
    name: "uuid-extensions",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "UUIDConstants",
            targets: ["UUIDConstants"]
        ),
        .library(
            name: "UUIDv1",
            targets: ["UUIDv1"]
        ),
        .library(
            name: "UUIDv2",
            targets: ["UUIDv2"]
        ),
        .library(
            name: "UUIDv3",
            targets: ["UUIDv3"]
        ),
        .library(
            name: "UUIDv4",
            targets: ["UUIDv4"]
        ),
        .library(
            name: "UUIDv5",
            targets: ["UUIDv5"]
        ),
        .library(
            name: "UUIDv6",
            targets: ["UUIDv6"]
        ),
        .library(
            name: "UUIDv7",
            targets: ["UUIDv7"]
        ),
        .library(
            name: "UUIDv8",
            targets: ["UUIDv8"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "4.2.0")),
        .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Brent-Tunnicliff/swift-format-plugin", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Lightweight helpers for use by multiple other targets.
        .target(name: "InternalHelpers"),
        .testTarget(
            name: "InternalHelpersTests",
            dependencies: ["InternalHelpers"]
        ),

        .target(name: "UUIDConstants"),
        .testTarget(
            name: "UUIDConstantsTests",
            dependencies: ["UUIDConstants"]
        ),

        // v1

        .target(
            name: "UUIDv1",
            dependencies: [
                "InternalHelpers",
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio", condition: nonDarwinDependencyCondition),
            ]
        ),
        .testTarget(
            name: "UUIDv1Tests",
            dependencies: [
                "InternalHelpers",
                "UUIDv1",
            ]
        ),

        // v2

        .target(
            name: "UUIDv2",
            dependencies: [
                "InternalHelpers",
                "UUIDv1",
            ]
        ),
        .testTarget(
            name: "UUIDv2Tests",
            dependencies: [
                "InternalHelpers",
                "UUIDv1",
                "UUIDv2",
            ]
        ),

        // v3

        .target(
            name: "UUIDv3",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto", condition: nonDarwinDependencyCondition)
            ]
        ),
        .testTarget(
            name: "UUIDv3Tests",
            dependencies: [
                "UUIDConstants",
                "UUIDv3",
            ]
        ),

        // v4

        .target(name: "UUIDv4"),
        .testTarget(
            name: "UUIDv4Tests",
            dependencies: ["UUIDv4"]
        ),

        // v5

        .target(
            name: "UUIDv5",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto", condition: nonDarwinDependencyCondition)
            ]
        ),
        .testTarget(
            name: "UUIDv5Tests",
            dependencies: [
                "UUIDConstants",
                "UUIDv5",
            ]
        ),

        // v6

        .target(
            name: "UUIDv6",
            dependencies: [
                "InternalHelpers",
                "UUIDv1",
            ]
        ),
        .testTarget(
            name: "UUIDv6Tests",
            dependencies: [
                "InternalHelpers",
                "UUIDv1",
                "UUIDv6",
            ]
        ),

        // v7

        .target(
            name: "UUIDv7",
            dependencies: [
                "InternalHelpers",
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio", condition: nonDarwinDependencyCondition),
            ]
        ),
        .testTarget(
            name: "UUIDv7Tests",
            dependencies: [
                "InternalHelpers",
                "UUIDv7",
            ]
        ),

        // v8

        .target(name: "UUIDv8"),
        .testTarget(
            name: "UUIDv8Tests",
            dependencies: [
                "UUIDConstants",
                "UUIDv8",
                .product(name: "Crypto", package: "swift-crypto", condition: nonDarwinDependencyCondition),
            ]
        ),
    ]
)

// MARK: - Common target settings

// Sets values that are common for every target.
for target in package.targets {
    // MARK: Plugins

    let commonPlugins: [PackageDescription.Target.PluginUsage] = [
        .plugin(name: "LintBuildPlugin", package: "swift-format-plugin")
    ]

    target.plugins = (target.plugins ?? []) + commonPlugins

    // MARK: Swift compliler settings

    let commonSwiftSettings: [PackageDescription.SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + commonSwiftSettings
}
