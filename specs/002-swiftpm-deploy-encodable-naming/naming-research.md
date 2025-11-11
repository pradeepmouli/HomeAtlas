# Package Naming Research: SwiftHomeKit

**Task**: T016 [US3] Research alternative package names and check for conflicts in Swift Package Index
**Date**: 2025-11-10

## Current Name

**SwiftHomeKit**

## Naming Criteria (FR-004)

1. ✅ Follows Swift API Design Guidelines noun-based package naming
2. ✅ Unique in Swift Package Index (verified via search)
3. ✅ Clearly indicates HomeKit functionality
4. ✅ Avoids trademark conflicts

## Swift Package Index Search Results

Searched Swift Package Index for similar names:

- `SwiftHomeKit`: **No conflicts found** (this package will be first)
- `HomeKit`: Reserved by Apple (framework name)
- `HomeKitAccessoryProtocol`: HAP-specific implementations exist
- `SwiftHAP`: Server-side HomeKit Accessory Protocol implementation (different use case)

## Alternative Names Considered

| Name | Pros | Cons | Verdict |
|------|------|------|---------|
| **SwiftHomeKit** (current) | Clear, follows conventions, available, indicates Swift+HomeKit | None significant | ✅ **Recommended** |
| HomeKitSwift | Reversed order, less common pattern | Not idiomatic for Swift packages | ❌ Reject |
| HomeKitWrapper | Accurate but verbose | "Wrapper" is implementation detail | ❌ Reject |
| HomeKitPlus | Marketing-oriented | Not descriptive of actual functionality | ❌ Reject |
| TypedHomeKit | Emphasizes type-safety | Less discoverable, not following SwiftX pattern | ❌ Reject |

## Trademark Analysis

- "HomeKit" is an Apple trademark
- Using "HomeKit" in package name is acceptable when:
  - Package genuinely relates to HomeKit framework
  - Not implying official Apple endorsement
  - Following community naming patterns (SwiftUI → SwiftUIKit, HomeKit → SwiftHomeKit)

Precedents: `SwiftUI`, `SwiftData`, `SwiftNIO` use Swift prefix with Apple/community terms.

## Recommendation

**Keep `SwiftHomeKit`** as the package name.

**Rationale**:
- ✅ Meets all FR-004 criteria
- ✅ No conflicts in Swift Package Index
- ✅ Clear and descriptive
- ✅ Follows Swift ecosystem conventions
- ✅ No trademark issues (descriptive use)

## Next Steps

T017: Stakeholder review and final confirmation (documented here for solo maintainer project).
