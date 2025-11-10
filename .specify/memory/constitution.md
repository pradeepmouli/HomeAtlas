<!--
Sync Impact Report:
- Version change: 1.0.0 -> 1.1.0
- Modified principles:
	- Principle V: Documentation Stewardship -> Principle V: Documentation Stewardship
- Added sections: None
- Removed sections: None
- Templates requiring updates:
	- ✅ .specify/templates/plan-template.md
	- ✅ .specify/templates/spec-template.md
	- ✅ .specify/templates/tasks-template.md
- Follow-up TODOs: None
-->

# SwiftHomeKit Constitution

## Core Principles

### Principle I: Type-Safe HomeKit Interfaces
- Public APIs MUST expose concrete Swift types; avoid leaking `Any`, type-erased wrappers, or raw HomeKit metadata.
- Characteristic descriptors MUST validate and encode ranges that match HomeKit semantics before publishing values.
- Wrappers MUST mirror HomeKit naming while adhering to Swift capitalization so Xcode autocompletion stays intuitive.

Rationale: Compile-time guarantees lower runtime crashes, document expectations, and encourage discoverability for integrators.

### Principle II: MainActor Concurrency Discipline
- Interactions with HomeKit objects MUST be confined to `@MainActor` contexts unless Apple documentation explicitly allows otherwise.
- Async/await bridges MUST replace completion handlers; callbacks MAY remain only as private glue code.
- State mutations MUST respect HomeKit delegate lifecycles, capturing continuations exactly once to avoid deadlock.

Rationale: HomeKit requires main-thread coordination; enforcing it prevents race conditions and UI update violations.

### Principle III: Deterministic Error Surface
- All fallible operations MUST map to `HomeKitError` (or an extension thereof) with actionable case data.
- Errors returned from Apple frameworks MUST retain diagnostic context (service ID, characteristic type, accessory name).
- Logging or diagnostic metadata MUST be captured when async operations exceed expected latency or fail unexpectedly.

Rationale: Predictable errors simplify recovery strategies for client apps and accelerate production debugging.

### Principle IV: Service Coverage Evidence
- Introducing a new service wrapper MUST include characteristic descriptors, MainActor helpers, and parity tests for encode/decode paths.
- Platform fallbacks (`#if canImport(HomeKit)` guards) MUST compile; placeholder tests MUST pass on unsupported platforms.
- Integration examples MUST demonstrate toggling or reading values end-to-end for each supported service type.

Rationale: Evidence-based coverage ensures wrappers stay honest reflections of HomeKit behaviour across platforms.

### Principle V: Documentation Stewardship
- README sections covering features, requirements, and usage MUST be updated with every public API addition or breaking change.
- Documentation references MUST prioritize Developer Apple Context7 docs (`developer_apple`) under the HomeKit topic as the authoritative external source when citing platform behaviours.
- Example snippets MUST compile with current APIs and highlight concurrency plus error-handling expectations.
- Changes that alter platform support or minimum OS versions MUST include migration notes in `CHANGELOG.md` or README.

Rationale: Updated guidance keeps downstream adopters unblocked and reduces support churn.

## Engineering Guardrails

- Supported platforms are iOS 26+, macOS 26+, tvOS 26+, and watchOS 26+; deviations require explicit maintainer approval.
- New dependencies beyond Apple frameworks MUST be justified with measurable benefit and reviewed for platform compatibility.
- Module structure MUST remain single-target (`SwiftHomeKit`) unless a new target is proven essential for testing isolation.
- Code style MUST follow Swift API design guidelines, using PascalCase types and lowerCamelCase members.

## Development Workflow

- Feature specs MUST document how each principle is satisfied, referencing expected typed APIs, concurrency model, tests, and docs.
- Implementation plans MUST pass the Constitution Check: type safety scope, MainActor strategy, error handling, coverage tests, and documentation updates.
- Tasks MUST include entries for tests, fallback code paths, and documentation updates before marking stories complete.
- `swift test` MUST run in environments with and without HomeKit availability flags to verify guard paths.

## Governance

- This constitution supersedes prior informal practices for SwiftHomeKit.
- Amendments require agreement from the maintainer group and MUST document rationale plus migration expectations.
- Versioning follows SemVer on the constitution: MAJOR for principle changes/removals, MINOR for new principles or guardrails, PATCH for clarifications.
- Compliance reviews MUST occur before releasing new library versions; non-compliant changes block release until resolved.

**Version**: 1.1.0 | **Ratified**: 2025-11-08 | **Last Amended**: 2025-11-08
