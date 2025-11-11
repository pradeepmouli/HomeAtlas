# Research: HomeAtlas rebrand and JSON serialization

Date: 2025-11-11
Branch: 003-homeatlas-rebrand-encodable

## Unknowns and Decisions

### 1) Serialization mechanism (macro vs wrapper vs generic method)
- Decision: Generic method entry point with lightweight Encodable snapshot models for MVP.
- Rationale: Fastest path to deterministic output using existing typed wrappers; avoids macro stability and time investment for initial release.
- Alternatives considered:
  - Macro-driven synthesis: Strong compile-time guarantees but higher complexity; revisit in later iteration.
  - Wrapper-only per-type Encodable: Verbose and higher maintenance; generic snapshot types reduce duplication.

### 2) Privacy defaults for exported data
- Decision: Opt-in anonymization via `SnapshotOptions(anonymize: Bool = false)`.
- Rationale: Most developer diagnostics prefer real names; provide explicit switch for sharing logs externally.
- Alternatives considered: Always anonymize (safer but less useful by default); global configuration (harder to discover).

### 3) Representation of restricted/unreadable values
- Decision: Include field with `null` value and a sibling `reason` string (e.g., `{"value": null, "reason": "permission"}`) in the characteristic payload.
- Rationale: Maintains schema stability and allows downstream tools to understand absence semantics.
- Alternatives considered: Omit fields (saves bytes but ambiguous); sentinel values (type-confusing).

### 4) Deterministic ordering
- Decision: Define order: Homes → Rooms (name asc) → Accessories (name asc) → Services (serviceType asc, then name) → Characteristics (type asc).
- Rationale: Determinism simplifies diffing and testing.
- Alternatives considered: Preserve HomeKit enumeration order (non-deterministic across runs/devices).

### 5) Module and tooling renaming process
- Decision: Rename module to `HomeAtlasKit`; tooling display names to `HomeAtlasGen` and `HomeAtlasCLI`. Provide migration notes and search/replace guidance.
- Rationale: Aligns branding while minimizing churn.
- Alternatives considered: Aliasing old names for a deprecation window; can be added if needed.

## References
- SwiftHomeKit Constitution v1.1.0 (Type safety, MainActor, error model, documentation stewardship)
- Apple Developer docs (HomeKit threading and read permissions)

