# Feature Specification: TypeScript Bindings for HomeAtlas

**Feature Branch**: `004-add-typescript-bindings`
**Created**: 2026-01-16
**Status**: Draft
**Input**: User description: "Add TypeScript bindings for use in React Native/Expo and/or Velox"

## Clarifications

### Session 2026-01-18

- Q: What lifecycle states should the HomeAtlas module transition through during initialization and operation? → A: Four-state: uninitialized, ready, permission denied, error (explicit error states)
- Q: How should write operations handle confirmation of device state changes? → A: Configurable: Support both optimistic (immediate) and confirmed (wait for acknowledgment) modes
- Q: What level of observability should the module provide for debugging and monitoring? → A: Standard: Structured errors with semantic error codes + optional developer-facing debug logs
- Q: How should the module handle transient network or communication failures when interacting with HomeKit devices? → A: Auto-retry with exponential backoff: Attempt 1-3 retries with increasing delays for transient failures
- Q: Should the module cache HomeKit data (homes, accessories, characteristics) or fetch fresh data on every request? → A: In-memory only: Cache data in memory during app session, cleared when module reinitializes
- Q: Can existing TypeScript type libraries be used as reference for type definitions? → A: Yes, types from hap-fluent library can be used as a point of reference for the TypeScript bindings

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Discover and List Smart Home Devices (Priority: P1)

As a React Native/Expo developer, I want to discover all HomeKit accessories in the user's home so that I can display them in my mobile app's dashboard.

**Why this priority**: Device discovery is the foundational capability. Without it, no other smart home interactions are possible. This is the entry point for any HomeKit-enabled application.

**Independent Test**: Can be fully tested by initializing the HomeAtlas module and retrieving a list of accessories. Delivers immediate value by showing users their connected devices.

**Acceptance Scenarios**:

1. **Given** a user has granted HomeKit permissions, **When** the developer calls the initialization method, **Then** the module returns a list of all accessible homes and their accessories.
2. **Given** a user has multiple homes configured, **When** the developer queries for homes, **Then** each home is returned with its name, unique identifier, and accessory count.
3. **Given** accessories are organized into rooms, **When** the developer queries a home, **Then** room assignments are included for each accessory.
4. **Given** home structure has been queried once, **When** the developer queries again during the same session, **Then** cached data is returned without re-querying HomeKit (until module reinitializes).

---

### User Story 2 - Read Device State (Priority: P1)

As a React Native/Expo developer, I want to read the current state of HomeKit accessories (e.g., light on/off, thermostat temperature) so that I can display real-time device status to users.

**Why this priority**: Reading device state is essential for any smart home dashboard. Users need to see current conditions before making changes.

**Independent Test**: Can be fully tested by selecting a specific accessory and reading its characteristic values. Delivers value by showing current device states.

**Acceptance Scenarios**:

1. **Given** an accessory with a readable characteristic, **When** the developer requests the characteristic value, **Then** the current value is returned with its correct type (boolean, number, string).
2. **Given** an accessory is unreachable, **When** the developer attempts to read a characteristic, **Then** an appropriate error is returned indicating the device is offline.
3. **Given** a service has multiple characteristics, **When** the developer queries all characteristics, **Then** each characteristic is returned with its type, current value, and read/write capabilities.
4. **Given** a transient network failure occurs during a read operation, **When** the system retries with exponential backoff, **Then** the operation succeeds on retry or returns error after exhausting retry attempts.

---

### User Story 3 - Control Device State (Priority: P1)

As a React Native/Expo developer, I want to write new values to HomeKit accessories (e.g., turn lights on/off, set thermostat temperature) so that users can control their smart home from my app.

**Why this priority**: Device control is the primary value proposition of a smart home app. Without write capability, the app is merely informational.

**Independent Test**: Can be fully tested by writing a value to a writable characteristic and observing the physical device response. Delivers core smart home control functionality.

**Acceptance Scenarios**:

