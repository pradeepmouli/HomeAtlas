# Implementation Plan: HomeAtlas rebrand and JSON serialization

**Branch**: `001-homeatlas-rebrand-encodable` | **Date**: 2025-11-11 | **Spec**: specs/001-homeatlas-rebrand-encodable/spec.md
**Input**: Feature specification from `/specs/001-homeatlas-rebrand-encodable/spec.md`

**Note**: This plan is produced by `/speckit.plan` and will drive Phase 0 (research) and Phase 1 (design/contracts) outputs.

## Summary

Primary requirement: Rebrand the project to HomeAtlas (module: HomeAtlasKit; tools: HomeAtlasGen, HomeAtlasCLI) and provide a deterministic JSON snapshot export of the Home graph (Home → Rooms → Accessories → Services → Characteristics), with platform-safe behavior when HomeKit is unavailable.

Technical approach (subject to Phase 0 validation): Implement a generic snapshot encoder entry point that walks the typed wrappers and emits a well-defined JSON structure. Prefer a lightweight Encodable snapshot model with a single public API (e.g., `HomeAtlasKit.encodeSnapshot(options:)`) and internal helpers. Consider a macro in a later iteration for compile-time conformance synthesis if needed for coverage; not required for MVP.

## Technical Context

**Language/Version**: Swift 6.0 (per repo guidelines)  
**Primary Dependencies**: Apple HomeKit (conditional), Foundation  
**Storage**: None (in-memory traversal; output to file/string as needed)  
**Testing**: XCTest with unit, integration, and fallback compilation tests  
**Target Platform**: iOS 18+/macOS 15+ family as per constitution guardrails; compile-time fallbacks when HomeKit is not available  
**Project Type**: Swift Package (single-target for core library)  
**Performance Goals**: Export ≤ 2 seconds for ~100 accessories with ~1000 characteristics on modern desktop hardware  
**Constraints**: Deterministic key ordering; no crashes on restricted values; optional anonymization  
**Scale/Scope**: Typical consumer homes; stress tests up to 100+ accessories, 1000+ characteristics  

Open questions (NEEDS CLARIFICATION for Phase 0):
- Serialization mechanism choice: macro vs. encodable wrapper vs. generic method for snapshotting (proposal: generic method + Encodable snapshot types for MVP).
- Privacy defaults: anonymize names/identifiers by default vs. opt-in (proposal: opt-in anonymization with explicit option flag).
- Null vs. omission for restricted/unreadable values (proposal: include field with null and reason field next to it).

## Constitution Check

Type-safe API surface: Use strongly-typed wrappers already present; public export API returns `Data`/`String` and documented schema without `Any` exposure.  
MainActor strategy: All HomeKit interactions (reads of values) performed on `@MainActor`; traversal code annotated accordingly. No exceptions anticipated.  
Error handling: Map failures to `HomeKitError` with context (home/room/accessory/service/characteristic identifiers). Timeouts/logging recorded via `DiagnosticsLogger`.  
Coverage evidence: Add unit tests for entities, integration test to export a representative Home, parity tests to validate keys, and compile guard tests for no-HomeKit platforms.  
Documentation: Update README, CHANGELOG, docs/reference-index.md with naming changes and an “Export snapshot” quickstart; add privacy notes.  
External references: Cite Apple Developer HomeKit docs for access permissions, threading, and characteristic read semantics via `developer_apple` context in docs.

Gate status: PASS (no violations anticipated). Re-check after design below.

## Project Structure

### Documentation (this feature)

```text
specs/001-homeatlas-rebrand-encodable/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── home-snapshot.schema.json
└── tasks.md             # Phase 2 (created by /speckit.tasks)
```

### Source Code (repository root)

```text
Sources/
├── SwiftHomeKit/                # Will be renamed to HomeAtlasKit in rebrand phase
│   ├── Context/
│   ├── Generated/
│   ├── Encoding/
│   │   └── HomeSnapshotEncoder.swift        # New: snapshot entry points and options
│   └── …
├── HomeKitServiceGenerator/     # Will become HomeAtlasGen (tool name)
└── HomeKitCatalogExtractor/     # Tooling kept; docs update for naming

Tests/
├── SwiftHomeKitTests/           # Will be renamed to HomeAtlasKitTests in rebrand phase
│   ├── Encodable/
│   │   └── SnapshotEncodingTests.swift      # New: validates schema and edge cases
│   └── Integration/
│       └── SnapshotIntegrationTests.swift   # New: end-to-end export
└── …
```

**Structure Decision**: Single Swift Package target with added `Encoding/` folder for snapshot logic and new tests under existing test target. Rebrand steps will rename the module and tool entry points, preserving source layout.

## Complexity Tracking

No constitution violations to justify at this time.

## Post-Design Constitution Re-Check

After producing `research.md`, `data-model.md`, and the schema contract, the design remains compliant:  
- Type safety preserved via snapshot models and typed traversal.  
- `@MainActor` enforced on read paths; no background HomeKit access.  
- Errors mapped to `HomeKitError` with diagnostics hooks.  
- Tests planned for coverage and fallbacks.  
- Documentation updates enumerated.
