# Encodable Audit: SwiftHomeKit

**Status**: T011 Complete - Audit findings documented
**Date**: 2025-11-10

Tracks Encodable feasibility and decisions for wrapper classes per Spec §FR-002.

## Guidelines

- Conform when all stored properties are Encodable and no `Any` types are present
- Maintain type-safety; no `Any` leakage (Constitution Principle I)
- Add encode/decode parity tests for each Encodable wrapper (Constitution Principle IV)
- Feasibility criteria (FR-002): (1) all stored properties Encodable, (2) no `Any` types, (3) parity tests pass

## Core Wrappers

| Type | File | Encodable | Stored Properties | Decision | Notes |
|------|------|-----------|-------------------|----------|-------|
| **Accessory** | `Sources/SwiftHomeKit/Accessory.swift` | ❌ No | `underlying: HMAccessory`, `serviceCache: [UUID: AnyObject]` | **Exclude** | `HMAccessory` is not Encodable; `serviceCache` contains `AnyObject`. Runtime state, not serializable data. |
| **Service** | `Sources/SwiftHomeKit/Service.swift` | ❌ No | `underlying: HMService`, `characteristicCache: [UUID: CharacteristicCacheEntry]` | **Exclude** | `HMService` not Encodable; cache is runtime state. Base class for generated services. |
| **Characteristic<Value>** | `Sources/SwiftHomeKit/Characteristic.swift` | ❌ No | `underlying: HMCharacteristic` | **Exclude** | `HMCharacteristic` not Encodable. Generic over `Value`, difficult to encode type-safely without custom strategy. |
| **HomeKitManager** | `Sources/SwiftHomeKit/HomeKitManager.swift` | ❌ No | `underlying: HMHomeManager`, caches | **Exclude** | Manager/controller type, not a data model. |
| **HomeKitError** | `Sources/SwiftHomeKit/HomeKitError.swift` | ⚠️ Consider | Associated values vary | **Defer** | Error types can be Encodable for diagnostics serialization. Requires careful handling of `Error`-typed payloads. Evaluate in future iteration. |
| **DiagnosticsLogger** | `Sources/SwiftHomeKit/DiagnosticsLogger.swift` | ❌ No | Observers, state | **Exclude** | Logger/singleton, not a data model. |

### Context Entities

| Type | File | Encodable | Stored Properties | Decision | Notes |
|------|------|-----------|-------------------|----------|-------|
| **Home** | `Sources/SwiftHomeKit/Context/Home.swift` | ❌ No | `underlying: HMHome` | **Exclude** | `HMHome` not Encodable. Wrapper for runtime HomeKit state. |
| **Room** | `Sources/SwiftHomeKit/Context/Room.swift` | ❌ No | `underlying: HMRoom` | **Exclude** | `HMRoom` not Encodable. Wrapper for runtime HomeKit state. |
| **Zone** | `Sources/SwiftHomeKit/Context/Zone.swift` | ❌ No | `underlying: HMZone` | **Exclude** | `HMZone` not Encodable. Wrapper for runtime HomeKit state. |

## Generated Services

Generated service wrappers (e.g., `LightbulbService`, `ThermostatService`) all inherit from `Service` and store `underlying: HMService`.

**Analysis**: All generated services are **excluded** because:
1. Inherit `Service` base class which stores non-Encodable `HMService`
2. Runtime wrappers around HomeKit framework types
3. No independent state beyond references to framework objects

| Type | File | Encodable | Inherits | Decision |
|------|------|-----------|----------|----------|
| LightbulbService | `Sources/SwiftHomeKit/Generated/Services/LightbulbService.swift` | ❌ No | Service | **Exclude** |
| ThermostatService | `Sources/SwiftHomeKit/Generated/Services/ThermostatService.swift` | ❌ No | Service | **Exclude** |
| *All 45 generated services* | `Sources/SwiftHomeKit/Generated/Services/*.swift` | ❌ No | Service | **Exclude** |

## Generated Characteristics

Generated characteristic wrappers inherit from `Characteristic<Value>` generic class.

**Analysis**: All generated characteristics are **excluded** because:
1. Inherit `Characteristic<Value>` which stores non-Encodable `HMCharacteristic`
2. Runtime wrappers around HomeKit framework types

## Alternative: Value-Type DTOs

**Recommendation**: If serialization is needed for diagnostics/export, create separate value-type DTOs that extract encodable properties:

```swift
public struct AccessorySnapshot: Codable {
    let name: String
    let uniqueIdentifier: UUID
    let isReachable: Bool
    let categoryType: String
    
    init(from accessory: Accessory) {
        self.name = accessory.name
        self.uniqueIdentifier = accessory.uniqueIdentifier
        self.isReachable = accessory.isReachable
        self.categoryType = accessory.category.categoryType
    }
}
```

This approach:
- ✅ Maintains type-safety (no `Any`)
- ✅ Encodable conformance is straightforward
- ✅ Separates runtime wrappers from serializable snapshots
- ✅ Allows selective property serialization

## Summary

**Audit Result**: 0 wrapper classes conform to Encodable (0% conformance).

**Reason**: All wrappers store non-Encodable HomeKit framework types (`HMAccessory`, `HMService`, `HMCharacteristic`, etc.) as their `underlying` property. These are reference types from Apple's HomeKit framework that do not conform to `Codable`.

**Conformance is not feasible** per FR-002 criteria:
- ❌ Stored properties are NOT all Encodable (framework types)
- ❌ Cannot encode `underlying` without losing type-safety

**Recommendation**: Document exclusion rationale per FR-003. If serialization is required, implement value-type DTO snapshots as shown above.
