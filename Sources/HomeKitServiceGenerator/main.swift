import Foundation

let arguments = CommandLine.arguments

guard arguments.count >= 2 else {
    print("Usage: HomeKitServiceGenerator <CATALOG_PATH> [--output <OUTPUT_DIR>] [--typescript <TS_OUTPUT_DIR>]")
    print("  CATALOG_PATH: Path to homekit-services.yaml catalog file")
    print("  --output: Output directory for generated Swift files (default: Sources/HomeAtlas/Generated)")
    print("  --typescript: Output directory for generated TypeScript files (default: packages/react-native-homeatlas/src/generated)")
    exit(1)
}

let catalogPath = arguments[1]
var outputDir = "Sources/HomeAtlas/Generated"
var typescriptOutputDir = "packages/react-native-homeatlas/src/generated"

// Parse optional arguments
var i = 2
while i < arguments.count - 1 {
    if arguments[i] == "--output" {
        outputDir = arguments[i + 1]
        i += 2
    } else if arguments[i] == "--typescript" {
        typescriptOutputDir = arguments[i + 1]
        i += 2
    } else {
        i += 1
    }
}

print("🔧 Generating HomeKit service classes...")
print("   Catalog: \(catalogPath)")
print("   Swift Output: \(outputDir)")
print("   TypeScript Output: \(typescriptOutputDir)")

do {
    let catalog = try HomeKitCatalogYAML.load(from: catalogPath)
    
    // Generate Swift classes
    let swiftGenerator = ServiceGenerator(catalog: catalog)
    try swiftGenerator.generateAll(to: outputDir)
    print("✅ Successfully generated \(catalog.services.count) Swift service classes")
    print("   Output directory: \(outputDir)")
    
    // Generate TypeScript definitions
    let tsGenerator = TypeScriptGenerator(catalog: catalog)
    try tsGenerator.generateAll(to: typescriptOutputDir)
    print("✅ Successfully generated TypeScript definitions")
    print("   Output directory: \(typescriptOutputDir)")
} catch {
    print("❌ Generation failed: \(error)")
    exit(1)
}