1. **Given** an accessory with a writable characteristic, **When** the developer writes a valid value, **Then** the device state changes and the operation completes successfully.
2. **Given** an accessory with a writable characteristic, **When** the developer writes an invalid value (out of range, wrong type), **Then** a descriptive error is returned without crashing.
3. **Given** multiple write operations are issued simultaneously, **When** all operations complete, **Then** each operation succeeds or fails independently with appropriate status.
4. **Given** a write operation is issued with optimistic mode, **When** the method is called, **Then** it returns immediately without waiting for device confirmation.
5. **Given** a write operation is issued with confirmed mode, **When** the method is called, **Then** it waits for and returns the device acknowledgment result.

---

### User Story 4 - Type-Safe Service Access (Priority: P2)

As a React Native/Expo developer, I want to access specific HomeKit service types (e.g., Lightbulb, Thermostat, Lock) with proper TypeScript typing so that I get autocomplete and compile-time safety in my code.

**Why this priority**: Type safety significantly improves developer experience and reduces runtime errors. However, basic functionality works without it.

**Independent Test**: Can be tested by importing service types and verifying TypeScript compiler catches invalid property access. Delivers developer productivity and code quality.

**Acceptance Scenarios**:

1. **Given** a TypeScript project using the bindings, **When** a developer accesses a Lightbulb service, **Then** TypeScript provides autocomplete for properties like `on`, `brightness`, and `hue`.
2. **Given** a developer attempts to access a non-existent property on a service, **When** the code is compiled, **Then** TypeScript reports a compile-time error.
3. **Given** a characteristic has a specific value type, **When** the developer reads or writes it, **Then** the TypeScript type matches the expected value type (boolean for on/off, number for brightness).

---

### User Story 5 - Subscribe to Real-Time Updates (Priority: P2)

As a React Native/Expo developer, I want to subscribe to characteristic change notifications so that my app automatically updates when device states change.

**Why this priority**: Real-time updates enhance user experience but apps can function with manual refresh. Essential for responsive dashboards.

**Independent Test**: Can be tested by subscribing to a characteristic, changing the physical device, and verifying the callback fires. Delivers live-updating UI capability.

**Acceptance Scenarios**:

1. **Given** a subscription is active on a characteristic, **When** the characteristic value changes, **Then** the registered callback is invoked with the new value.
2. **Given** multiple subscriptions exist, **When** the app wants to clean up, **Then** subscriptions can be removed individually or all at once.
3. **Given** a device becomes unreachable, **When** the connection is lost, **Then** an error event is emitted to subscribers.

---

### User Story 6 - Error Handling with Context (Priority: P2)

As a React Native/Expo developer, I want rich error information when operations fail so that I can display meaningful messages to users and debug issues effectively.

**Why this priority**: Good error handling improves both user experience and developer debugging. Essential for production apps but not required for initial prototyping.

**Independent Test**: Can be tested by intentionally causing failures and verifying error objects contain expected context. Delivers diagnosable error reporting.

**Acceptance Scenarios**:

1. **Given** an operation fails, **When** the error is caught, **Then** it includes semantic error code, human-readable message, and relevant context (accessory name, characteristic type).
2. **Given** a permission is denied, **When** the error is returned, **Then** it returns a PERMISSION_DENIED error code with a message suggesting resolution.
3. **Given** network/transport errors occur, **When** the error is returned, **Then** it uses distinct error codes for temporary (DEVICE_UNREACHABLE) and permanent failures.
4. **Given** debug logging is enabled, **When** operations execute, **Then** detailed diagnostic information is logged for developer troubleshooting.

---

### Edge Cases

