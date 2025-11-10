# Feature Specification: Strongly Typed HomeKit Wrapper

**Feature Branch**: `001-create-homekit-wrapper`
**Created**: 2025-11-08
**Status**: In Progress (US1 ✅ Complete, US2 ✅ Complete, US3 ⏳ Pending, US4 ⏳ Planned)
**Input**: User description: "Build a strongly-typed Swift wrapper for Apple HomeKit. Please ask for clarifications on exact approach if needed."

## Implementation Status

### Completed (US1)
- ✅ Base wrapper classes: `Characteristic<Value>`, `Service`, `Accessory`
- ✅ `HomeKitManager` with async/await discovery
- ✅ `@MainActor` enforcement on all HomeKit operations
- ✅ Type constants: `ServiceType`, `CharacteristicType`
- ✅ Cross-platform support with conditional compilation
- ✅ Integration tests (7/8 passing, 1 skipped pending generated services)

### In Progress (US3)
- ⏳ SDK header parser for `.h` files
- ⏳ Symbol extractor for `HomeKit.tbd`
- ⏳ YAML catalog generator
- ⏳ SwiftSyntax service generator
- ⏳ SwiftPM build plugin

## User Scenarios & Testing *(mandatory)*

> Constitution Alignment: Describe the typed HomeKit APIs involved, required MainActor/async behaviour, planned tests, documentation updates, and reference Developer Apple Context7 (`developer_apple`, HomeKit topic) when citing platform behaviour.

### User Story 1 - Compile-Time Accessory Control (Priority: P1) ✅

**Status**: Complete

Swift integrators need to read and write HomeKit characteristics through strongly typed APIs so they can ship reliable accessory control without runtime casting errors.

**Implementation**:
- `Characteristic<Value>` provides generic type-safe read/write operations
- `Service` offers `characteristic<Value>(ofType:)` for type-safe characteristic access
- `Accessory` wraps `HMAccessory` with `service(ofType:)` lookups
- `HomeKitManager` handles async discovery with `@MainActor` enforcement

**Tests**: 7/8 integration tests passing, validating base wrapper behavior and type safety.

**Acceptance Scenarios**:

1. ✅ **Given** a developer using the typed wrapper, **When** they request `Characteristic<Bool>` for a service, **Then** the API returns a Bool-typed accessor and type mismatches fail at compile time.
2. ✅ **Given** an accessory on the main thread, **When** the developer writes through the wrapper, **Then** the call executes within `@MainActor` using async/await without blocking UI.

---

### User Story 2 - Deterministic Error Insights (Priority: P2) ✅

**Status**: Complete

As a HomeKit library maintainer, I need the wrapper to surface actionable error cases with accessory metadata so downstream apps can recover or inform users quickly.

**Implementation**:
- Unified `HomeKitError` hierarchy with accessory, service, and characteristic context.
- `DiagnosticsLogger` that captures latency and failure metadata for every HomeKit interaction.
- Accessory and characteristic wrappers translate HomeKit callbacks into context-rich errors while emitting diagnostics events.

**Acceptance Scenarios**:

1. ✅ Transport failure error with accessory metadata.
2. ✅ Diagnostic logging for operations exceeding latency thresholds.

---

### User Story 3 - Extensible Service Coverage (Priority: P3) ⏳

**Status**: Architecture ready; autogeneration not implemented

Framework adopters want guidance and scaffolding to add new HomeKit services without breaking existing typed guarantees.

**Current Implementation**:
- Open `Service` class ready for subclassing
- Open `Characteristic<Value>` class ready for specialization
- Base wrapper tests demonstrate extension pattern

**Pending**:
- SDK header parser extracting service/characteristic definitions
- YAML catalog generator
- SwiftSyntax service class generator
- SwiftPM plugin orchestration

**Acceptance Scenarios**:

1. ⏳ Generate service wrappers from SDK headers
2. ⏳ Documentation with SDK cross-references

---

### User Story 4 - Context Entities & Cache Lifecycle (Priority: P3) ⏳

**Status**: Planned

HomeKit developers want typed access to homes, rooms, and zones plus predictable cache lifecycle controls so wrapper instances remain stable and can be eagerly prepared when needed.

**Implementation (planned)**:
- Manual `HMHome`, `HMRoom`, and `HMZone` wrappers under `Sources/SwiftHomeKit/Context/` with `@MainActor` accessors mirroring Developer Apple naming.
- Cache warm-up and reset APIs on `Service`, `Accessory`, and `HomeKitManager` so apps can eagerly initialize wrappers or clear stale state in response to delegate callbacks.
- Diagnostics integration ensuring cache operations emit metadata when warm-up exceeds latency thresholds.

**Acceptance Scenarios**:

