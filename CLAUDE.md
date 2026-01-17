# HomeAtlas Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-01-17

## Active Technologies

- Swift 6.0 with Apple HomeKit (conditional), Foundation
- In-memory traversal with JSON export to file/string as needed
- Swift 6.0 (native module), TypeScript 5.x (bindings) + HomeAtlas (Swift), React Native 0.73+, Expo SDK 50+ (001-add-typescript-bindings)

## Project Structure

```text
# Swift Package Manager Structure
Sources/
  HomeAtlas/
  HomeAtlasMacros/
  HomeKitCatalogExtractor/
  HomeKitServiceGenerator/
Tests/
  HomeAtlasTests/

# TypeScript Bindings (planned - 001-add-typescript-bindings)
packages/
  react-native-homeatlas/
    src/
      index.ts
      types/
      NativeHomeAtlas.ts
    ios/
      HomeAtlasModule.swift
      HomeAtlasModule.m
    android/
    __tests__/
Examples/
  ReactNativeExample/
```

## Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Generate service wrappers from HomeKit catalog
swift run HomeKitCatalogExtractor
swift run HomeKitServiceGenerator
```

## Code Style

- Follow Swift API Design Guidelines
- Use `@MainActor` for all HomeKit interactions
- Prefer async/await over completion handlers
- Use strongly typed wrappers (no `Any` leakage)
- TypeScript: Follow standard conventions for React Native native modules

## Recent Changes

- 001-add-typescript-bindings: Added Swift 6.0 (native module), TypeScript 5.x (bindings) + HomeAtlas (Swift), React Native 0.73+, Expo SDK 50+

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
