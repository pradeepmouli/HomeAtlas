# Research: Strongly Typed HomeKit Wrapper

## Task: Research code generation tooling for HomeKit catalog sync

- **Decision**: Use a Swift Package Manager command plugin that invokes a Swift CLI built with Swift Argument Parser and SwiftSyntax to translate a curated `homekit-services.yaml` schema into strongly typed Swift sources.
- **Rationale**: SwiftSyntax provides first-class Swift AST construction without string concatenation, enabling reliable generation across Swift 6 toolchains. Running the generator through an SPM command plugin keeps the workflow co-located with package consumers (`swift package plugin generate-homeatlas`) and supports CI automation.
- **Alternatives considered**:
  - *Stencil/Handlebars templates*: Simpler to adopt but prone to formatting drift and harder to enforce `@MainActor` annotations automatically.
  - *Sourcery*: Powerful templating but adds an external dependency and is tailored for code scanning rather than external schema expansion.
  - *Build-time macros*: Require Swift 6.1+ experimental features and complicate full-catalog regeneration; rejected until macro tooling stabilises for large code emission.

## Task: Best practices for Apple HomeKit framework integration

- **Decision**: Continue to treat all HomeKit entry points as `@MainActor` and wrap callbacks in async continuations only when Developer Apple Context7 indicates background execution is supported. Maintain diagnostic logging capturing accessory metadata and operation latency.
- **Rationale**: HomeKit remains UIKit-aligned, expecting main-thread orchestration for reads and writes. Aligning with Developer Apple guidance prevents race conditions and entitlement violations while the error surface (accessory/service/characteristic identifiers) accelerates debugging.
- **Alternatives considered**: Dispatching operations to background queues risks undefined behaviour and is discouraged by Developer Apple documentation; adopting raw HAP over IP bypasses HomeKit security stack and violates platform policies.

- **Task: Best practices for Swift Package Manager distribution**
-
- **Decision**: Ship the library as a single SPM package with one library target (`HomeAtlas`), macro target (`HomeAtlasMacros`), and two executable targets (`HomeKitCatalogExtractor`, `HomeKitServiceGenerator`). Publish semantic versions alongside constitution updates.
- **Rationale**: SPM is the mandated distribution mechanism (FR-007). Keeping the generator and extractor alongside the library keeps tooling discoverable, allows `swift run HomeKitServiceGenerator` to refresh sources, and avoids parallel distribution channels.
- **Alternatives considered**: Providing prebuilt XCFrameworks would introduce binary maintenance overhead; alternative package managers (CocoaPods, Carthage) conflict with specification scope.

## Task: Best practices for Swift Argument Parser usage in generation CLI

- **Decision**: Model the generator CLI with subcommands (`sync`, `diff`, `validate`) using Swift Argument Parser, emitting structured diagnostics and exit codes for CI.
- **Rationale**: SAP offers declarative command definitions, automatic help output, and integrates with Swift concurrency. Subcommands allow separation between schema validation and code emission, easing contributor workflows.
- **Alternatives considered**: Using raw `CommandLine.arguments` increases boilerplate and reduces UX; third-party CLIs (e.g., Commander) add dependencies without added value.

## Task: Best practices for Developer Apple Context7 HomeKit metadata ingestion

- **Decision**: Maintain a curated `homekit-services.yaml` file storing service versions, characteristic metadata, and canonical Developer Apple Context7 URLs. Contributors update the YAML after reviewing Developer Apple release notes; the generator stamps source headers with the referenced document revision.
- **Rationale**: Apple does not expose a public JSON feed for HomeKit services. A curated YAML anchored with explicit doc links offers traceability, simplifies reviews, and satisfies the constitution requirement to cite Developer Apple Context7 as the source.
- **Alternatives considered**: Scraping HTML from developer.apple.com risks breakage and violates terms of use; relying on community datasets could diverge from Apple's authoritative definitions.