1. ⏳ **Given** a developer requests `RoomWrapper` for a known room, **When** the room is looked up via `HomeKitManager`, **Then** the wrapper reuses cached instances across repeated calls and surfaces room metadata documented by Developer Apple Context7 (`developer_apple`, HomeKit > HMRoom).
2. ⏳ **Given** caches are warmed via the new API, **When** an accessory is removed from HomeKit, **Then** cache reset prunes stale wrappers and diagnostics emit a `cache.reset` event referencing the affected identifiers.

### Edge Cases

- Accessory reports a characteristic with metadata that changed in a recent HomeKit revision; wrapper must reconcile with cached type definitions or flag the mismatch gracefully.
- HomeKit responds with localized metadata or optional characteristic ranges missing from Developer Apple Context7 documentation; wrapper must fall back to safe defaults without crashing.
- App builds on a simulator or platform without HomeKit entitlement; wrapper must compile and execute fallback tests that stub characteristic interactions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001** ✅: The wrapper surfaces HomeKit accessories, services, and characteristics as strongly typed Swift constructs (base classes `Characteristic<Value>`, `Service`, `Accessory` implemented).
- **FR-002** ✅: The library provides compile-time checked accessor methods for read/write operations that reject unsupported type casts before runtime (generic `Characteristic<Value>` enforces type safety).
- **FR-003** ✅: `@MainActor` enforcement guards all HomeKit interactions (all public APIs annotated `@MainActor`).
- **FR-004** ✅: All fallible operations resolve to a `HomeKitError` hierarchy with contextual diagnostics.
- **FR-005** ✅: The project supplies sample usage and integration tests demonstrating end-to-end flows and fallback compilation when HomeKit is unavailable (7/8 tests passing).
- **FR-006** ⏳: Service coverage scope will mirror the complete HomeKit services catalog with autogeneration workflow (US3 pending SDK extraction).
- **FR-007** ✅: Distribution ships as a Swift Package Manager library (Package.swift configured).
- **FR-TYPE** ✅: Implementation exposes strongly typed HomeKit interfaces without leaking `Any`.
- **FR-CONCUR** ✅: Implementation specifies MainActor/async strategy for every HomeKit call.
- **FR-DOCS** ⏳: Documentation to be updated with examples and platform notes (pending US3 completion).
- **FR-008** ⏳: Provide typed wrappers for `HMHome`, `HMRoom`, and `HMZone` along with cache warm-up/reset APIs on `Service`, `Accessory`, and `HomeKitManager` that maintain wrapper identity across delegate updates.

### Non-Functional Requirements

- **NFR-001** ⏳: Instrument characteristic read/write/notification flows so 95% of operations complete within 200 ms on physical accessories, recording latency metrics through `DiagnosticsLogger` and asserting thresholds in integration tests.

### Key Entities *(include if feature involves data)*

**Implemented (US1)**:
- **`Characteristic<Value>`**: Generic open class wrapping `HMCharacteristic` with type-safe async read/write operations
- **`Service`**: Open base class wrapping `HMService` with characteristic accessor methods
- **`Accessory`**: Final wrapper for `HMAccessory` providing service access and async operations
- **`HomeKitManager`**: MainActor-bound manager for home/accessory discovery with ObservableObject pattern

**Planned (US3)**:
- **SDK Catalog**: YAML representation extracted from iOS SDK headers and `.tbd` files
- **Generated Services**: Autogenerated service subclasses (e.g., `LightbulbService`, `ThermostatService`) with typed characteristic properties

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001** ✅: Base wrapper APIs enable type-safe accessory control without runtime casting (generic `Characteristic<Value>` implemented and tested).
- **SC-002** ⏳: Latency instrumentation captures percentile metrics via integration tests, proving 95% of helper invocations stay under 200 ms on sample accessories.
- **SC-003** ⏳: Error diagnostics tests assert that every `HomeKitError` case emits accessory, service, and characteristic metadata with zero missing-context warnings.
- **SC-004** ⏳: Documentation validation pending US3 completion.
- **SC-HK-001** ✅: Integration tests pass for base wrappers; fallback compilation succeeds on non-HomeKit platforms (7/8 tests passing, conditional compilation verified).
- **SC-005** ⏳: Cache lifecycle tests confirm wrapper reuse across repeated lookups and validate warm-up/reset hooks emit diagnostics events with Developer Apple references.

## Assumptions & Dependencies

- iOS SDK headers (`HMServiceTypes.h`, `HMCharacteristicTypes.h`) and `HomeKit.tbd` remain the source of truth for service/characteristic metadata used by the US3 autogeneration workflow.
- Access to HomeKit entitlements and compatible test accessories is available for validation.
- Downstream adopters rely on Swift Package Manager.
- US1 base wrapper architecture (open classes for subclassing) supports future code generation without breaking changes.