- What happens when HomeKit permission is not granted? Error returned indicating permission required.
- What happens when a home has no accessories? Empty array returned, not an error.
- How does the system handle accessories added/removed while app is running? Re-query required; real-time home structure changes not automatically pushed.
- What happens when reading a write-only characteristic? Error indicating operation not supported.
- How are unsupported platforms handled? Clear error at initialization time indicating platform requirements.
- How are transient network failures handled? System automatically retries with exponential backoff (1-3 attempts); if all retries fail, error is returned to caller.
- How is cached data managed? Home structure data is cached in-memory only during the app session; no persistent storage. Cache is cleared when module reinitializes or app restarts.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a method to initialize HomeAtlas and request HomeKit permissions
- **FR-001a**: System MUST expose module state with four distinct states: uninitialized, ready, permission denied, error
- **FR-002**: System MUST expose home discovery with name, identifier, and accessory enumeration
- **FR-002a**: System MUST cache home structure data (homes, accessories, rooms, services) in memory during app session; cache is cleared on module reinitialization
- **FR-003**: System MUST allow querying accessories by name or unique identifier
- **FR-004**: System MUST expose accessory properties: name, identifier, reachability status, category
- **FR-005**: System MUST allow enumerating all services on an accessory
- **FR-006**: System MUST allow querying specific service types (e.g., Lightbulb, Thermostat)
- **FR-007**: System MUST allow reading characteristic values with proper type mapping
- **FR-008**: System MUST allow writing characteristic values with validation
- **FR-008a**: System MUST support both optimistic (immediate return) and confirmed (wait for device acknowledgment) write modes, configurable per operation
- **FR-009**: System MUST provide TypeScript type definitions for all HomeKit service types
- **FR-010**: System MUST provide TypeScript type definitions for all characteristic value types
- **FR-011**: System MUST support subscribing to characteristic change notifications
- **FR-012**: System MUST support unsubscribing from notifications (individually and globally)
- **FR-013**: System MUST return structured errors with semantic error codes, human-readable message, and contextual metadata
- **FR-013a**: System MUST provide optional developer-facing debug logging that can be enabled for troubleshooting
- **FR-013b**: System MUST automatically retry transient failures (network timeouts, device temporarily unreachable) with exponential backoff (1-3 attempts with increasing delays)
- **FR-014**: System MUST work with React Native and Expo managed workflow projects
- **FR-015**: System MUST gracefully handle unsupported platforms with clear error messaging

### Key Entities

- **ModuleState**: Represents the current operational state of the HomeAtlas module with four states: uninitialized (not yet initialized), ready (initialized and HomeKit permissions granted), permission denied (HomeKit access denied by user), error (initialization or runtime failure)
- **Home**: Represents a HomeKit home with name, unique identifier, and collections of accessories and rooms
- **Room**: Represents a room within a home with name and unique identifier
- **Accessory**: A physical or bridged HomeKit device with name, identifier, reachability, category, room assignment, and services
- **Service**: A functional unit of an accessory (e.g., Lightbulb, Thermostat) with type identifier and characteristics
- **Characteristic**: A readable/writable property of a service with type, value, and notification support
- **Error**: Structured error with semantic error code (e.g., PERMISSION_DENIED, DEVICE_UNREACHABLE), human-readable message, and operation context (accessory name, characteristic type, operation)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can discover and display all HomeKit accessories within 5 seconds of app launch on a typical home setup (10-50 devices)
- **SC-002**: Read and write operations complete within 2 seconds for reachable devices under normal conditions
- **SC-003**: TypeScript type definitions cover 100% of HomeKit service types available in the underlying HomeAtlas framework
- **SC-004**: TypeScript compiler catches invalid property access on service and characteristic types (zero runtime type errors for typed usage)
- **SC-005**: Real-time characteristic updates are delivered to subscribers within 1 second of the physical device state change
- **SC-006**: Errors provide sufficient context for developers to diagnose issues without additional logging (includes accessory name, operation type, and failure reason)
- **SC-007**: Module installs successfully in both bare React Native and Expo managed workflow projects
- **SC-008**: API surface requires no more than 5 core methods to accomplish basic smart home control (init, list accessories, read, write, subscribe)

## Assumptions

- Users will be on iOS/iPadOS devices where HomeKit is available; Android support is out of scope
- HomeKit permission prompting is handled by the native layer; the module will request permissions when needed
- The TypeScript bindings will expose the same capabilities as the underlying HomeAtlas Swift framework
- Expo SDK version 50+ and React Native 0.73+ are the minimum supported versions
- TypeScript service types will be generated by extending the existing HomeKitServiceGenerator to output TypeScript alongside Swift from the same YAML catalog, ensuring type sync
- The hap-fluent library types can serve as a reference implementation for TypeScript type definitions
- Velox (Swift port of Tauri) is not applicable - it is unrelated to React Native and uses a different architecture
