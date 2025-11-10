# Developer Apple Reference Index

This document serves as a comprehensive index of Apple Developer documentation references used throughout SwiftHomeKit. All citations link to canonical HomeKit framework documentation.

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

## Citation Format

All Developer Apple references in SwiftHomeKit source code follow this format:

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

**Last Updated**: November 9, 2025
**Related**: [Service Extension](service-extension.md), [Troubleshooting Guide](troubleshooting.md)
