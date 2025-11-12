# HomeAtlas v0.2.0 – Rebrand & Deterministic Snapshot Export

## 🚀 Highlights

- **HomeAtlas Rebrand**: All modules, docs, and tools now use the HomeAtlas name (formerly SwiftHomeKit).
- **Deterministic Snapshot Export**: New API to export HomeKit graphs to stable, privacy-aware JSON for diagnostics, backup, and support.
- **Typed Snapshots with Macros**: Swift 6 macros generate type-safe snapshot types for HomeKit entities.
- **Platform Safety**: Graceful fallback and error reporting on non-HomeKit platforms.
- **Performance**: Snapshot export completes in <2s for 100+ accessories; latency benchmarks included.

## ✨ New Features

- `HomeAtlas.encodeSnapshot(_:options:) async throws -> Data` – Export HomeKit home graphs to JSON.
- `SnapshotOptions(anonymize:)` – Redact names/IDs for privacy.
- Typed snapshot models for Home, Room, Zone, Accessory, Service, Characteristic.
- Deterministic ordering and stable key output for reproducible exports.

## 🛡️ Platform & Safety

- `#if canImport(HomeKit)` guards for all HomeKit-dependent code.
- Fallback error (`HomeKitError.platformUnavailable`) on unsupported platforms.
- 59 tests, including platform safety and performance benchmarks.

## 📚 Documentation

- Updated README, quickstart, and reference docs for HomeAtlas branding and new APIs.
- Privacy, error handling, and performance notes included.
- Apple Developer references for all HomeKit API behaviors.

## 📝 Migration

- All `SwiftHomeKit` references replaced with `HomeAtlas`.
- See CHANGELOG.md and docs/migration-homeatlas.md for details.

## 🧪 Validation

- All tests passing.
- Performance: ~1ms latency for snapshot operations in test suite.
