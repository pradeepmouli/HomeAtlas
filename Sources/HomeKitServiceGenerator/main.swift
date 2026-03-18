import Foundation

let arguments = CommandLine.arguments

guard arguments.count >= 2 else {
    print("Usage: HomeKitServiceGenerator <CATALOG_PATH> [--output <OUTPUT_DIR>] [--typescript <TS_OUTPUT_DIR>]")
    print("  CATALOG_PATH: Path to homekit-services.yaml catalog file")
    print("  --output: Output directory for generated Swift files (default: Sources/HomeAtlas/Generated)")
    print("  --typescript: Output directory for generated TypeScript files (optional)")
    exit(1)
}

let catalogPath = arguments[1]
var outputDir = "Sources/HomeAtlas/Generated"
var typescriptOutputDir: String?

// Parse optional arguments
var i = 2
while i < arguments.count {
    if arguments[i] == "--output" && i + 1 < arguments.count {
        outputDir = arguments[i + 1]
        i += 2
    } else if arguments[i] == "--typescript" && i + 1 < arguments.count {
        typescriptOutputDir = arguments[i + 1]
        i += 2
    } else {
        i += 1
    }
}

print("🔧 Generating HomeKit service classes...")
print("   Catalog: \(catalogPath)")
print("   Swift Output: \(outputDir)")
if let tsOutput = typescriptOutputDir {
    print("   TypeScript Output: \(tsOutput)")
}

do {
    let catalog = try HomeKitCatalogYAML.load(from: catalogPath)
    
    // Generate Swift code
    let generator = ServiceGenerator(catalog: catalog)
    try generator.generateAll(to: outputDir)
    print("✅ Successfully generated \(catalog.services.count) Swift service classes")
    print("   Output directory: \(outputDir)")
    
    // Generate TypeScript code if requested
    if let tsOutput = typescriptOutputDir {
        let tsGenerator = TypeScriptGenerator(catalog: catalog)
        try tsGenerator.generateAll(to: tsOutput)
        print("✅ Successfully generated TypeScript definitions")
        print("   Output directory: \(tsOutput)")
    }
} catch {
    print("❌ Generation failed: \(error)")
    exit(1)
}
