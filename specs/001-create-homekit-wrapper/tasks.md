---

description: "Task list for strongly typed Swift HomeKit wrapper"
---

# Tasks: Strongly Typed HomeKit Wrapper

**Input**: Design documents from `/specs/001-create-homekit-wrapper/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include unit, integration, and generator validation tests where acceptance scenarios reference deterministic behaviour.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

> Constitution Alignment: Task lists MUST include type-safe wrapper work, MainActor/concurrency handling, error-surface validation, fallback compilation, tests, documentation updates, and explicit references to Developer Apple Context7 (`developer_apple`, HomeKit topic) before a story can close.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish Swift Package targets, directories, and resources referenced by subsequent phases.

- [X] T001 Define library, executable, and plugin targets with Swift 6 settings in `Package.swift`
- [X] T002 Create repository directories (`Sources/HomeAtlas/`, `Sources/HomeKitServiceGenerator/`, `Sources/HomeKitCatalogExtractor/`, `Sources/HomeAtlasMacros/`, `Resources/`, `Tests/HomeAtlasTests/`, `Tests/HomeAtlasMacrosTests/`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core schema, generator scaffolding, and CI hooks that every user story depends on.

- [X] T003 Author baseline HomeKit catalog stub with Developer Apple citations in `Resources/homekit-services.yaml`
- [X] T004 Implement schema models and validation helpers in `Sources/HomeKitServiceGenerator/CatalogParser.swift`
- [X] T005 Build Swift Argument Parser CLI scaffold in `Sources/HomeKitServiceGenerator/main.swift`
- [X] T006 Integrate SwiftSyntax-based generation pipeline skeleton in `Sources/HomeKitServiceGenerator/ServiceGenerator.swift`
- [X] T007 Implement CLI entry point for regeneration commands in `Sources/HomeKitServiceGenerator/main.swift`
- [X] T008 Add generator smoke tests covering `sync` validation in `Tests/HomeAtlasTests/Integration/GeneratedParityTests.swift`

**Checkpoint**: Foundation ready – user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Compile-Time Accessory Control (Priority: P1) 🎯 MVP

**Goal**: Provide strongly typed accessors ensuring compile-time safety for HomeKit reads/writes.

**Independent Test**: Run `swift test --filter LightbulbControlTests` to toggle a light accessory and confirm unsupported types fail to compile via negative test targets.

### Implementation Tasks

- [X] T009 [US1] Generate `ServiceDescriptor` and `AccessoryProfile` runtime types in `Sources/HomeAtlas/Types.swift`
- [X] T010 [P] [US1] Implement `CharacteristicValueType` domain modelling in `Sources/HomeAtlas/Characteristic.swift`
- [X] T011 [US1] Add `HomeKitManager` facade with `@MainActor` typed accessors in `Sources/HomeAtlas/HomeKitManager.swift`
- [X] T012 [P] [US1] Create integration test toggling a lightbulb characteristic in `Tests/HomeAtlasTests/Integration/LightbulbControlTests.swift`
- [X] T013 [US1] Document compile-time usage example with Developer Apple references in `README.md`

**Checkpoint**: User Story 1 functional and independently demonstrable

---

## Phase 4: User Story 2 - Deterministic Error Insights (Priority: P2)

**Goal**: Surface actionable error cases with accessory metadata and latency diagnostics.

**Independent Test**: Execute `swift test --filter HomeKitErrorTests` to validate error payloads and simulated transport failures.

### Implementation Tasks

- [X] T014 [US2] Extend `HomeKitError` hierarchy with metadata-rich cases in `Sources/HomeAtlas/HomeKitError.swift`
- [X] T015 [P] [US2] Add diagnostic logging hooks capturing latency in `Sources/HomeAtlas/DiagnosticsLogger.swift`
- [X] T016 [US2] Wire telemetry capture into async characteristic writes in `Sources/HomeAtlas/Characteristic.swift`
- [X] T017 [P] [US2] Add unit tests for error surface and diagnostics in `Tests/HomeAtlasTests/HomeKitErrorTests.swift`
- [X] T018 [US2] Update troubleshooting documentation with Developer Apple guidance in `docs/troubleshooting.md`
- [ ] T030 [US2] Add latency benchmark integration test covering 95th percentile target in `Tests/HomeAtlasTests/Integration/LatencyBenchmarks.swift`
- [ ] T031 [P] [US2] Assert diagnostics metadata coverage for each `HomeKitError` case in `Tests/HomeAtlasTests/HomeKitErrorDiagnosticsTests.swift`

**Checkpoint**: User Stories 1 and 2 functional and testable independently

---

## Phase 5: User Story 3 - Extensible Service Coverage (Priority: P3)

**Goal**: Enable maintainers to autogenerate new service wrappers with confidence and parity tests, sourcing canonical metadata directly from the shipped iOS SDK.

**Independent Test**: Run the SDK extractor (`swift run HomeKitCatalogExtractor dump --sdk iphoneos`), then `swift package plugin generate-homeatlas && swift test --filter GeneratedParityTests` after adding a mock service to confirm metadata harvest, generation, docs, and tests update automatically.

### Implementation Tasks

- [X] T019 [US3] Build clang-backed SDK extractor CLI in `Sources/HomeKitCatalogExtractor/` to parse HomeKit headers into normalized data
- [X] T020 [P] [US3] Parse `HomeKit.tbd` exports and diff against header-derived catalog within extractor tests
- [X] T021 [US3] Integrate extractor output into `Resources/homekit-services.yaml` regeneration via `Sources/HomeKitServiceGenerator/main.swift`
- [X] T022 [P] [US3] Generate SwiftSyntax service/characteristic source files with Context7 doc links in `Sources/HomeAtlas/Generated/`
- [X] T023 [P] [US3] Document SDK extraction + generation workflow in `docs/service-extension.md` and back with parity tests in `Tests/HomeAtlasTests/Integration/GeneratedParityTests.swift`

**Checkpoint**: All user stories independently functional with automation for catalog updates

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Repository-wide improvements, documentation polish, and CI enablement.

- [X] T024 Add Developer Apple citation index in `docs/reference-index.md`
- [X] T025 Document generator usage with Developer Apple citations in `README.md` and `specs/001-create-homekit-wrapper/quickstart.md`
- [ ] T026 Configure CI workflow for fallback builds in `.github/workflows/ci.yml`

---

## Phase 7: User Story 4 - Context Entities & Cache Lifecycle (Priority: P3)

**Goal**: Provide typed wrappers for Home context entities and formalize cache lifecycle controls for eager loading and invalidation scenarios.

**Independent Test**: Extend integration coverage with `swift test --filter ContextEntityLifecycleTests` validating wrapper reuse, cache warm-up hooks, and Developer Apple compliance references.

### Implementation Tasks

- [X] T027 [US4] Add manual `HMHome`, `HMRoom`, and `HMZone` wrappers with `@MainActor` accessors in `Sources/HomeAtlas/Context/` citing Developer Apple metadata.
- [X] T028 [P] [US4] Expose cache warm-up and reset APIs across `Service`, `Accessory`, and `HomeKitManager` in `Sources/HomeAtlas/` with negative tests in `Tests/HomeAtlasTests/CacheLifecycleTests.swift`.
- [X] T029 [US4] Document context wrappers and cache lifecycle usage in `README.md` and `specs/001-create-homekit-wrapper/quickstart.md`, referencing Developer Apple Context7 guidance.

**Checkpoint**: Context entity ergonomics and cache lifecycle APIs documented and validated.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies – must complete first.
- **Foundational (Phase 2)**: Depends on Setup completion – blocks all user stories.
- **User Stories (Phase 3–5)**: Depend on Foundational completion.
  - US1 (P1) must ship before others for MVP.
  - US2 (P2) may proceed after US1 baseline types exist.
  - US3 (P3) depends on generator scaffolding and benefits from US1 type definitions.
- **Polish (Phase 6)**: Runs after desired user stories complete.

### User Story Dependencies

- **US1**: Independent after foundational work; unlocks typed APIs.
- **US2**: Depends on US1’s session facade to attach diagnostics.
- **US3**: Depends on US1 descriptor structures and foundational generator scaffolding.

### Within Each User Story

- Implement core types before adding diagnostics or docs in the same story.
- Tests marked [P] can run once corresponding implementation is in place.
- Documentation tasks follow implementation to reference accurate APIs.

---

## Parallel Opportunities

- [US1] `CharacteristicValueType` implementation (T010) can proceed alongside integration test scaffolding (T012).
- [US2] Diagnostics logger (T015) and unit tests (T017) can evolve concurrently once error enum (T014) exists.
- [US3] SDK extractor core (T019) and `.tbd` diff automation (T020) can progress in parallel; once they land, schema integration (T021) unlocks emitter/doc/test updates (T022–T023).
- Generator smoke tests (T008) can run while plugin wiring (T007) is implemented.

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phases 1–2 (Setup + Foundational).
2. Deliver User Story 1 (Phases 3 tasks) for compile-time safe control.
3. Validate with integration tests and documentation update.

### Incremental Delivery

1. Ship MVP (US1) to unblock integrators.
2. Layer in deterministic error insights (US2) for richer diagnostics.
3. Add SDK-driven extensibility tooling (US3) to scale service coverage.

### Parallel Team Strategy

- Developer A: Focus on runtime library (US1) following foundational completion.
- Developer B: Build diagnostics and logging (US2) once error enum stubs exist.
- Developer C: Implement SDK extractor + generator enhancements (US3) leveraging schema scaffolding.
- Shared effort: Documentation and CI polish in Phase 6.
