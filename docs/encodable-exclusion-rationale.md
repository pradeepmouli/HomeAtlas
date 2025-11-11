# Encodable Exclusion Rationale

This document explains why SwiftHomeKit wrapper classes cannot conform to `Encodable` and provides alternative approaches for serialization needs.

## Why Wrappers Are Not Encodable

All SwiftHomeKit wrapper classes store `underlying` properties referencing Apple HomeKit framework types:

- `Accessory` → `HMAccessory`
- `Service` → `HMService`
- `Characteristic<Value>` → `HMCharacteristic`
- `Home` → `HMHome`
- `Room` → `HMRoom`
- `Zone` → `HMZone`

**Apple's HomeKit framework types do not conform to `Codable`** because:
1. They represent live connections to physical accessories
2. They contain delegates, callbacks, and runtime state
3. They reference native Objective-C objects not designed for serialization

Per SwiftHomeKit Constitution Principle I (Type-Safe APIs), we cannot:
- Leak `Any` types during encoding
- Use custom serialization that loses type information
- Bypass Swift's type system

Per FR-002 feasibility criteria:
- ❌ Stored properties are NOT all Encodable
- ❌ `HMAccessory`, `HMService`, etc. cannot be encoded
- ❌ No feasible conformance path exists

## Alternative: Value-Type DTOs

For diagnostics, logging, or export scenarios requiring serialization, create separate Data Transfer Objects (DTOs):

```swift
/// Encodable snapshot of Accessory state for diagnostics/export.
public struct AccessorySnapshot: Codable {
    public let name: String
    public let uniqueIdentifier: UUID
    public let isReachable: Bool
    public let categoryType: String
    public let serviceTypes: [String]

    public init(from accessory: Accessory) {
        self.name = accessory.name
        self.uniqueIdentifier = accessory.uniqueIdentifier
        self.isReachable = accessory.isReachable
        self.categoryType = accessory.category.categoryType
        self.serviceTypes = accessory.allServices().map(\.serviceType)
    }
}

// Usage:
let snapshot = AccessorySnapshot(from: myAccessory)
let data = try JSONEncoder().encode(snapshot)
```

### Benefits of DTO Approach

✅ **Type-Safe**: All properties are simple value types (String, UUID, Bool, Array)
✅ **Encodable**: Straightforward `Codable` conformance
✅ **Flexible**: Choose which properties to serialize
✅ **Testable**: DTO round-trip tests are simpler than wrapper tests
✅ **Constitution Compliant**: No `Any` leakage, maintains type-safety

### When to Use DTOs

- **Diagnostics**: Serialize accessory/service state for bug reports
- **Analytics**: Export configuration snapshots for analysis
- **Logging**: Persist HomeKit state for debugging
- **Testing**: Create fixtures from live HomeKit data

## Success Criteria Update

Original **SC-002**: "At least 90% of wrapper classes conform to `Encodable` or have documented reasons for exclusion."

**Result**: 0% conform, 100% excluded with documented rationale (this file + `docs/encodable-audit.md`).

**Rationale Documented**:
- Primary: HomeKit framework types not Codable
- Secondary: Wrappers are runtime references, not data models
- Alternative: DTO pattern recommended for serialization needs

## References

- **Apple Developer**: HomeKit framework types (HMAccessory, HMService, etc.) do not conform to Codable
- **SwiftHomeKit Constitution Principle I**: Type-Safe APIs without `Any` leakage
- **Spec FR-002**: Conformance feasibility criteria
- **Spec FR-003**: Document exclusion rationale (this file)
