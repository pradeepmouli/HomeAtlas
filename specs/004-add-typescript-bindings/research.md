# Research: TypeScript Bindings for HomeAtlas

**Date**: 2026-01-16
**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Research Topics

1. React Native native module bridging patterns
2. Expo Module API compatibility
3. Swift async/await to Promise bridging
4. TypeScript code generation from Swift types
5. HomeKit permission handling in React Native

---

## 1. Native Module Architecture

### Decision: Use Expo Modules API

**Rationale**:
- Expo Modules API automatically supports both New Architecture (enabled by default since RN 0.76) and legacy bridge
- Uses Swift DSL directly, minimizing Objective-C boilerplate
- Provides consistent cross-platform API design pattern
- Integrates with Expo's config plugin system for Info.plist modifications (needed for HomeKit permissions)
- Best developer experience for module consumers

**Alternatives Considered**:

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| Expo Modules API | Swift DSL, auto New Arch support, config plugins | Slightly slower than Nitro | **SELECTED** |
| Nitro Modules | 15-59x faster, direct Swift | Newer ecosystem, less documentation | Not selected |
| Turbo Modules (direct) | Maximum control, C++ option | Requires Objective-C bridging, more boilerplate | Not selected |
| Legacy Bridge | Wide compatibility | Deprecated, slower, no JSI benefits | Not selected |

---

## 2. Swift Async/Await to Promise Bridging

### Decision: Use Expo AsyncFunction with Swift native async/await

**Pattern**:
```swift
// HomeAtlasModule.swift
import ExpoModulesCore
import HomeAtlas

public class HomeAtlasModule: Module {
    public func definition() -> ModuleDefinition {
        Name("HomeAtlas")

        // Implicit Promise via async function
        AsyncFunction("initialize") { () async throws -> [String: Any] in
            let manager = HomeKitManager.shared
            await manager.waitUntilReady()
            return self.serializeHomes(manager.homes)
        }

        AsyncFunction("readCharacteristic") { (accessoryId: String, serviceType: String, characteristicType: String) async throws -> Any in
            // Bridge to HomeAtlas Swift API
        }
    }
}
```

**Rationale**:
- Swift's native async/await maps cleanly to JavaScript Promises via `AsyncFunction`
- No manual Promise handling needed (implicit conversion)
- Error propagation via `throws` automatically rejects the Promise
- HomeAtlas already uses async/await patterns

---

## 3. TypeScript Type Generation

### Decision: Extend HomeKitServiceGenerator to output TypeScript alongside Swift

**Approach**:
1. **Core types**: Manually written TypeScript interfaces matching HomeAtlas Swift types
2. **Generated service types**: Extend existing `HomeKitServiceGenerator` to output TypeScript from the same YAML catalog

**Rationale**:
- **No mature Swift→TypeScript tool exists** - ecosystem gap confirmed via research
- **Expo Modules API has no built-in codegen** - TypeScript types must be maintained separately
- HomeAtlas already has a code generation pipeline (`HomeKitServiceGenerator`) using `homekit-services.yaml`
- Single source of truth ensures Swift and TypeScript types stay in sync automatically
- ~100 services and ~200 characteristics benefit from automation
- Manual core types ensure API stability

**Research Findings**:

| Tool | Direction | Status |
|------|-----------|--------|
| Quicktype | JSON→TS | Not applicable (no Swift input) |
| Nitro Modules | TS→Swift | Opposite direction |
| React Native Codegen | TS→ObjC++ | Opposite direction |
| ts-gyb (Microsoft) | TS→Swift | Opposite direction |
| Typeshare (1Password) | Rust→Multi | Swift as output only |

**Implementation**: Add `TypeScriptGenerator.swift` to `Sources/HomeKitServiceGenerator/` that:
- Reads from `homekit-services.yaml` (same as Swift generator)
- Outputs to `packages/react-native-homeatlas/src/generated/`
- Runs via SwiftPM command plugin alongside Swift generation

**Type Mapping**:

