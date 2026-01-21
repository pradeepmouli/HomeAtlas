import Foundation

/// Generates TypeScript type definitions from HomeKit catalog for React Native bindings
struct TypeScriptGenerator {
    private let catalog: HomeKitCatalogYAML
    private let fileManager: FileManager

    init(catalog: HomeKitCatalogYAML, fileManager: FileManager = .default) {
        self.catalog = catalog
        self.fileManager = fileManager
    }

    /// Generate all TypeScript files to the specified output directory
    func generateAll(to outputPath: String) throws {
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)

        // Clean and create output directory
        if fileManager.fileExists(atPath: outputURL.path) {
            try cleanDirectory(at: outputURL)
        } else {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true)
        }

        // Create subdirectories
        let servicesDir = outputURL.appendingPathComponent("services", isDirectory: true)
        try fileManager.createDirectory(at: servicesDir, withIntermediateDirectories: true)

        // Generate type files
        try generateServiceTypesEnum(at: outputURL)
        try generateCharacteristicTypesEnum(at: outputURL)
        try generateCharacteristicInterfaces(at: outputURL)
        try generateServiceInterfaces(at: servicesDir)
        try generateIndexFile(at: outputURL)

        print("✅ TypeScript generation complete: \(catalog.services.count) services, \(catalog.characteristics.count) characteristics")
    }

    // MARK: - Directory Management

    private func cleanDirectory(at url: URL) throws {
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        for entry in contents {
            try fileManager.removeItem(at: entry)
        }
    }

    // MARK: - Type Generation

    /// Generate ServiceTypes enum with all service type identifiers
    private func generateServiceTypesEnum(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("serviceTypes.ts")
        var contents = fileHeader()
        contents += "\n/**\n * HomeKit service type identifiers.\n * Auto-generated from homekit-services.yaml.\n */\n"
        contents += "export enum ServiceTypes {\n"

        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            let constantName = makeTypeScriptConstantName(from: service.swiftName)
            let doc = service.documentation ?? service.name
            contents += "  /** \(doc) */\n"
            contents += "  \(constantName) = '\(service.identifier)',\n"
        }

        contents += "}\n"
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    /// Generate CharacteristicTypes enum with all characteristic type identifiers
    private func generateCharacteristicTypesEnum(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("characteristicTypes.ts")
        var contents = fileHeader()
        contents += "\n/**\n * HomeKit characteristic type identifiers.\n * Auto-generated from homekit-services.yaml.\n */\n"
        contents += "export enum CharacteristicTypes {\n"

        for characteristic in catalog.characteristics.sorted(by: { $0.name < $1.name }) {
            let constantName = makeTypeScriptConstantName(from: characteristic.swiftName)
            let doc = characteristic.documentation ?? characteristic.name
            contents += "  /** \(doc) */\n"
            contents += "  \(constantName) = '\(characteristic.identifier)',\n"
        }

        contents += "}\n"
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    /// Generate characteristic interfaces with value types and metadata
    private func generateCharacteristicInterfaces(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("characteristics.ts")
        var contents = fileHeader()
        contents += "\n/**\n * HomeKit characteristic type definitions.\n * Auto-generated from homekit-services.yaml.\n */\n\n"
        contents += "import type { Characteristic } from '../types/characteristic';\n"
        contents += "import { CharacteristicTypes } from './characteristicTypes';\n\n"

        // Generate specific characteristic interfaces that extend the base Characteristic type
        for characteristic in catalog.characteristics.sorted(by: { $0.name < $1.name }) {
            let typeName = makeTypeScriptTypeName(from: characteristic.swiftName)
            let tsValueType = mapValueType(characteristic.valueType)
            let doc = characteristic.documentation ?? characteristic.name

            contents += "/** \(doc) */\n"
            if characteristic.deprecated {
                contents += "/** @deprecated HomeKit marks this characteristic as deprecated */\n"
            }
            contents += "export interface \(typeName) extends Characteristic<\(tsValueType)> {\n"
            contents += "  type: CharacteristicTypes.\(makeTypeScriptConstantName(from: characteristic.swiftName));\n"
            contents += "  value: \(tsValueType);\n"
            contents += "}\n\n"
        }

        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    /// Generate service interfaces with required and optional characteristics as direct properties
    private func generateServiceInterfaces(at servicesDir: URL) throws {
        let characteristicTypeNames = Dictionary(uniqueKeysWithValues:
            catalog.characteristics.map { ($0.name, makeTypeScriptTypeName(from: $0.swiftName)) }
        )

        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            let typeName = "\(service.name)Service"
            let fileURL = servicesDir.appendingPathComponent("\(typeName).ts")
            var contents = fileHeader()
            contents += "\n/**\n * \(service.name) service interface.\n * Auto-generated from homekit-services.yaml.\n */\n\n"
            contents += "import type { Service } from '../../types/service';\n"
            contents += "import { ServiceTypes } from '../serviceTypes';\n"
            contents += "import { CharacteristicTypes } from '../characteristicTypes';\n"

            // Import characteristic types
            let allCharacteristics = Set(service.requiredCharacteristics + service.optionalCharacteristics)
            if !allCharacteristics.isEmpty {
                contents += "import type {\n"
                for charName in allCharacteristics.sorted() {
                    if let typeName = characteristicTypeNames[charName] {
                        contents += "  \(typeName),\n"
                    }
                }
                contents += "} from '../characteristics';\n"
            }

            contents += "\n"

            let doc = service.documentation ?? service.name
            contents += "/**\n * \(doc)\n"
            if !service.requiredCharacteristics.isEmpty {
                contents += " * Required characteristics: \(service.requiredCharacteristics.joined(separator: ", "))\n"
            }
            if !service.optionalCharacteristics.isEmpty {
                contents += " * Optional characteristics: \(service.optionalCharacteristics.joined(separator: ", "))\n"
            }
            contents += " */\n"

            if service.deprecated {
                contents += "/** @deprecated HomeKit marks this service as deprecated */\n"
            }

            let serviceTypeConstant = "ServiceTypes.\(makeTypeScriptConstantName(from: service.swiftName))"
            contents += "export interface \(typeName) extends Service<\(serviceTypeConstant)> {\n"
            contents += "  type: \(serviceTypeConstant);\n"
            
            // Required characteristics as direct properties
            for charName in service.requiredCharacteristics.sorted() {
                if let typeName = characteristicTypeNames[charName] {
                    let key = makeCharacteristicKey(charName)
                    contents += "  /** Required */\n"
                    contents += "  \(key): \(typeName);\n"
                }
            }

            // Optional characteristics as optional properties
            for charName in service.optionalCharacteristics.sorted() {
                if let typeName = characteristicTypeNames[charName] {
                    let key = makeCharacteristicKey(charName)
                    contents += "  /** Optional */\n"
                    contents += "  \(key)?: \(typeName);\n"
                }
            }

            contents += "}\n"
            try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    // MARK: - Index Generation

    private func generateIndexFile(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("index.ts")
        var contents = fileHeader()
        contents += "\n/**\n * HomeKit type definitions and service catalog.\n * Auto-generated from homekit-services.yaml.\n */\n\n"

        // Export type enums
        contents += "export { ServiceTypes } from './serviceTypes';\n"
        contents += "export { CharacteristicTypes } from './characteristicTypes';\n"
        contents += "export type {\n"
        
        for characteristic in catalog.characteristics.sorted(by: { $0.name < $1.name }) {
            let typeName = makeTypeScriptTypeName(from: characteristic.swiftName)
            contents += "  \(typeName),\n"
        }
        contents += "} from './characteristics';\n\n"

        // Export service types
        contents += "export type {\n"
        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            let typeName = "\(service.name)Service"
            contents += "  \(typeName),\n"
        }
        contents += "} from './services';\n"

        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Generate services/index.ts as well
        let servicesIndexURL = outputURL.appendingPathComponent("services", isDirectory: true).appendingPathComponent("index.ts")
        var servicesContents = fileHeader()
        servicesContents += "\n/**\n * HomeKit service type exports.\n * Auto-generated from homekit-services.yaml.\n */\n\n"
        
        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            let typeName = "\(service.name)Service"
            servicesContents += "export type { \(typeName) } from './\(typeName)';\n"
        }
        
        try servicesContents.write(to: servicesIndexURL, atomically: true, encoding: .utf8)
    }

    // MARK: - Helper Methods

    private func fileHeader() -> String {
        return """
        // Auto-generated TypeScript definitions for HomeKit services and characteristics
        // Generated by HomeKitServiceGenerator - DO NOT EDIT MANUALLY
        // Source: homekit-services.yaml
        """
    }

    private func makeTypeScriptConstantName(from swiftName: String) -> String {
        // Convert to UPPER_SNAKE_CASE for constants
        var result = ""
        for (index, char) in swiftName.enumerated() {
            if index > 0 && char.isUppercase {
                result.append("_")
            }
            result.append(char.uppercased())
        }
        return result
    }

    private func makeTypeScriptTypeName(from swiftName: String) -> String {
        // Keep PascalCase for type names
        return swiftName
    }

    private func makeCharacteristicKey(_ name: String) -> String {
        // The characteristic name is the display name (e.g., "PowerState", "CurrentPosition")
        // Convert PascalCase to camelCase
        guard !name.isEmpty else { return name }
        
        let first = name.prefix(1).lowercased()
        let rest = name.dropFirst()
        return first + rest
    }

    private func mapValueType(_ swiftType: String) -> String {
        // Map Swift types to TypeScript types
        switch swiftType.lowercased() {
        case "bool": return "boolean"
        case "int", "uint8", "uint16", "uint32", "uint64", "int32": return "number"
        case "double", "float": return "number"
        case "string": return "string"
        case "data": return "string" // Base64 encoded
        case "tlv8": return "string" // Base64 encoded
        default: return "any"
        }
    }
}
