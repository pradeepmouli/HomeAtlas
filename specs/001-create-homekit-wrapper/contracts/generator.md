# Contract: HomeKit Schema Generator

**Status**: Not yet implemented. US3 requires SDK extraction approach.

## Planned Architecture

### SDK Catalog Extraction
- **Tool**: `homekit-catalog-extractor`
- **Purpose**: Extract service/characteristic metadata directly from iOS SDK
- **Inputs**:
  - `HMServiceTypes.h` - Service type constant declarations
  - `HMCharacteristicTypes.h` - Characteristic type constant declarations
  - `HomeKit.tbd` - Exported symbol table for validation
- **Output**: `Resources/homekit-services.yaml` - Normalized catalog

### Code Generation
- **Tool**: `homekit-catalog-gen`
- **Purpose**: Generate strongly-typed service wrappers from catalog
- **Input**: `Resources/homekit-services.yaml`
- **Output**: `Sources/SwiftHomeKit/Generated/*.swift`

### Plugin Integration
- **Plugin**: `SwiftHomeKitPlugin`
- **Command**: `swift package generate-homekit`
- **Behavior**: Orchestrates extraction → generation pipeline

## Implementation Status

### ✅ Completed (US1)
- Base wrapper classes (`Characteristic`, `Service`, `Accessory`)
- `HomeKitManager` for discovery
- Type constants (`ServiceType`, `CharacteristicType`)
- Integration tests

### ❌ Not Implemented (US3)
- SDK header parser
- `.tbd` symbol extractor
- Catalog YAML generator
- SwiftSyntax-based service generator
- Package plugin

## Next Steps

1. Implement header parser to extract constants from SDK `.h` files
2. Implement `.tbd` parser to validate exported symbols
3. Merge header + tbd data into YAML catalog
4. Build SwiftSyntax generator for service classes
5. Create package plugin to automate pipeline

## Design Notes

Per the plan, the catalog must be **SDK-derived**, not manually curated:
> "Author a clang-backed utility that consumes HMServiceTypes.h, HMCharacteristicTypes.h, and related headers from the active iOS SDK to emit normalized JSON"

The generator will create services that subclass our base `Service` class and expose typed `Characteristic<T>` properties.
