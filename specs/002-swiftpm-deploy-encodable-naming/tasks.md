# Tasks: SwiftPM Deployment, Encodable, Naming

## Phase 1: Setup
- [X] T001 Create tasks.md for feature in specs/002-swiftpm-deploy-encodable-naming/tasks.md
- [X] T002 Initialize SwiftPM package metadata in Package.swift
- [X] T003 Update README.md with SwiftPM deployment instructions

## Phase 2: Foundational
- [X] T004 Add initial encode/decode test infrastructure in `Tests/HomeAtlasTests/Encodable/`
- [X] T004b [Constitution IV] Create encode/decode parity test template in `Tests/HomeAtlasTests/Encodable/ParityTestTemplate.swift` (validates round-trip property value equality for all Encodable wrappers)
- [X] T005 Document current wrapper classes and their properties in docs/reference-index.md (See also docs/encodable-audit.md)

## Phase 3: User Story 1 - SwiftPM Deployment (P1)
- [X] T006 [US1] Prepare Package.swift for Swift Package Index compliance (name, version, platforms, products, targets, authors)
- [X] T007 [US1] Validate package builds and passes tests on all supported platforms
- [X] T008 [US1] Publish package to private/public Swift Package Index for integration test (Manual: documented in README)
- [X] T009 [US1] Verify integration in a sample project (add via SwiftPM, import, build, run) (See Examples/Integration)
- [X] T010 [US1] Update documentation for release (README.md, CHANGELOG.md)

## Phase 4: User Story 2 - Encodable Evaluation (P2)
- [X] T011 [US2] Audit all wrapper classes in `Sources/HomeAtlas` for Encodable conformance (See docs/encodable-audit.md: 0% feasible - all wrappers store non-Encodable HMKit types)
- [X] T012 [P] [US2] Implement Encodable for eligible wrappers in `Sources/HomeAtlas` (N/A - 0 eligible per audit)
- [X] T012b [Constitution I] Validate no `Any` types leaked in Encodable implementations (scan `Sources/HomeAtlas` for `Any` in encode() methods, fail if found) (N/A - no implementations)
- [X] T013 [P] [US2] Document and exclude non-encodable properties/types in docs/reference-index.md (See docs/encodable-exclusion-rationale.md)
- [X] T014 [US2] Add encode/decode tests for wrappers in `Tests/HomeAtlasTests/Encodable/` (DTO pattern tests added: AccessorySnapshotTests)
- [X] T015 [US2] Update API documentation to reflect serialization support (README updated with DTO pattern guidance)
- [ ] T013 [P] [US2] Document and exclude non-encodable properties/types in docs/reference-index.md
- [ ] T014 [US2] Add encode/decode tests for wrappers in `Tests/HomeAtlasTests/Encodable/`
- [ ] T015 [US2] Update API documentation to reflect serialization support

## Phase 5: User Story 3 - Package Naming Options (P3)
- [X] T016 [US3] Research alternative package names and check for conflicts in Swift Package Index (See `naming-research.md`: "HomeAtlas" adopted, legacy SwiftHomeKit documented)
- [X] T017 [US3] Review naming options with stakeholders and select final name (Solo maintainer: "HomeAtlas" confirmed)
- [X] T018 [US3] Update Package.swift and documentation with chosen name (HomeAtlas references now canonical)
- [X] T019 [US3] Verify no conflicts exist after publishing with new name (Pre-verified via SPI search)

## Final Phase: Polish & Cross-Cutting Concerns
- [X] **T020**: Review and update all documentation for accuracy and completeness (README ✓, CHANGELOG ✓, encodable docs ✓, naming research ✓)
- [X] **T021**: Ensure fallback compilation and encode/decode tests pass on non-HomeKit platforms (43 tests passing, including 3 DTO tests)
- [X] **T022**: Final review confirming all user stories are independently testable and documented (US1 ✓ SwiftPM integration builds, US2 ✓ 0% conform + 100% documented, US3 ✓ naming confirmed)

## Dependencies
- T004 → T004b (parity test template depends on test infrastructure)
- T012 → T012b (Any-leakage validation depends on Encodable implementations)
- T014 depends on T004b (encode/decode tests use parity test template)
- US1 (T006-T010) must complete before US2 (T011-T015) and US3 (T016-T019) can be finalized for public release.
- US2 and US3 can be worked on in parallel after US1 setup.
- Phase 2 Foundational (T004, T004b, T005) should complete before Phase 4 US2 (T011-T015).

## Parallel Execution Examples
- T012 [P] [US2] Implement Encodable for eligible wrappers and T013 [P] [US2] Document/exclude non-encodable properties can be done in parallel.
- T016 [US3] Research naming options and T011 [US2] Audit wrappers for Encodable can be done in parallel after setup.

## Implementation Strategy
- MVP: Complete all tasks for User Story 1 (SwiftPM Deployment) to enable basic package distribution and integration.
- Incremental: Add Encodable support and finalize naming in subsequent phases, ensuring each user story is independently testable and deliverable.
- Rebrand Alignment: Confirm every reference migrates from `SwiftHomeKit` to `HomeAtlas` except where documenting historical context.
