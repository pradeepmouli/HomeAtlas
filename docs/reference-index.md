# Developer Apple Reference Index

This document serves as a comprehensive index of Apple Developer documentation references used throughout HomeAtlas. All citations link to canonical HomeKit framework documentation.

## Framework Overview

- **[HomeKit Framework](https://developer.apple.com/documentation/homekit)** - Coordinate and control home automation accessories
- **[Enabling HomeKit in your app](https://developer.apple.com/documentation/homekit/enabling-homekit-in-your-app)** - Setup entitlements and permissions

## Core Types

### Home Manager

- **[HMHomeManager](https://developer.apple.com/documentation/homekit/hmhomemanager)** - Manages a collection of user's homes
- **[HMHomeManagerDelegate](https://developer.apple.com/documentation/homekit/hmhomemanagerdelegate)** - Receives home manager state updates
- **[Configuring a home automation device](https://developer.apple.com/documentation/homekit/configuring-a-home-automation-device)** - Setup guide

### Context Entities

#### Home
- **[HMHome](https://developer.apple.com/documentation/homekit/hmhome)** - Represents a physical location
- **[HMHomeDelegate](https://developer.apple.com/documentation/homekit/hmhomedelegate)** - Receives home state updates
- **[HMHomeAccessControl](https://developer.apple.com/documentation/homekit/hmhomeaccesscontrol)** - User permission levels

#### Room
- **[HMRoom](https://developer.apple.com/documentation/homekit/hmroom)** - Represents a room within a home
- **[roomForEntireHome](https://developer.apple.com/documentation/homekit/hmhome/roomforentirehome)** - Default room for unassigned accessories

#### Zone
- **[HMZone](https://developer.apple.com/documentation/homekit/hmzone)** - Logical grouping of rooms
- **[Room for home cannot be in zone](https://developer.apple.com/documentation/homekit/hmerror/code/roomforhomecannotbeinzone)** - Architecture constraint

### Accessories

- **[HMAccessory](https://developer.apple.com/documentation/homekit/hmaccessory)** - Represents a home automation accessory
- **[HMAccessoryCategory](https://developer.apple.com/documentation/homekit/hmaccessorycategory)** - Categorizes accessory types
- **[HMAccessorySetupManager](https://developer.apple.com/documentation/homekit/hmaccessorysetupmanager)** - Manages new accessory setup
- **[Interacting with a home automation network](https://developer.apple.com/documentation/homekit/interacting-with-a-home-automation-network)** - Integration patterns

### Services

- **[HMService](https://developer.apple.com/documentation/homekit/hmservice)** - Represents a controllable feature
- **[HMServiceGroup](https://developer.apple.com/documentation/homekit/hmservicegroup)** - Groups related services
- **Service Type Constants**:
  - **[HMServiceTypeLightbulb](https://developer.apple.com/documentation/homekit/hmservicetypelightbulb)** - Light source control
  - **[HMServiceTypeThermostat](https://developer.apple.com/documentation/homekit/hmservicetypethermostat)** - Temperature control
  - **[HMServiceTypeOutlet](https://developer.apple.com/documentation/homekit/hmservicetypeoutlet)** - Power outlet control

### Characteristics

- **[HMCharacteristic](https://developer.apple.com/documentation/homekit/hmcharacteristic)** - Represents a specific characteristic
- **[HMCharacteristicMetadata](https://developer.apple.com/documentation/homekit/hmcharacteristicmetadata)** - Characteristic constraints
- **Characteristic Type Constants**:
  - **[HMCharacteristicTypePowerState](https://developer.apple.com/documentation/homekit/hmcharacteristictypepowerstate)** - On/off state
  - **[HMCharacteristicTypeBrightness](https://developer.apple.com/documentation/homekit/hmcharacteristictypebrightness)** - Brightness level
  - **[HMCharacteristicTypeCurrentTemperature](https://developer.apple.com/documentation/homekit/hmcharacteristictypecurrenttemperature)** - Temperature reading

## Automation

### Action Sets & Triggers

- **[HMActionSet](https://developer.apple.com/documentation/homekit/hmactionset)** - Collection of actions triggered together
- **[HMTimerTrigger](https://developer.apple.com/documentation/homekit/hmtimertrigger)** - Periodic time-based triggers
- **[HMEventTrigger](https://developer.apple.com/documentation/homekit/hmeventtrigger)** - Event and condition-based triggers

## Error Handling

- **[HMError](https://developer.apple.com/documentation/homekit/hmerror)** - HomeKit error structure
- **[HMError.Code](https://developer.apple.com/documentation/homekit/hmerror/code)** - Error code enumeration
- **[HMErrorDomain](https://developer.apple.com/documentation/homekit/hmerrordomain)** - Error domain identifier
- **Error Codes**:
  - **[connectionFailed](https://developer.apple.com/documentation/homekit/hmerror/code/connectionfailed)** - Accessory connection failure
  - **[communicationFailure](https://developer.apple.com/documentation/homekit/hmerror/code/communicationfailure)** - Communication error
  - **[invalidParameter](https://developer.apple.com/documentation/homekit/hmerror/code/invalidparameter)** - Invalid input

## Testing

- **[HomeKit Accessory Simulator](https://developer.apple.com/documentation/homekit/testing-your-app-with-the-homekit-accessory-simulator)** - Test accessories without hardware
- **[HMAccessorySetupPayload](https://developer.apple.com/documentation/homekit/hmaccessorysetuppayload)** - Authentication payload

## Entitlements & Privacy

- **[HomeKit Entitlement](https://developer.apple.com/documentation/homekit)** - Enable HomeKit capability (`com.apple.developer.homekit`)
- **[NSHomeKitUsageDescription](https://developer.apple.com/documentation/homekit/enabling-homekit-in-your-app)** - Privacy usage string

## Platform Availability

- **iOS**: 8.0+
- **iPadOS**: 8.0+
- **macOS**: 10.14+ (via Mac Catalyst)
- **tvOS**: 10.0+
- **watchOS**: 2.0+
- **visionOS**: 1.0+

## Additional Resources

- **[HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/specification/)** - Technical protocol details
- **[App Store Review Guidelines - HomeKit](https://developer.apple.com/app-store/review/guidelines/#homekit)** - Submission requirements
- **[WWDC Videos on HomeKit](https://developer.apple.com/videos/frameworks/homekit)** - Developer sessions

---

## Snapshot Export API

### Overview

The Snapshot Export API allows developers to serialize HomeKit home graphs to deterministic JSON format for debugging, backups, and data export scenarios.

- **Public API**: `HomeAtlas.encodeSnapshot(_:options:) async throws -> Data`
- **Purpose**: Export Home entities, relationships, and state to JSON
- **Thread Safety**: `@MainActor` annotation ensures main-thread execution (required for HomeKit API access)
- **Performance**: Typical export time ≤2 seconds for ~100 accessories with ~1000 characteristics

### Usage

```swift
import HomeAtlas
import HomeKit

@MainActor
func exportHomeSnapshot(_ home: HMHome) async throws {
    // Basic export
    let jsonData = try await HomeAtlas.encodeSnapshot(home)

    // With anonymization for privacy
    let options = SnapshotOptions(anonymize: true)
    let anonymizedData = try await HomeAtlas.encodeSnapshot(home, options: options)

    // Save to file
    try jsonData.write(to: URL(fileURLWithPath: "home-snapshot.json"))
}
```

### Typed Snapshots with Macros (HomeAtlas)

Swift 6 macros generate type-safe snapshot types for HomeAtlas classes using `@Snapshotable`.
Generated types are suffixed with `AtlasSnapshot` to avoid conflicts with generic snapshot models.

```swift
@Snapshotable
public final class LightbulbService: Service { /* ... */ }

// Generated by macro:
public struct LightbulbServiceAtlasSnapshot: Codable, Sendable { /* typed fields */ }

// Example usage (async):
@MainActor
func captureTypedServiceSnapshot(_ service: LightbulbService) async throws -> LightbulbServiceAtlasSnapshot {
  try await LightbulbServiceAtlasSnapshot(from: service)
}
```

Applies to: Home, Room, Zone, Accessory, Service subclasses, Characteristic subclasses.

### Snapshot Options

- **`SnapshotOptions.anonymize`**: When `true`, redacts user-identifiable names and UUIDs while preserving structure
  - Home/Room/Accessory/Service names are hashed
  - UUIDs remain intact for relationship tracking
  - Metadata (manufacturer, model, firmware) preserved

### Output Schema

JSON output follows the [HomeAtlas Home Snapshot Schema](https://homeatlas.dev/schemas/home-snapshot.schema.json):

```json
{
  "id": "home-uuid",
  "name": "My Home",
  "rooms": [
    {
      "id": "room-uuid",
      "name": "Living Room",
      "accessories": [...]
    }
  ],
  "zones": [...],
  "metadata": null
}
```

### Characteristic Value Handling

Characteristics follow `@MainActor` read semantics per [HMCharacteristic.readValue()](https://developer.apple.com/documentation/homekit/hmcharacteristic/readvalu):

- **Readable characteristics**: Value captured if `properties` contains [HMCharacteristicPropertyReadable](https://developer.apple.com/documentation/homekit/hmcharacteristicpropertyreadable)
- **Permission-restricted**: `value: null, reason: "permission"` when read access denied
- **Unavailable devices**: `value: null, reason: "unavailable"` when device unreachable
- **Unknown errors**: `value: null, reason: "unknown"` for other failures

Reference: [Apple Developer - HMCharacteristic](https://developer.apple.com/documentation/homekit/hmcharacteristic)

### Deterministic Ordering

All entities sorted lexicographically by name to ensure stable JSON output across exports:

- Rooms sorted by `name` (ascending)
- Zones sorted by `name` (ascending)
- Accessories sorted by `name` (ascending)
- Services sorted by `serviceType`, then `name` (ascending)
- Characteristics sorted by `characteristicType` (ascending)

JSON keys output using `JSONEncoder.outputFormatting = .sortedKeys` for reproducibility.

### Platform Availability

```swift
#if canImport(HomeKit)
// Full snapshot export available on iOS 18+, macOS 15+, etc.
#else
// Fallback: throws HomeKitError.platformUnavailable
#endif
```

- **HomeKit platforms**: iOS 18.0+, macOS 15.0+, watchOS 11.0+, tvOS 18.0+
- **Non-HomeKit platforms**: API available but throws `HomeKitError.platformUnavailable` with descriptive reason

### Error Handling

All errors map to `HomeKitError` enum cases:

- **`.homeManagement(operation:underlying:)`**: Home/Room/Zone traversal failures
- **`.accessoryOperation(accessoryID:operation:)`**: Accessory/Service reading failures
- **`.characteristicOperation(characteristicID:operation:)`**: Characteristic value read failures
- **`.platformUnavailable(reason:)`**: HomeKit framework not available on current platform

Reference: [HomeKitError.swift](../Sources/HomeAtlas/HomeKitError.swift)

### Privacy Considerations

**Personally Identifiable Information (PII)** in snapshots:
- Home/Room/Zone/Accessory/Service names (user-defined strings)
- UUIDs (device-specific identifiers)

**Recommendation**: Use `SnapshotOptions(anonymize: true)` when sharing snapshots for debugging or support to redact PII.

### Performance Notes

- Export time scales linearly with accessory/characteristic count
- Typical performance: 100 accessories with 1000 characteristics export in <2 seconds
- Use `async` context to avoid blocking UI during large exports
- Consider background queue for very large homes (200+ accessories)

---

## Citation Format

All Developer Apple references in HomeAtlas source code follow this format:

```swift
/// Brief description.
///
/// - Reference: [Apple Developer - Type/Method Name](https://developer.apple.com/documentation/homekit/...)
```

For example:
```swift
/// A strongly-typed wrapper for HMAccessory.
///
/// - Reference: [Apple Developer - HMAccessory](https://developer.apple.com/documentation/homekit/hmaccessory)
@MainActor
public final class Accessory { ... }
```

---

**Last Updated**: November 11, 2025
**Related**: [Service Extension](service-extension.md), [Troubleshooting Guide](troubleshooting.md)
