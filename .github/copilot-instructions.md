# HomeAtlas Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-11-11

## Active Technologies
- Swift 6.0 with Apple HomeKit (conditional), Foundation
- In-memory traversal with JSON export to file/string as needed

## Project Structure

```text
Sources/
  HomeAtlas/
  HomeAtlasMacros/
  HomeKitCatalogExtractor/
  HomeKitServiceGenerator/
Tests/
  HomeAtlasTests/
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

## Recent Changes
- 003-homeatlas-rebrand-encodable: Finalized HomeAtlas rebrand; added snapshot export with typed macros
- 002-swiftpm-deploy-encodable-naming: Naming research and migration to HomeAtlas identity
- 001-create-homekit-wrapper: Initial HomeKit wrapper infrastructure with type-safe APIs

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
