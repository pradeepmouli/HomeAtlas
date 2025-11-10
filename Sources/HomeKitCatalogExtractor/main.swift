import Foundation

let arguments = CommandLine.arguments

guard arguments.count >= 2 else {
    print("Usage: HomeKitCatalogExtractor <SDK_PATH> [--output <OUTPUT_PATH>] [--metadata <METADATA_PATH>] [--simulator <SIMULATOR_APP_PATH>]")
    print("  SDK_PATH: Path to iOS SDK (e.g., /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk)")
    print("  --output: Output YAML file path (default: Resources/homekit-services.yaml)")
    print("  --metadata: Path to plain-metadata.config (default: /System/Library/PrivateFrameworks/HomeKitDaemon.framework/Resources/plain-metadata.config if available)")
    print("  --simulator: Path to Accessory Simulator.app (default: /Applications/Xcode.app/Contents/Developer/Applications/Accessory Simulator.app if available)")
    exit(1)
}

let sdkPath = arguments[1]
var outputPath = "Resources/homekit-services.yaml"

let defaultMetadataPath = "/System/Library/PrivateFrameworks/HomeKitDaemon.framework/Resources/plain-metadata.config"
let defaultSimulatorPaths = [
    "/Applications/HomeKit Accessory Simulator.app",
    "/Applications/Xcode.app/Contents/Developer/Applications/Accessory Simulator.app"
]

var metadataPath: String?
var simulatorPath: String?

var index = 2
while index < arguments.count {
    let argument = arguments[index]
    switch argument {
    case "--output":
        guard index + 1 < arguments.count else {
            print("⚠️  Missing value for --output")
            exit(1)
        }
        outputPath = arguments[index + 1]
        index += 2
    case "--metadata":
        guard index + 1 < arguments.count else {
            print("⚠️  Missing value for --metadata")
            exit(1)
        }
        metadataPath = arguments[index + 1]
        index += 2
    case "--simulator":
        guard index + 1 < arguments.count else {
            print("⚠️  Missing value for --simulator")
            exit(1)
        }
        simulatorPath = arguments[index + 1]
        index += 2
    default:
        print("⚠️  Unknown argument: \(argument)")
        exit(1)
    }
}

let fileManager = FileManager.default

if metadataPath == nil && fileManager.fileExists(atPath: defaultMetadataPath) {
    metadataPath = defaultMetadataPath
}

if simulatorPath == nil {
    simulatorPath = defaultSimulatorPaths.first { fileManager.fileExists(atPath: $0) }
}

print("🔍 Extracting HomeKit catalog from SDK...")
print("   SDK Path: \(sdkPath)")
print("   Output: \(outputPath)")
if let metadataPath {
    print("   Metadata: \(metadataPath)")
} else {
    print("   Metadata: (not provided)")
}
if let simulatorPath {
    print("   Simulator: \(simulatorPath)")
} else {
    print("   Simulator: (not provided)")
}

let extractor = SDKExtractor(sdkPath: sdkPath, metadataPath: metadataPath, simulatorPath: simulatorPath)

do {
    let homeKitFrameworkPath = "\(sdkPath)/System/Library/Frameworks/HomeKit.framework"

    // Parse header files
    let headerParser = HeaderParser(frameworkPath: homeKitFrameworkPath)
    var services = try headerParser.parseServicesSync()
    var characteristics = try headerParser.parseCharacteristicsSync()

    // Parse TBD file for symbol validation
    let tbdParser = TBDParser(frameworkPath: homeKitFrameworkPath)
    let exportedSymbols = try tbdParser.parseSymbolsSync()

    // Validate parsed data against TBD exports
    extractor.validateSymbols(services: services, characteristics: characteristics, exportedSymbols: exportedSymbols)

    // Use runtime inspector to add service-characteristic relationships
    let inspector = RuntimeInspector(metadataPath: metadataPath, simulatorPath: simulatorPath)
    let inspection = inspector.inspectServiceCharacteristics(services: services, characteristics: characteristics)
    services = inspection.services
    characteristics = inspection.characteristics

    let catalog = HomeKitCatalog(services: services, characteristics: characteristics)
    try catalog.writeYAML(to: outputPath)

    print("✅ Successfully extracted \(catalog.services.count) services and \(catalog.characteristics.count) characteristics")
    print("   Output written to: \(outputPath)")
} catch {
    print("❌ Extraction failed: \(error)")
    exit(1)
}
