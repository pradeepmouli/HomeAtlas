# Feature Specification: HomeAtlas rebrand and JSON serialization

**Feature Branch**: `003-homeatlas-rebrand-encodable`
**Created**: 2025-11-11
**Status**: Draft
**Input**: User description: "Update project naming - Brand/repo: HomeAtlas, SwiftPM module: HomeAtlasKit, Tooling: HomeAtlasGen, HomeAtlasCLI. Implement encodable wrapper/macro or generic method to serialize Home/Room/Accessory/Service/Characteristic etc.."

## User Scenarios & Testing *(mandatory)*

> Constitution Alignment: Describe the typed HomeKit APIs involved, required MainActor/async behaviour, planned tests, documentation updates, and reference Developer Apple Context7 (`developer_apple`, HomeKit topic) when citing platform behaviour.

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Export a Home snapshot to JSON (Priority: P1)

A developer using the library can export the current Home graph (Home → Rooms → Accessories → Services → Characteristics) to a structured JSON document for diagnostics, analytics, or support.

**Why this priority**: Enables immediate value to developers for testing, debugging, and integrations without changing existing device setups.

**Independent Test**: From a sample or live Home environment, call the provided serialization API to produce JSON. Validate that the output contains expected entities, relationships, and values with stable keys.

**Acceptance Scenarios**:

1. **Given** a Home with at least one Room and Accessory, **When** the developer requests a snapshot export, **Then** a JSON document is produced with Home metadata, Rooms, Accessories, Services, and Characteristics including current values where accessible.
2. **Given** characteristics that are unavailable or require permissions, **When** the snapshot is produced, **Then** the export includes fields with null or an explicit status for inaccessible values, without failing the entire export.

---

### User Story 2 - Adopt HomeAtlas naming (Priority: P2)

A developer can adopt the new naming: brand/repo as HomeAtlas, module as HomeAtlasKit, and tools as HomeAtlasGen and HomeAtlasCLI, with clear migration guidance.

**Why this priority**: Aligns the toolkit under a cohesive brand and reduces confusion for new and existing users.

**Independent Test**: Validate that package metadata, module import name, docs, and CLI/tool references consistently use HomeAtlas naming, and that a migration note is available.

**Acceptance Scenarios**:

1. **Given** a fresh consumer project, **When** the developer follows the README, **Then** they can import the module and run the CLI using the HomeAtlas names.
2. **Given** an existing consumer on prior naming, **When** they review migration notes, **Then** they understand the steps and scope of changes required to adopt HomeAtlas naming.

---

### User Story 3 - Platform-safe behavior (Priority: P3)

Consumers who compile on platforms without HomeKit support can still build their apps, and serialization APIs behave predictably (e.g., encode known data or report a clear unsupported status).

**Why this priority**: Ensures wider compatibility and prevents build-time blockers.

**Independent Test**: Build on a target where HomeKit is unavailable and run serialization entry points in a sandboxed environment to verify graceful behavior.

**Acceptance Scenarios**:

1. **Given** a non-HomeKit platform, **When** building the consumer project, **Then** the library compiles without errors.
2. **Given** a non-HomeKit platform, **When** calling serialization APIs, **Then** the result is a well-formed placeholder/empty snapshot or a clear unsupported indicator without crashes.

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

- Homes with no Rooms, or Rooms with no Accessories should still export a valid, minimal JSON structure.
- Characteristics with write-only or permission-restricted values must not cause export failures; values are represented as null with an access note.
- Very large Homes (e.g., 100+ Accessories, 1000+ Characteristics) must export within reasonable time and memory limits.
- Names or metadata containing personally identifiable information should be handled with care; where required, provide options to omit or anonymize.
- When HomeKit APIs are unavailable at compile or runtime, exports should degrade gracefully without crashing.

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: The library MUST provide a single call (function or method) that produces a JSON representation of the current Home graph, including Homes, Rooms, Accessories, Services, and Characteristics with values when readable.
- **FR-002**: The JSON output MUST use stable, documented keys and be deterministic for a given Home state (ordering rules clearly defined).
- **FR-003**: The export MUST not crash when encountering inaccessible or unsupported values; such fields are included as null with a reason field or excluded per documented rules.
- **FR-004**: The solution MUST avoid leaking sensitive identifiers beyond what is already visible in standard Home views; provide an option to anonymize names and identifiers in the export.
- **FR-005**: The rebrand MUST update visible naming in documentation and developer entry points to “HomeAtlas” (brand/repo), “HomeAtlasKit” (module), “HomeAtlasGen” and “HomeAtlasCLI” (tooling), with a migration note.
- **FR-TYPE**: Implementation MUST expose strongly typed Home interfaces for the targeted services/characteristics without leaking `Any` in public APIs.
- **FR-CONCUR**: Implementation MUST specify the MainActor/async strategy for every Home call and for value reads performed during snapshot export.
- **FR-DOCS**: Documentation MUST include examples for exporting a Home snapshot, notes on privacy options, performance guidance, and migration steps to HomeAtlas naming.

### Key Entities *(include if feature involves data)*

- **Home**: Top-level container with metadata and collections of Rooms and Zones.
- **Room**: Logical grouping of Accessories within a Home.
- **Zone**: Cross-cutting grouping of Rooms.
- **Accessory**: A device with one or more Services.
- **Service**: Feature set exposed by an Accessory composed of Characteristics.
- **Characteristic**: A typed property/value with metadata (e.g., units, access, min/max) and a current value when readable.

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: Developers can generate a complete Home snapshot JSON in under 2 seconds for Homes with up to 100 Accessories on modern desktop hardware.
- **SC-002**: Snapshot export succeeds without crashes in 99% of attempts across supported platforms and sample datasets.
- **SC-003**: Documentation migration tasks are completable in under 15 minutes by an existing user familiar with the prior naming.
- **SC-004**: At least 5 representative acceptance scenarios (including permission-restricted characteristics) pass with stable, documented JSON keys.
- **SC-HK-001**: Compilation and basic export behavior succeed on platforms without HomeKit; CI confirms both HomeKit-present and HomeKit-absent builds.
