# Research: SwiftPM Deployment, Encodable, Naming

## Decision: SwiftPM Deployment
- **Chosen**: Use Swift Package Manager (SwiftPM) for distribution via the Swift Package Index.
- **Rationale**: SwiftPM is the standard for Swift library distribution and is required for discoverability and adoption in the Swift ecosystem.
- **Alternatives considered**: Manual distribution, CocoaPods, Carthage (all less preferred for modern Swift projects).

## Decision: Encodable for Wrapper Classes
- **Chosen**: Evaluate all wrapper classes for `Encodable` conformance. Conform where feasible; document and exclude properties/types that cannot be encoded.
- **Rationale**: Serialization enables diagnostics, analytics, and export. Not all HomeKit types are serializable, so selective conformance is required.
- **Alternatives considered**: Custom serialization, omitting serialization support (would limit diagnostics and integrations).

## Decision: Package Naming
- **Chosen**: Review alternative names for the package to ensure uniqueness, clarity, and alignment with Swift community standards. Use tools like the Swift Package Index search to check for conflicts.
- **Rationale**: Naming impacts discoverability and user trust. A clear, unique name avoids confusion and supports adoption.
- **Alternatives considered**: Retain current name without review (risk of conflict or ambiguity).
