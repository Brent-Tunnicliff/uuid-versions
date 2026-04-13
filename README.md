# uuid-extensions

The purpose of this project is:

1. Expand Foundation UUID creation to support various versions as per [RFC 9562](https://www.rfc-editor.org/rfc/rfc9562) as creating a new Foundation.UUID object uses v4.
2. Provide a macro for creating UUID's with StaticString that fails the build instead of returning optional if the input is invalid.
3. Provide constants for `nil` and `max` UUIDs. 
4. Support all swift platforms that can import Foundation.UUID or FoundationEssentials.UUID. But if any platform requires too much custom work to get working then I may decide to ignore.

## Supported platforms

Apple platforms, including:

- iOS
- macOS
- tvOS
- visionOS
- watchOS

Other supported platforms:

- Android
- Linux
- WASM
- Windows

> [!WARNING]
> These other platforms have only been tested via CI pipeline. Some only by building. So please report any issues found with them.

## Installation

Import via SPM:

```swift
let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/Brent-Tunnicliff/uuid-extensions.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            // ...
            dependencies: [
                .product(name: "UUIDExtensions", package: "uuid-extensions"),
            ]
```

## How to use

### UUID Versions

#### UUID v1

Time and node based UUID.

Node is typically based on the MAC address of the machine that generates it, 
but due to complexity around supporting that for a niche version,  decided to go for the option
of a randomly generated node.

By default it will persist the node value to `UserDefaults`. But you can customise this to be in memory only, 
or add encryption when storing it in UserDefaults.

Example: C232AB00-9414-11EC-B3C8-9F6BDECED846

```swift
// Default implementation 
let id: UUID = .v1
```

```swift
// Keep state in memory only
let id: UUID = .v1(dataStore: .inMemory)
```

```swift
// Persist state to disk.
let id: UUID = .v1(dataStore: .persistent)
```

```swift
// Persist encrypted state to disk.
// The same key needs to be used to decrypt, so store it somewhere secure.
// An optional `authenticatedData` can also be passed in as an extra check that always needs to be the same value.
let key = SymmetricKey(size: .bits256)
let data: Data?
let id: UUID = .v1(dataStore: .securePersistent(key: key, authenticatedData: data))
```

<https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-1>

#### UUID v2

Very similar to v1, but embeds the domain and local id for linking to the creator if that level of audibility is needed.

It sacrifices a lot of its randomness, increasing the risk of collisions (same UUID value bing generated multiple times).

V2 is seen as a very niche version.

```swift
let domain: UInt8
let localID: UInt32

// Default implementation
let id: UUID = .v2(domain: domain, localID: localID)
```

```swift
// Keep state in memory only
let id: UUID = .v2(dataStore: .inMemory, domain: domain, localID: localID)
```

```swift
// Persist state to disk.
let id: UUID = .v2(dataStore: .persistent, domain: domain, localID: localID)
```

```swift
// Persist encrypted state to disk.
// The same key needs to be used to decrypt, so store it somewhere secure.
// An optional `authenticatedData` can also be passed in as an extra check that always needs to be the same value.
let key = SymmetricKey(size: .bits256)
let data: Data?
let id: UUID = .v2(dataStore: .securePersistent(key: key, authenticatedData: data), domain: domain, localID: localID)
```

<https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-2>

#### UUID v3

Generates UUID based on hashing the namespace and name inputs with MD5.

Has no random or time based aspect, so passing in the same inputs will always return the same response.

Useful for generating meaningful UUID's that can be repeated/verified.

It is recommended to use `v5` over this if possible.

```swift
// Can use a specified constant as the namespace like `.dns`, `.url`, `.oid`, `.x500`, or your own custom UUID value.
let namespace: UUID
let name: String

let id: UUID = .v3(namespace: namespace, name: name)
```

<https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-3>

#### UUID v4

A randomly generated UUID.

The default `Foundation.UUID()` initialisation uses v4, so this is just a wrapper of that default behaviour.

Has been included for completeness.

```swift
let id: UUID = .v4

// is the same as
let id: UUID = UUID()
```

<https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-4>

#### UUID v5

The same inputs and similar method to v3, except uses SHA-1 to hash the inputs.

Has no random or time based aspect, so passing in the same inputs will always return the same response.

Useful for generating meaningful UUID's that can be repeated/verified.

```swift
// Can use a specified constant as the namespace like `.dns`, `.url`, `.oid`, `.x500`, or your own custom UUID value.
let namespace: UUID
let name: String

let id: UUID = .v5(namespace: namespace, name: name)
```

<https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-5>

#### UUID v6

Similar to `v1`, but reordered the leading timestamp for improved DB locality.

This is also following the recommendation to use a new random node and clock sequence for each UUID generated.

It is recommended to use `v7` over this if possible.

```swift
let id: UUID = .v6
```

<https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-6>

#### UUID v7

Time-ordered UUID, useful when the wanting the UUID value to increment with each new one.

Generates with milliseconds in the most significant bits and random for the remaining.

Optional configurations can be used to increase the precision of the timestamp to sub-milliseconds, and/or adding counter logic.

Both of the counter options guarantee that the UUID will always increment from the last, even if many get generated within the same timestamp value.

- Fixed length counter increments by 1 from a previous that shares the same timestamp. But the end value still has enough random values to make future values unpredictable.
- Monotonic random counter makes sure the random values of the UUID are always a higher value then any previous values that share the same timestamp in a way that makes predicting the next value difficult.

For both counter types, in the edge case that we reach the highest possible value for that timestamp, it will sleep and wait for the next time stamp value.
This can be either 1 millisecond, or less based on if increased clock precision is enabled or not.

```swift
// Default implementation
let id: UUID = .v7

// or
let id: UUID = .v7(configuration: .default)
``` 

```swift
// Generates timestamp with sub-milliseconds 
let id: UUID = .v7(configuration: .withIncreasedClockPrecision)
```

```swift
// Generates with the fixed length counter
let id: UUID = .v7(configuration: .with(counter: .fixedLength))
```

```swift
// Generates with the monotonic random counter
let id: UUID = .v7(configuration: .with(counter: .monotonicRandom))
```

```swift
// Generates timestamp with sub-milliseconds and the fixed length counter
let id: UUID = .v7(configuration: .withIncreasedClockPrecision(counter: .fixedLength))
```

```swift
// Generates timestamp with sub-milliseconds and the monotonic random counter
let id: UUID = .v7(configuration: .withIncreasedClockPrecision(counter: .monotonicRandom))
```

<https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-7>

#### UUID v8

Provides a format for experimental or vendor-specific use cases.

The implementation in this package is just a way to wrap the desired value and set the version and variant fields.

Can be generated based on:

- `uuid_t`: The same type used in `Foundation.UUID(uuid:)`. But we edit it to set the version and variant.
- `Data`: We take the prefix of data, pad the end with 0 if needed, then set the version and variant.

<https://www.rfc-editor.org/rfc/rfc9562#name-uuid-version-8>

### Macro

This freestanding macro can be used directly wherever the UUID needs to be created with:

```swift
import UUIDExtensions

let id: UUID = #uuid("95034084-7faa-4311-88dc-3cbc8052b359")
```

The input is type "StaticString", so the value must be known at compile time.

If the input does not have a valid UUID format, then you will get a compile error that it isn't a valid UUID.

```swift
// Compile error: 'hello :)' is not a valid UUID
let id: UUID = #uuid("hello :)")
```

### Constants

The project has a small number of constants defined in [RFC 9562](https://www.rfc-editor.org/rfc/rfc9562).
They are added as static extension to the Foundation.UUID type.

#### UUID.nil

Nil UUID has all 128 bits set to 0.

```swift
// 00000000-0000-0000-0000-000000000000
let id: UUID = .nil
```

<https://www.rfc-editor.org/rfc/rfc9562#section-5.9>

#### UUID.max

Max UUID has all 128 bits set to 1.

```swift
// FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF
let id: UUID = .max
```

<https://www.rfc-editor.org/rfc/rfc9562#section-5.10>.

#### UUID.dns

DNS namespace ID for v3 and v5 UUID's.

```swift
// 6BA7B810-9DAD-11D1-80B4-00C04FD430C8
let id: UUID = .dns
```

<https://www.rfc-editor.org/rfc/rfc9562#section-6.6>

#### UUID.url

URL namespace ID for v3 and v5 UUID's.

```swift
// 6BA7B811-9DAD-11D1-80B4-00C04FD430C8
let id: UUID = .url
```

<https://www.rfc-editor.org/rfc/rfc9562#section-6.6>

#### UUID.oid

OID namespace ID for v3 and v5 UUID's.

```swift
// 6BA7B812-9DAD-11D1-80B4-00C04FD430C8
let id: UUID = .oid
```

<https://www.rfc-editor.org/rfc/rfc9562#section-6.6>

#### UUID.x500

X500 namespace ID for v3 and v5 UUID's.

```swift
// 6BA7B814-9DAD-11D1-80B4-00C04FD430C8
let id: UUID = .x500
```

<https://www.rfc-editor.org/rfc/rfc9562#section-6.6>

### See more

See <https://brent-tunnicliff.github.io/uuid-extensions/documentation/uuidextensions> for more details.

## Source Stability

The versioning of this package follows [Semantic Versioning](https://semver.org/). Source breaking changes to public API require a new major version.

We'd like this package to quickly embrace Swift language and toolchain improvements, and expect the latest Swift toolchains to be used (i.e. latest public Xcode version). So we will include updating the Swift version of the package as a new minor version bump.

## Disclaimer

I only pretend to know what I am doing. If you find something wrong please raise an issue to let me know.
