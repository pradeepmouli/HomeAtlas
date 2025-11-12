# Tasks: HomeAtlas rebrand and JSON serialization

**Input**: Design documents from `/specs/003-homeatlas-rebrand-encodable/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/home-snapshot.schema.json

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

> Constitution Alignment: Task lists MUST include type-safe wrapper work, MainActor/concurrency handling, error-surface validation, fallback compilation, tests, documentation updates, and explicit references to Developer Apple Context7 (`developer_apple`, HomeKit topic) before a story can close.

## Path Conventions

- **Module**: `Sources/HomeAtlas/` (formerly `Sources/SwiftHomeKit/`)
- **Tests**: `Tests/HomeAtlasTests/` (formerly `Tests/SwiftHomeKitTests/`)
- **Tools**: `Sources/HomeKitServiceGenerator/`, `Sources/HomeKitCatalogExtractor/`
- **Docs**: `docs/`, `README.md`, `CHANGELOG.md`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Ensure baseline folders exist for snapshot encoding work

- [ ] T001 Confirm or create `Sources/HomeAtlas/Encoding/` directory for snapshot logic
- [ ] T002 [P] Confirm or create `Tests/HomeAtlasTests/Encodable/` directory for snapshot tests
- [ ] T003 [P] Confirm or create `Tests/HomeAtlasTests/Integration/` directory (add README stub if created)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core snapshot models and encoding infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Create `SnapshotOptions` struct in `Sources/HomeAtlas/Encoding/SnapshotOptions.swift` with anonymize flag
- [ ] T005 [P] Create base snapshot model types in `Sources/HomeAtlas/Encoding/SnapshotModels.swift`: `HomeSnapshot`, `RoomSnapshot`, `ZoneSnapshot`, `AccessorySnapshot`, `ServiceSnapshot`, `CharacteristicSnapshot` conforming to Codable
- [ ] T006 [P] Add deterministic ordering helpers in `Sources/HomeAtlas/Encoding/SnapshotHelpers.swift` for sorting Rooms, Accessories, Services, Characteristics per research.md
- [ ] T007 Create `HomeSnapshotEncoder` entry point in `Sources/HomeAtlas/Encoding/HomeSnapshotEncoder.swift` with `@MainActor` annotation and async signature
- [ ] T008 Add error handling in `HomeSnapshotEncoder` mapping to `HomeKitError` with context (home/room/accessory/service/characteristic IDs)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Export a Home snapshot to JSON (Priority: P1) 🎯 MVP

**Goal**: Developer can export Home graph to deterministic JSON with stable keys, handling inaccessible values gracefully

**Independent Test**: Call snapshot API on sample Home; validate JSON contains expected entities, relationships, values with stable keys per schema contract

### Implementation for User Story 1

- [ ] T009 [P] [US1] Implement Home→HomeSnapshot conversion in `HomeSnapshotEncoder` traversing rooms and zones
- [ ] T010 [P] [US1] Implement Room→RoomSnapshot conversion traversing accessories
- [ ] T011 [P] [US1] Implement Accessory→AccessorySnapshot conversion with manufacturer/model/firmware metadata
- [ ] T012 [P] [US1] Implement Service→ServiceSnapshot conversion traversing characteristics
- [ ] T013 [US1] Implement Characteristic→CharacteristicSnapshot conversion reading values on `@MainActor` with null+reason for restricted/unavailable (depends on T009-T012)
- [ ] T014 [US1] Add deterministic ordering to all snapshot conversions using helpers from T006
- [ ] T015 [US1] Implement anonymization logic in `HomeSnapshotEncoder` when `SnapshotOptions.anonymize = true` (hash/redact names and IDs)
- [ ] T016 [US1] Add public API method `encodeSnapshot(options:) async throws -> Data` in `Sources/HomeAtlas/HomeAtlas.swift` or dedicated export file
- [ ] T017 [US1] Implement JSON encoding with stable key order using JSONEncoder with sortedKeys option
- [ ] T018 [US1] Add unit test in `Tests/HomeAtlasTests/Encodable/SnapshotEncodingTests.swift` validating schema compliance against `contracts/home-snapshot.schema.json`
- [ ] T019 [US1] Add integration test in `Tests/HomeAtlasTests/Integration/SnapshotIntegrationTests.swift` exporting a representative Home and verifying output
- [ ] T020 [US1] Add edge case tests: empty Home, no Rooms, restricted characteristics, large Home (100+ accessories), anonymization with `SnapshotOptions.anonymize = true`
- [ ] T021 [US1] Add performance test validating export ≤ 2 seconds for ~100 accessories with ~1000 characteristics
- [ ] T022 [US1] Document snapshot API in `docs/reference-index.md` with examples, privacy options, performance notes
- [ ] T023 [US1] Reference Developer Apple Context7 (`developer_apple`, HomeKit topic) for characteristic read permissions and threading in docs

**Checkpoint**: At this point, User Story 1 should be fully functional - snapshot export works with deterministic JSON

---

## Phase 4: User Story 2 - Adopt HomeAtlas naming (Priority: P2)

**Goal**: Module, tools, and docs use HomeAtlas branding consistently with migration guidance

**Independent Test**: Import module as `HomeAtlas` in a fresh project; run CLI with documented HomeAtlas commands; verify migration note exists

### Implementation for User Story 2

- [ ] T024 [P] [US2] Audit repository for lingering `SwiftHomeKit` identifiers and replace with `HomeAtlas` where migration context is not required
- [ ] T025 [P] [US2] Update `Package.swift` comments and product docs to describe the module as `HomeAtlas`
- [ ] T026 [P] [US2] Refresh CLI documentation in `docs/service-extension.md` and `README.md` to reference current executable names and HomeAtlas branding
- [ ] T027 [P] [US2] Add or update migration guidance in `CHANGELOG.md` and/or `docs/migration-homeatlas.md`
- [ ] T028 [US2] Sweep `.github/copilot-instructions.md`, `.specify/memory/constitution.md`, and spec files to ensure HomeAtlas naming consistency
- [ ] T029 [US2] Run `swift build` to verify package metadata remains valid after documentation updates
- [ ] T030 [US2] Update quickstart examples in `docs/` and `specs/002-*/quickstart.md` to confirm `import HomeAtlas`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - snapshot export works with HomeAtlas branding

---

## Phase 5: User Story 3 - Platform-safe behavior (Priority: P3)

**Goal**: Library compiles and snapshot APIs behave gracefully on non-HomeKit platforms

**Independent Test**: Build on macOS/Linux without HomeKit; call snapshot API and verify it returns placeholder or clear unsupported status without crashes

### Implementation for User Story 3

- [ ] T034 [P] [US3] Add `#if canImport(HomeKit)` guards around HomeKit-dependent snapshot code in `HomeSnapshotEncoder`
- [ ] T035 [P] [US3] Implement fallback `encodeSnapshot` for non-HomeKit platforms returning empty snapshot or clear error in `HomeSnapshotEncoder`
- [ ] T036 [US3] Add compile test in CI validating build succeeds on non-HomeKit platform (e.g., Linux if supported, or macOS with HomeKit disabled)
- [ ] T037 [US3] Add runtime test calling snapshot API on non-HomeKit platform verifying graceful behavior (no crash, clear result)
- [ ] T038 [US3] Document platform-safe behavior in `README.md` and `docs/reference-index.md`

