# Service Extension Workflow

This document describes the SDK-driven workflow for extending SwiftHomeKit with new HomeKit services and characteristics.

## Overview

SwiftHomeKit uses a two-stage code generation pipeline:

1. **SDK Extraction**: Parse the iOS SDK to extract canonical HomeKit metadata
2. **Service Generation**: Generate strongly-typed Swift wrappers from the extracted catalog

This approach ensures that service definitions stay synchronized with Apple's official HomeKit framework releases.

## Prerequisites

- Xcode 16.0+ with iOS SDK
- Swift 6.0+
- Access to HomeKit framework headers in the iOS SDK

## Workflow

### Stage 1: Extract HomeKit Catalog from SDK

The `HomeKitCatalogExtractor` tool parses the iOS SDK to generate a normalized YAML catalog:

```bash
# Extract from default iOS SDK location
swift run homekit-catalog-extractor \
  /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
  --output Resources/homekit-services.yaml
```

#### Optional: Include Runtime Metadata

For enhanced metadata (service/characteristic descriptions, constraints), provide optional sources:

```bash
swift run homekit-catalog-extractor \
  <SDK_PATH> \
  --output Resources/homekit-services.yaml \
  --metadata /System/Library/PrivateFrameworks/HomeKitDaemon.framework/Resources/plain-metadata.config \
  --simulator "/Applications/HomeKit Accessory Simulator.app"
```

**What the extractor does:**

1. **Header Parsing**: Analyzes `HomeKit.framework/Headers/*.h` using Clang to extract service/characteristic type constants
2. **TBD Validation**: Parses `HomeKit.tbd` to validate exported symbols match header declarations
3. **Metadata Inspection**: If provided, extracts human-readable descriptions and constraints from runtime metadata sources
4. **YAML Generation**: Outputs normalized catalog to `Resources/homekit-services.yaml`

**Output Format** (`Resources/homekit-services.yaml`):

```yaml
services:
  - type: "00000043-0000-1000-8000-0026BB765291"
    name: "Lightbulb"
    description: "A light source that can be turned on/off and dimmed."
    characteristics:
      - type: "00000025-0000-1000-8000-0026BB765291"
        name: "On"
        format: "bool"
        permissions: ["read", "write", "notify"]
      - type: "00000008-0000-1000-8000-0026BB765291"
        name: "Brightness"
        format: "int"
        unit: "percentage"
        permissions: ["read", "write", "notify"]
```

### Stage 2: Generate Swift Service Wrappers

The `HomeKitServiceGenerator` tool consumes the YAML catalog and emits Swift source files:

```bash
swift run homekit-service-generator \
  Resources/homekit-services.yaml \
  --output Sources/SwiftHomeKit/Generated
```

**What the generator does:**

1. **Catalog Parsing**: Loads YAML and validates service/characteristic schema
2. **SwiftSyntax Emission**: Generates strongly-typed service classes with:
   - Generic `Characteristic<T>` wrappers for each property
   - `@MainActor` accessors for thread safety
   - Developer Apple documentation links
3. **Type Constants**: Creates reference files for UUID type constants
4. **Output Organization**: Writes files to `Sources/SwiftHomeKit/Generated/`

**Generated Code Example** (simplified):

```swift
import HomeKit

/// A light source that can be turned on/off and dimmed.
///
/// - Reference: [Apple Developer - HMServiceTypeLightbulb](https://developer.apple.com/documentation/homekit/hmservicetypelightbulb)
@MainActor
public final class LightbulbService: Service {
    public static let serviceType = "00000043-0000-1000-8000-0026BB765291"

    public var on: Characteristic<Bool> {
        characteristic(ofType: "00000025-0000-1000-8000-0026BB765291")
    }

    public var brightness: Characteristic<Int>? {
        characteristic(ofType: "00000008-0000-1000-8000-0026BB765291")
    }
}
```

## Adding New Services

When Apple introduces new HomeKit services in an iOS SDK update:

1. **Update Catalog**: Re-run the extractor against the new SDK:
   ```bash
   swift run homekit-catalog-extractor <NEW_SDK_PATH> --output Resources/homekit-services.yaml
   ```

2. **Regenerate Wrappers**: Re-run the generator:
   ```bash
   swift run homekit-service-generator Resources/homekit-services.yaml
   ```

3. **Validate Parity**: Run integration tests to ensure generated code matches SDK:
   ```bash
   swift test --filter GeneratedParityTests
   ```

4. **Commit Changes**: Include both the updated YAML catalog and generated Swift files in version control

## Manual Service Definitions

For services requiring custom behavior beyond autogeneration (e.g., complex state management), create manual wrappers in `Sources/SwiftHomeKit/` that subclass `Service` directly:

```swift
@MainActor
public final class CustomService: Service {
    public static let serviceType = "<UUID>"

    // Custom implementation with stateful logic
}
```

Exclude manually-defined services from the YAML catalog to prevent generation conflicts.

## Verification & Testing

### Parity Tests

The `GeneratedParityTests` suite validates that:

- Every service in the YAML catalog has a corresponding Swift class
- Generated characteristic accessors match catalog metadata
- Type UUIDs align with SDK constants
- Developer Apple documentation links are present

Run with:

```bash
swift test --filter GeneratedParityTests
```

### Integration Tests

Validate generated services work with real HomeKit accessories:

```bash
swift test --filter LightbulbControlTests
```

## Troubleshooting

### Extraction Issues

**Problem**: Extractor fails with "HomeKit.framework not found"

**Solution**: Verify SDK path points to a valid iOS SDK:
```bash
ls /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/
```

**Problem**: Missing service descriptions in generated YAML

**Solution**: Provide optional metadata sources via `--metadata` and `--simulator` flags for enhanced documentation.

### Generation Issues

**Problem**: Generator fails with "Invalid catalog schema"

**Solution**: Validate YAML syntax and ensure it matches the expected schema. Check for typos in service/characteristic UUIDs.

**Problem**: Generated code fails to compile

**Solution**: Ensure `Service` and `Characteristic` base types exist in `Sources/SwiftHomeKit/` and are `@MainActor`-annotated.

## Developer Apple References

- [HomeKit Framework Documentation](https://developer.apple.com/documentation/homekit)
- [HMService Class Reference](https://developer.apple.com/documentation/homekit/hmservice)
- [HMCharacteristic Class Reference](https://developer.apple.com/documentation/homekit/hmcharacteristic)
- [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/specification/)

---

**Last Updated**: November 9, 2025
**Related**: [Troubleshooting Guide](troubleshooting.md), [Quick Start](../specs/001-create-homekit-wrapper/quickstart.md)
