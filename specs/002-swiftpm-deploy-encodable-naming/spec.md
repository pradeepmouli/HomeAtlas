# Feature Specification: SwiftPM Deployment, Encodable, Naming

**Feature Branch**: `002-swiftpm-deploy-encodable-naming`
**Created**: 2025-11-10
**Status**: Draft
**Input**: User description: "package for deployment in swift package respository, minor: evaluate use of encodable for wrapper classes, cosmetic: evaluate alternative package naming options"

## User Scenarios & Testing *(mandatory)*

> Constitution Alignment: This feature targets packaging the library for deployment in the Swift Package Index, evaluating the use of `Encodable` for wrapper classes, and considering alternative package naming conventions. All changes must maintain MainActor/async safety, preserve typed HomeKit APIs, and update documentation with Developer Apple Context7 references as needed.

### User Story 1 - SwiftPM Deployment (Priority: P1)

As a library maintainer, I want to package the HomeKit wrapper for deployment in the Swift Package Index, so that users can easily add it as a dependency in their projects.

**Why this priority**: Distribution via SwiftPM is essential for adoption and integration in the Swift ecosystem.

**Independent Test**: Can be fully tested by publishing the package to a private or public Swift Package Index and verifying successful integration in a sample project.

**Acceptance Scenarios**:

1. **Given** the package is published, **When** a user adds it via SwiftPM, **Then** it integrates without errors and exposes all intended APIs.
2. **Given** a new release, **When** the package is updated, **Then** documentation and versioning are correct in the index.

---

### User Story 2 - Encodable Evaluation (Priority: P2)

As a developer, I want wrapper classes to conform to `Encodable` where possible, so that HomeKit data can be serialized for logging, diagnostics, or export.

**Why this priority**: Serialization enables better diagnostics, analytics, and potential integrations with other systems.

**Independent Test**: Can be fully tested by attempting to encode wrapper instances and verifying output matches expected structure.

**Acceptance Scenarios**:

1. **Given** a wrapper instance, **When** encoded, **Then** the resulting data is valid and contains all relevant fields.
2. **Given** a non-encodable property, **When** encoding is attempted, **Then** it is either excluded or handled gracefully.

---

### User Story 3 - Package Naming Options (Priority: P3)

As a maintainer, I want to evaluate alternative package naming conventions, so that the library name is clear, discoverable, and consistent with Swift community standards.

**Why this priority**: Naming impacts discoverability and user trust in the package ecosystem.

**Observable behavior for "handled gracefully"**: User attempts to import package on unsupported platform → compile-time error with clear message "HomeKit not available on this platform" OR fallback stub types compile successfully but throw runtime errors when used.

**Independent Test**: Can be fully tested by reviewing naming options with stakeholders and checking for conflicts or confusion in the Swift Package Index.

**Acceptance Scenarios**:

1. **Given** a set of naming options, **When** reviewed, **Then** the selected name is unique, descriptive, and unambiguous.
2. **Given** the chosen name, **When** published, **Then** it does not conflict with existing packages.

---

### Edge Cases

- What happens if the package contains platform-specific code not supported by all SwiftPM consumers?
- How does the system handle wrapper properties that cannot be encoded?
- What if the preferred package name is already taken in the Swift Package Index?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support deployment to the Swift Package Index with all required metadata and documentation.
- **FR-002**: Wrapper classes MUST conform to `Encodable` where type-safe conformance is possible (all stored properties are Encodable-compatible). Conformance is feasible when: (1) all stored properties are Encodable, (2) no `Any` types are present, (3) encode/decode round-trip tests pass with property value parity. Each wrapper class MUST have corresponding encode/decode parity tests per Constitution Principle IV.
- **FR-003**: System MUST document any properties or types that cannot be encoded, with rationale.
- **FR-004**: Maintainers MUST review and select a package name that is unique, descriptive, and consistent with Swift community standards (criteria: (1) name follows Swift API Design Guidelines noun-based package naming, (2) name is unique in Swift Package Index, (3) name clearly indicates HomeKit functionality, (4) name avoids trademark conflicts).
- **FR-005**: Documentation MUST be updated to reflect deployment, serialization, and naming decisions.
- **FR-006**: Platform-specific code (e.g., HomeKit availability on iOS/macOS/tvOS/watchOS) MUST be handled via conditional compilation (#if canImport(HomeKit)) with fallback stubs or compilation errors on unsupported platforms.
- **FR-TYPE**: Implementation MUST expose strongly typed HomeKit interfaces for the targeted services/characteristics without leaking `Any`.
- **FR-CONCUR**: Implementation MUST specify the MainActor/async strategy for every HomeKit call.
- **FR-DOCS**: Documentation MUST be updated with examples, platform notes, and migration guidance reflecting the change.

### Key Entities

- **Wrapper Class**: Represents a Swift type that wraps HomeKit objects, potentially conforming to `Encodable`.
- **Package Metadata**: Information required for SwiftPM deployment (name, version, description, authors, etc.).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Package can be added to a sample project via SwiftPM and builds successfully on supported platforms.
- **SC-002**: At least 90% of wrapper classes (defined as classes in Sources/SwiftHomeKit/ conforming to HomeKit service/characteristic wrapper protocols) conform to `Encodable` or have documented reasons for exclusion.
- **SC-003**: Package name is unique in the Swift Package Index and follows community naming conventions.
- **SC-004**: Documentation is updated and published alongside the package release.
- **SC-HK-001**: Encode/decode tests pass for new wrappers and fallback compilation succeeds on platforms without HomeKit.

## Assumptions

- The package will target the latest stable Swift version and concurrency model.
- Some HomeKit types may not be serializable; these will be documented.
- Naming review will include a search of the Swift Package Index and community feedback.
