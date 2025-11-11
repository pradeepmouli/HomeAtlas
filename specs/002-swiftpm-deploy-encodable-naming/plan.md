# Implementation Plan: SwiftPM Deployment, Encodable, Naming

**Branch**: `002-swiftpm-deploy-encodable-naming` | **Date**: 2025-11-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-swiftpm-deploy-encodable-naming/spec.md`

## Summary

This feature will:
- Package the HomeKit wrapper for deployment in the Swift Package Index using SwiftPM.
- Evaluate and implement `Encodable` conformance for wrapper classes where feasible, documenting any exclusions.
- Review and select a unique, descriptive package name consistent with Swift community standards.
- Update documentation to reflect deployment, serialization, and naming decisions.

## Technical Context

**Language/Version**: Swift 6.0 (latest stable)
**Primary Dependencies**: HomeKit (Apple framework), SwiftPM
**Storage**: N/A
**Testing**: XCTest
**Target Platform**: iOS 26+, macOS 26+, tvOS 26+, watchOS 26+
**Project Type**: Single Swift package (library)
**Performance Goals**: No measurable regression in build or runtime performance (baseline: ±5% build time, ±10KB package size, <1ms per encode/decode operation); serialization should not add significant overhead
**Constraints**: Must maintain type-safe APIs, MainActor/async discipline, and fallback compilation for non-HomeKit platforms
**Scale/Scope**: Library-level; no app or backend changes

## Constitution Check

- Scope the type-safe API surface: All wrappers must remain type-safe; no `Any` leakage permitted.
- MainActor strategy: All HomeKit interactions remain @MainActor unless Apple documentation allows otherwise.
- Error handling: All errors mapped to `HomeKitError` with diagnostic metadata.
- Coverage evidence: Encode/decode tests for wrappers, fallback compilation checks, integration demo updates.
- Documentation: README and CHANGELOG updated for deployment, serialization, and naming.
- External references: Cite Developer Apple Context7 documentation for platform behaviour and constraints.

## Project Structure

### Documentation (this feature)

```text
specs/002-swiftpm-deploy-encodable-naming/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md (to be generated)
```

### Source Code (repository root)

```text
Sources/
├── SwiftHomeKit/
│   ├── [wrappers, models, HomeKit integration]
│   └── ...
Tests/
├── SwiftHomeKitTests/
│   ├── [encode/decode, integration, contract tests]
│   └── ...
Package.swift
README.md
```

**Structure Decision**: Single Swift package with `Sources/SwiftHomeKit` and `Tests/SwiftHomeKitTests` as the main code and test roots. No new targets or submodules required for this feature.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None      |            |                                     |
