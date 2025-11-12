# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.2.0] - 2025-11-11
### Added
- **HomeAtlas Rebrand**: Renamed package from SwiftHomeKit to HomeAtlas
  - Updated package name, library product, and all imports
  - Renamed source directories and main types
  - Updated all documentation and examples
- **Macro-Based Typed Snapshots**: Introduced `@Snapshotable` macro for type-safe snapshot generation
  - Applied to Home, Room, Zone, Accessory, Service classes
  - Generates `*AtlasSnapshot` structs that preserve type information
  - Supports typed characteristic fields in service snapshots (e.g., `Bool?`, `Int?`, `Double?`)
  - Includes nested snapshot structures with deterministic ordering
- **AtlasSnapshot Encoder**: New bridging encoder for converting HMHome graphs to typed snapshots
  - `AtlasSnapshotEncoder` class for typed snapshot generation
  - `HomeAtlas.encodeSnapshot(_:options:)` API for JSON export
  - Deterministic JSON output with sorted keys
- **Stable Anonymization**: FNV-1a-based deterministic anonymization for privacy
  - `StableAnonymizer` helper for reproducible hashing
  - Process-independent anonymization tokens
  - Configurable via `SnapshotOptions.anonymize`
- **Characteristic Value Mapping**: Auto-generated mapping from characteristic wrappers to value types
  - Generator produces mapping consumed by macro
  - 138 characteristics mapped to concrete Swift types
  - Placeholder fallback if generator hasn't run
- **Platform Safety**: Comprehensive platform guards and fallback implementations
  - Graceful compilation on non-HomeKit platforms
  - `HomeKitError.platformUnavailable` for unsupported operations
  - Platform-specific test coverage (56 tests passing)
- **Code Generator Enhancements**:
  - Updated to annotate all generated services with `@Snapshotable`
  - Generates characteristic value type mappings for macro consumption
  - Updated default output path to `Sources/HomeAtlas/Generated`

### Changed
- **Package Identity**: Migrated from SwiftHomeKit to HomeAtlas throughout codebase
- **Snapshot Model Naming**: All snapshot types now use `*AtlasSnapshot` suffix
- **API Surface**: Extended snapshot capabilities beyond generic DTOs to typed structures
- **Documentation**: Updated README with HomeAtlas branding and snapshot export examples
- **Test Suite**: Expanded from 53 to 56 tests with platform safety coverage

### Fixed
- Macro test formatting mismatches resolved
- Platform guard coverage audited and verified
- Deterministic sorting applied to all snapshot collections

## [0.1.0] - 2025-11-10
### Added
- Initial SwiftPM package structure
- HomeKit wrapper scaffolding with type-safe APIs (@MainActor)
- Test infrastructure for encode/decode parity (template)
- Documentation updates for SPI release readiness
