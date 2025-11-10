import Foundation

/// Main extractor that orchestrates SDK parsing
struct SDKExtractor {
    let sdkPath: String
    let metadataPath: String?
    let simulatorPath: String?

    init(sdkPath: String, metadataPath: String? = nil, simulatorPath: String? = nil) {
        self.sdkPath = sdkPath
        self.metadataPath = metadataPath
        self.simulatorPath = simulatorPath
    }

    func extractCatalog() async throws -> HomeKitCatalog {
        let homeKitFrameworkPath = "\(sdkPath)/System/Library/Frameworks/HomeKit.framework"

        // Parse header files
        let headerParser = HeaderParser(frameworkPath: homeKitFrameworkPath)
    var services = try await headerParser.parseServices()
    var characteristics = try await headerParser.parseCharacteristics()

        // Parse TBD file for symbol validation
        let tbdParser = TBDParser(frameworkPath: homeKitFrameworkPath)
        let exportedSymbols = try await tbdParser.parseSymbols()

        // Validate parsed data against TBD exports
        validateSymbols(services: services, characteristics: characteristics, exportedSymbols: exportedSymbols)

        // Use runtime inspector to add service-characteristic relationships
        let inspector = RuntimeInspector(metadataPath: metadataPath, simulatorPath: simulatorPath)
        let inspection = inspector.inspectServiceCharacteristics(services: services, characteristics: characteristics)
        services = inspection.services
        characteristics = inspection.characteristics

        return HomeKitCatalog(services: services, characteristics: characteristics)
    }

    func validateSymbols(
        services: [ServiceEntry],
        characteristics: [CharacteristicEntry],
        exportedSymbols: Set<String>
    ) {
        guard !exportedSymbols.isEmpty else { return }

        // Check that all service type constants are exported
        for service in services {
            let symbolName = "_HMServiceType\(service.name)"
            if !exportedSymbols.contains(symbolName) {
                print("⚠️  Warning: Service symbol not found in TBD: \(symbolName)")
            }
        }

        // Check that all characteristic type constants are exported
        for characteristic in characteristics {
            let symbolName = "_HMCharacteristicType\(characteristic.name)"
            if !exportedSymbols.contains(symbolName) {
                print("⚠️  Warning: Characteristic symbol not found in TBD: \(symbolName)")
            }
        }
    }
}