| Swift Type | TypeScript Type |
|------------|-----------------|
| `String` | `string` |
| `Bool` | `boolean` |
| `Int` / `Int32` | `number` |
| `Double` / `Float` | `number` |
| `UUID` | `string` (UUID format) |
| `[T]` | `T[]` |
| `[String: Any]` | `Record<string, unknown>` |
| `async throws -> T` | `Promise<T>` |
| `Optional<T>` | `T \| null` |

---

## 4. HomeKit Permission Handling

### Decision: Expo Config Plugin for Info.plist + runtime permission check

**Implementation**:

1. **Build-time**: Config plugin adds required Info.plist keys
   - `NSHomeKitUsageDescription`: Required for HomeKit access

2. **Runtime**: Module checks permission status and requests if needed

**Config Plugin** (`app.plugin.js`):
```javascript
module.exports = function withHomeAtlas(config) {
  return {
    ...config,
    ios: {
      ...config.ios,
      infoPlist: {
        ...config.ios?.infoPlist,
        NSHomeKitUsageDescription:
          config.ios?.infoPlist?.NSHomeKitUsageDescription ||
          "This app uses HomeKit to control your smart home devices."
      }
    }
  };
};
```

**Rationale**:
- Expo config plugins handle native project modifications declaratively
- Permission prompt is triggered automatically by HomeKit framework when first accessed
- No separate permission library needed

---

## 5. Event Subscription Pattern

### Decision: Expo Events API for characteristic change notifications

**Pattern**:
```swift
// Swift side - emit events
Events("onCharacteristicChange")

Function("subscribeToCharacteristic") { (accessoryId: String, characteristicType: String) in
    // Set up HomeKit notification
    characteristic.setNotifications(enabled: true)
    // When value changes, emit event
    self.sendEvent("onCharacteristicChange", [
        "accessoryId": accessoryId,
        "characteristicType": characteristicType,
        "value": newValue
    ])
}
```

```typescript
// TypeScript side - listen for events
import { EventEmitter } from 'expo-modules-core';

const emitter = new EventEmitter(HomeAtlasModule);
emitter.addListener('onCharacteristicChange', (event) => {
  console.log(event.accessoryId, event.value);
});
```

**Rationale**:
- Expo's EventEmitter provides clean subscription API
- Maps directly to HomeKit's notification pattern
- Automatic cleanup when listeners are removed

---

## 6. Module Package Structure

### Decision: Standalone npm package in `packages/` directory

**Structure**:
```
packages/react-native-homeatlas/
├── package.json
├── expo-module.config.json
├── app.plugin.js              # Config plugin for Info.plist
├── src/
│   ├── index.ts               # Main exports
│   ├── HomeAtlas.ts           # Main API class
│   ├── types/                 # TypeScript definitions
│   └── generated/             # Generated service types
├── ios/
│   ├── HomeAtlasModule.swift  # Expo module definition
│   └── Serialization.swift    # Swift→JSON conversion
└── android/
    └── HomeAtlasModule.kt     # Stub with unsupported error
```

**Rationale**:
- Monorepo structure allows local development with main HomeAtlas library
- Can be published to npm independently
- Android stub provides clear error message rather than crash

---

## 7. Velox Compatibility

### Decision: Not applicable - Velox is unrelated to React Native

**Research Findings**:
- **Velox (velox-apps)** is a Swift port of Tauri for desktop applications, not a React Native tool
- Uses webview-based rendering (via Wry) with Swift backends
- Has no connection to React Native ecosystem
- Target platform is macOS desktop, not mobile

**Conclusion**:
- The original feature request mentioned "Velox" but this appears to be unrelated to our use case
- No Velox-specific compatibility work is needed
- The module will work with standard React Native and Expo projects

---

## Summary of Decisions

| Topic | Decision |
|-------|----------|
| Module Architecture | Expo Modules API |
| Async Pattern | AsyncFunction with Swift async/await |
| Type Generation | Extend HomeKitServiceGenerator for TypeScript output |
| Permissions | Expo Config Plugin + runtime check |
| Events | Expo Events API |
| Package Structure | Standalone package in `packages/` |
| Velox Support | Not applicable (unrelated to React Native) |

---

## Open Questions Resolved

All NEEDS CLARIFICATION items from Technical Context have been resolved through this research. No blockers for Phase 1.