**Checkpoint**: All user stories should now be independently functional - complete HomeAtlas rebrand with robust snapshot export

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final validation

- [ ] T039 [P] Update `CHANGELOG.md` with feature summary and breaking changes (naming)
- [ ] T040 [P] Run `swift test` to validate all tests pass
- [ ] T041 [P] Run performance benchmarks from T021 and document results
- [ ] T042 Validate quickstart examples in `specs/003-homeatlas-rebrand-encodable/quickstart.md` against implemented API
- [ ] T043 [P] Code review for type safety (no `Any` leakage per Constitution Principle I)
- [ ] T044 [P] Code review for MainActor annotations per Constitution Principle II
- [ ] T045 Final constitution check: verify all principles satisfied (type safety, MainActor, errors, coverage, docs)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Independent but best done after US1 implementation exists to rename
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Depends on US1 snapshot implementation to add guards

**Recommended sequence**: Complete US1 (MVP), then US2 (rebrand), then US3 (platform safety)

### Within Each User Story

- **US1**: Models before encoder methods, encoder methods before tests, tests before docs
- **US2**: File/directory renames can be parallel, but doc updates should follow to verify new names
- **US3**: Guards before fallback implementation, runtime tests after fallback

### Parallel Opportunities

- **Setup (Phase 1)**: All tasks marked [P] can run in parallel
- **Foundational (Phase 2)**: T005 (snapshot models) and T006 (helpers) can run in parallel
- **US1 (Phase 3)**: T009-T012 (entity conversions) can run in parallel before T013 (depends on all)
- **US1 (Phase 3)**: T018-T020 (tests) can run in parallel after T017
- **US2 (Phase 4)**: T024-T029 (renames and doc updates) can run in parallel
- **US3 (Phase 5)**: T034-T035 (guards and fallback) can run in parallel
- **Polish (Phase 6)**: T039-T041, T043-T044 can all run in parallel

---

## Parallel Example: User Story 1

If working with a team on US1, this could be split:

**Developer A**: T009-T010 (Home/Room conversions)
**Developer B**: T011-T012 (Accessory/Service conversions)
**Developer C**: T018-T019 (Unit/integration tests - can start once T013-T017 stub exists)

Once T013 completes (depends on T009-T012), Developer A/B can proceed to T014-T017 while Developer C completes tests.

---

## MVP Scope (Recommended)

**Minimum Viable Product** = User Story 1 only (Phase 1 + Phase 2 + Phase 3)

This delivers:
- ✅ Snapshot export API
- ✅ Deterministic JSON output
- ✅ Privacy options (anonymization)
- ✅ Error handling for restricted values
- ✅ Tests validating schema compliance
- ✅ Documentation for snapshot export

**Post-MVP** = Add User Story 2 (rebrand) and User Story 3 (platform safety)

---

## Implementation Strategy

1. **Start with MVP**: Complete Phase 1-3 (Setup + Foundational + US1) to deliver snapshot export
2. **Validate**: Run all US1 tests, verify quickstart examples work
3. **Rebrand**: Complete Phase 4 (US2) to adopt HomeAtlas naming
4. **Harden**: Complete Phase 5 (US3) for platform-safe behavior
5. **Polish**: Complete Phase 6 for final validation and constitution check

**Estimated Task Count**: 46 tasks total
- Phase 1 (Setup): 3 tasks
- Phase 2 (Foundational): 5 tasks
- Phase 3 (US1 - MVP): 15 tasks
- Phase 4 (US2): 11 tasks (added constitution update)
- Phase 5 (US3): 5 tasks
- Phase 6 (Polish): 7 tasks

**Parallel Opportunities**: ~20 tasks marked [P] can run in parallel within their phase constraints
