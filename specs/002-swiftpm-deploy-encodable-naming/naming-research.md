# Package Naming Research: HomeAtlas

**Task**: T016 [US3] Research alternative package names and check for conflicts in Swift Package Index
**Date**: 2025-11-10 (updated 2025-11-11 to capture HomeAtlas rebrand)

## Current Name

**HomeAtlas** (formerly `SwiftHomeKit`)

## Naming Criteria (FR-004)

1. ✅ Follows Swift API Design Guidelines noun-based package naming
2. ✅ Unique in Swift Package Index (verified via search for "HomeAtlas")
3. ✅ Clearly indicates HomeKit functionality while supporting future roadmap messaging
4. ✅ Avoids trademark conflicts (Atlas is generic, "Home" descriptive)

## Swift Package Index Search Results

Searched Swift Package Index for similar names:

- `HomeAtlas`: **No conflicts found** (name available)
- `SwiftHomeKit`: Legacy identity retained for historical context but no longer published under that label
- `HomeKit`: Reserved by Apple (framework name)
- `HomeKitAccessoryProtocol`: HAP-specific implementations exist
- `SwiftHAP`: Server-side HomeKit Accessory Protocol implementation (different use case)

## Alternative Names Considered

| Name | Pros | Cons | Verdict |
|------|------|------|---------|
| **HomeAtlas** (current) | Connects to home automation domain, aligns with roadmap branding, available | Requires migration messaging from SwiftHomeKit | ✅ **Recommended** |
| SwiftHomeKit (legacy) | Immediately communicates Swift + HomeKit | Deprecated identity after rebrand | ⚠️ Legacy (retain aliases only) |
| HomeKitSwift | Reversed order, less common pattern | Not idiomatic for Swift packages | ❌ Reject |
| HomeKitWrapper | Accurate but verbose | "Wrapper" is implementation detail | ❌ Reject |
| TypedHomeKit | Emphasizes type-safety | Less discoverable, not following naming conventions | ❌ Reject |
| AtlasHome | Reinforces atlas metaphor | Less obvious HomeKit association | ❌ Reject |

## Trademark Analysis

- "HomeKit" is an Apple trademark
- Using "HomeKit" in package name is acceptable when:
  - Package genuinely relates to HomeKit framework
  - Not implying official Apple endorsement
  - Following community naming patterns (SwiftUI → SwiftUIKit, HomeKit → SwiftHomeKit)

Precedents: `SwiftUI`, `SwiftData`, `SwiftNIO` use Swift prefix with Apple/community terms.

## Recommendation

**Adopt `HomeAtlas`** as the package name.

**Rationale**:
- ✅ Meets all FR-004 criteria
- ✅ No conflicts in Swift Package Index (2025-11-11 verification)
- ✅ Clear, distinctive, and supports long-term branding beyond purely HomeKit wrappers
- ✅ Avoids trademark issues (descriptive use, "Atlas" generic)
- ✅ Preserves continuity by documenting `SwiftHomeKit` as a legacy alias only

## Next Steps

T017: Stakeholder review and final confirmation (documented here for solo maintainer project).
T018: Update repository references and documentation to surface `HomeAtlas` as canonical package name (completed via rebrand tasks).
