import Foundation

let arguments = CommandLine.arguments

guard arguments.count >= 2 else {
    print("Usage: HomeKitServiceGenerator <CATALOG_PATH> [--output <OUTPUT_DIR>]")
    print("  CATALOG_PATH: Path to homekit-services.yaml catalog file")
    print("  --output: Output directory for generated Swift files (default: Sources/HomeAtlas/Generated)")
    exit(1)
}

let catalogPath = arguments[1]
var outputDir = "Sources/HomeAtlas/Generated"

// Parse optional --output argument
if arguments.count >= 4 && arguments[2] == "--output" {
    outputDir = arguments[3]
}

print("🔧 Generating HomeKit service classes...")
print("   Catalog: \(catalogPath)")
print("   Output: \(outputDir)")

do {
    let catalog = try HomeKitCatalogYAML.load(from: catalogPath)
    let generator = ServiceGenerator(catalog: catalog)

    try generator.generateAll(to: outputDir)

    print("✅ Successfully generated \(catalog.services.count) service classes")
    print("   Output directory: \(outputDir)")
} catch {
    print("❌ Generation failed: \(error)")
    exit(1)
}
