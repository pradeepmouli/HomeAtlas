# SwiftHomeKit

SwiftHomeKit delivers compile-time safe wrappers over Apple HomeKit services and characteristics. Metadata for every service originates from Developer Apple Context7 (`developer_apple`, HomeKit topic), ensuring generated Swift APIs remain aligned with the platform source of truth.

## Highlights

- Strongly typed descriptors for accessories, services, and characteristics (no `Any` leakage).
- `@MainActor` async helpers that bridge HomeKit callbacks to structured Swift concurrency.
- Schema-driven SwiftPM command plugin (`generate-homekit`) to regenerate sources whenever the HomeKit catalog evolves.
- Deterministic error surface that captures accessory, service, and characteristic context for diagnostics.

## Requirements

- Xcode 16 beta or newer with the Swift 6.0 toolchain.
- Apple platforms with HomeKit support (iOS 16+, macOS 13+, tvOS 16+, watchOS 9+).

## Installation

Add `SwiftHomeKit` to your package dependencies:

```swift
.package(url: "https://github.com/pradeepmouli/swift-homekit.git", from: "0.1.0")
```

Then add the library to your target:

```swift
.target(name: "MyApp", dependencies: [
    .product(name: "SwiftHomeKit", package: "swift-homekit")
])
```

## Compile-Time Accessory Control

```swift
import SwiftHomeKit

enum ToggleError: Error {
    case accessoryNotFound
    case characteristicUnavailable
}

@MainActor
func toggleLightbulb(named accessoryName: String, manager: HomeKitManager) async throws {
    await manager.waitUntilReady()

    guard
        let accessory = manager.accessory(named: accessoryName),
        let lightbulb = accessory.service(of: LightbulbService.self)
    else {
        throw ToggleError.accessoryNotFound
    }

    guard let power = lightbulb.powerState else {
        throw ToggleError.characteristicUnavailable
    }

    try await power.write(true)
}
```

The example mirrors the [Developer Apple Context7 HomeKit Lightbulb service documentation](https://developer.apple.com/documentation/homekit/hmservice/lightbulb). `LightbulbService` exposes a `PowerStateCharacteristic` wrapper (`Characteristic<Bool>`) so attempts to write a non-boolean value fail at compile time rather than at runtime.

## Deterministic Error Insights

SwiftHomeKit converts every fallible operation into a `HomeKitError`, enriching the error with the accessory, service, and characteristic metadata documented by [Developer Apple](https://developer.apple.com/documentation/homekit/hmerror).

```swift
do {
    try await power.write(true)
} catch let error as HomeKitError {
    switch error {
    case .characteristicTransport(_, let context, _):
        print("Write failed for", context.characteristicType, "on", context.serviceType ?? "<unknown>")
        print("Metadata:", error.diagnosticsMetadata)
    default:
        throw error
    }
}
```

The shared `DiagnosticsLogger` already emits structured telemetry whenever a HomeKit operation fails or exceeds the configurable latency budget (default 500 ms). Register an observer to integrate with your logging stack:

```swift
let token = DiagnosticsLogger.shared.addObserver { event in
    print("HomeKit", event.operation.rawValue, event.outcome, event.metadata)
}
```

Pair the metadata with the relevant Developer Apple Context7 topic (e.g., accessory communication or latency guidance) to provide actionable insights to end users.

## Context Entities & Organization

SwiftHomeKit provides strongly-typed wrappers for HomeKit context entities that organize accessories:

```swift
import SwiftHomeKit

@MainActor
func listHomeRooms(manager: HomeKitManager) async {
    await manager.waitUntilReady()

    guard let primaryHome = manager.homes.first else {
        print("No homes configured")
        return
    }

    // Wrap HMHome for type-safe access
    let home = Home(primaryHome)

    print("Home: \(home.name)")
    print("Rooms:")

    for hmRoom in home.rooms {
        let room = Room(hmRoom)
        print("  - \(room.name) (\(room.accessories.count) accessories)")
    }

    print("\nZones:")
    for hmZone in home.zones {
        let zone = Zone(hmZone)
        print("  - \(zone.name) (\(zone.rooms.count) rooms)")
    }
}
```

These wrappers conform to the [Developer Apple HMHome](https://developer.apple.com/documentation/homekit/hmhome), [HMRoom](https://developer.apple.com/documentation/homekit/hmroom), and [HMZone](https://developer.apple.com/documentation/homekit/hmzone) APIs while providing `@MainActor` safety and diagnostic logging.

## Cache Lifecycle Management

For performance optimization, SwiftHomeKit exposes cache warm-up and reset APIs:

```swift
@MainActor
func optimizeAccessoryAccess(manager: HomeKitManager) async {
    // Warm up caches for all services and characteristics
    await manager.warmUpCache(includeServices: true, includeCharacteristics: true)

    // Later, if accessories are modified externally:
    await manager.resetCache(includeCharacteristics: true)
}
```

Cache operations emit diagnostics events for monitoring performance:

```swift
let token = DiagnosticsLogger.shared.addObserver { event in
    if event.operation == .cacheWarmUp || event.operation == .cacheReset {
        print("Cache operation:", event.metadata)
    }
}
```

See [Developer Apple - Interacting with a home automation network](https://developer.apple.com/documentation/homekit/interacting-with-a-home-automation-network) for best practices on accessory lifecycle management.

## Generating Sources

SwiftHomeKit uses a two-stage pipeline to keep service definitions synchronized with Apple's SDK:

### 1. Extract Catalog from iOS SDK

```bash
swift run homekit-catalog-extractor \
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    --output Resources/homekit-services.yaml
```

This parses HomeKit framework headers and validates exported symbols against `HomeKit.tbd`, producing a normalized YAML catalog.

### 2. Generate Swift Wrappers

```bash
swift run homekit-service-generator \
    Resources/homekit-services.yaml \
    --output Sources/SwiftHomeKit/Generated
```

Or use the SwiftPM plugin for integrated builds:

```bash
swift package plugin generate-homekit
```

The plugin/generator emits typed Swift wrappers into:

- `Sources/SwiftHomeKit/Generated/Services` for service classes such as `LightbulbService`.
- `Sources/SwiftHomeKit/Generated/Characteristics` for characteristic wrappers such as `PowerStateCharacteristic`.

Every generated file includes `@MainActor` annotations and doc comments referencing the corresponding [Developer Apple HomeKit documentation](https://developer.apple.com/documentation/homekit) so the code stays aligned with the platform source of truth.

For detailed workflow, see [Service Extension Guide](docs/service-extension.md).

## Testing

```bash
swift test
```

Smoke tests validate the schema pipeline and ensure integration logic compiles on platforms without HomeKit support by exercising fallback paths.

## Documentation

- **[Service Extension Guide](docs/service-extension.md)** - SDK extraction and code generation workflow
- **[Troubleshooting Guide](docs/troubleshooting.md)** - Common errors and solutions
- **[Developer Apple Reference Index](docs/reference-index.md)** - Complete API reference citations
- **[Quickstart Guide](specs/001-create-homekit-wrapper/quickstart.md)** - Step-by-step setup

## License

SwiftHomeKit is available under the MIT license. See [LICENSE](LICENSE) for details.
