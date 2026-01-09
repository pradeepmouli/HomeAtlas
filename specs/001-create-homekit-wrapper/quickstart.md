# Quickstart: Strongly Typed HomeKit Wrapper

## Prerequisites
- Xcode 16 beta or newer with Swift 6.0 toolchain.
- HomeKit entitlement enabled on test devices (iOS 26+, macOS 26+).
- Access to Developer Apple Context7 (`developer_apple`, HomeKit topic) for metadata verification.

## Installation
```bash
# Add dependency in Package.swift
.package(url: "https://github.com/pradeepmouli/HomeAtlas.git", from: "0.1.0")

# Add to target dependencies
.target(
    name: "MyApp",
    dependencies: [
    .product(name: "HomeAtlas", package: "HomeAtlas")
    ]
)
```

## Generate Typed Sources

HomeAtlas uses a two-stage pipeline to stay synchronized with Apple's HomeKit SDK:

### Stage 1: Extract Catalog from SDK

```bash
swift run HomeKitCatalogExtractor \
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    --output Resources/homekit-services.yaml
```

This command:
- Parses HomeKit framework headers using Clang
- Validates exported symbols against `HomeKit.tbd`
- Generates normalized YAML catalog citing [Developer Apple HomeKit metadata](https://developer.apple.com/documentation/homekit)

### Stage 2: Generate Swift Wrappers

```bash
swift run HomeKitServiceGenerator \
    Resources/homekit-services.yaml \
    --output Sources/HomeAtlas/Generated
```

Generated files contain:
- `@MainActor` annotations for concurrency safety
- Documentation links to [Developer Apple Context7](https://developer.apple.com/documentation/homekit)
- Split output into `Generated/Services` and `Generated/Characteristics`

For complete workflow details, see the [Service Extension Guide](../../docs/service-extension.md).

## Using the Wrapper
```swift
import HomeAtlas

enum ToggleError: Error {
    case accessoryNotFound
    case characteristicUnavailable
}

@MainActor
func toggleLightbulb(named accessoryName: String, manager: HomeKitManager) async throws {
    await manager.waitUntilReady()

    guard
        let accessory = manager.accessory(named: accessoryName),
        let service = accessory.service(of: LightbulbService.self)
    else {
        throw ToggleError.accessoryNotFound
    }

    guard let power = service.powerState else {
        throw ToggleError.characteristicUnavailable
    }

    try await power.write(true)
}
```

## Context Entities & Organization

Organize accessories using strongly-typed wrappers for HomeKit context entities:

```swift
import HomeAtlas

@MainActor
func manageHome(manager: HomeKitManager) async throws {
    await manager.waitUntilReady()

    guard let primaryHome = manager.homes.first else { return }
    let home = Home(primaryHome)

    // Add a new room
    let bedroom = try await home.addRoom(named: "Bedroom")
    let bedroomWrapper = Room(bedroom)

    // Create a zone grouping multiple rooms
    let upstairsZone = try await home.addZone(named: "Upstairs")
    let zone = Zone(upstairsZone)
    try await zone.addRoom(bedroom)

    // List all rooms and zones
    print("Rooms in \(home.name):")
    for hmRoom in home.rooms {
        let room = Room(hmRoom)
        print("  - \(room.name) (\(room.accessories.count) accessories)")
    }
}
```

These wrappers conform to [Developer Apple HMHome](https://developer.apple.com/documentation/homekit/hmhome), [HMRoom](https://developer.apple.com/documentation/homekit/hmroom), and [HMZone](https://developer.apple.com/documentation/homekit/hmzone) APIs with `@MainActor` safety.

## Cache Lifecycle Optimization

Optimize performance with cache warm-up and reset APIs:

```swift
@MainActor
func optimizeCaching(manager: HomeKitManager) async {
    // Warm up caches before intensive operations
    await manager.warmUpCache(includeServices: true, includeCharacteristics: true)

    // Monitor cache operations
    let token = DiagnosticsLogger.shared.addObserver { event in
        if event.operation == .cacheWarmUp || event.operation == .cacheReset {
            print("Cache \(event.operation.rawValue):", event.duration)
        }
    }

    // Reset caches after external modifications
    await manager.resetCache(includeCharacteristics: true)
}
```

See [Developer Apple - Interacting with a home automation network](https://developer.apple.com/documentation/homekit/interacting-with-a-home-automation-network) for best practices.

## Testing Strategy
- Run `swift test --filter HomeAtlasTests` to execute unit and integration tests.
- Use `swift test --enable-test-discovery` on Linux/macOS to verify fallback builds without HomeKit framework.
- Execute `swift run HomeKitServiceGenerator Resources/homekit-services.yaml --output Sources/HomeAtlas/Generated` after catalog updates to refresh generated wrappers.

## Error Handling & Diagnostics

- Every HomeKit read/write surfaces a `HomeKitError` that includes accessory, service, and characteristic metadata pulled from Developer Apple Context7 (`developer_apple`, HomeKit > HMError).
- Register an observer on `DiagnosticsLogger.shared` to stream latency breaches or failures into your telemetry pipeline:

    ```swift
      let token = DiagnosticsLogger.shared.addObserver { event in
          print("HomeKit", event.operation.rawValue, event.outcome, event.metadata)
      }
    ```
- Pair the emitted metadata with the appropriate Developer Apple troubleshooting guidance to drive actionable UI, alerts, or retry policies.

## Documentation Updates
- After schema updates, add hyperlinks to the corresponding Developer Apple Context7 service and characteristic pages in README and CHANGELOG.
- Regenerate DocC documentation (future enhancement) to keep public API references current.
