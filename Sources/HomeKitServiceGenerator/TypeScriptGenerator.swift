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
        contents += "import { CharacteristicTypes } from './characteristicTypes';\n\n"

        // Generate base characteristic interface
        contents += "/** Base characteristic interface with common properties */\n"
        contents += "export interface CharacteristicBase<T = any> {\n"
        contents += "  type: string;\n"
        contents += "  value: T | null;\n"
        contents += "  format: string;\n"
        contents += "  permissions: string[];\n"
        contents += "  unit?: string;\n"
        contents += "  minValue?: number;\n"
        contents += "  maxValue?: number;\n"
        contents += "  stepValue?: number;\n"
        contents += "  minStep?: number;\n"
        contents += "  maxLength?: number;\n"
        contents += "  validValues?: number[];\n"
        contents += "  validValuesRange?: [number, number];\n"
        contents += "}\n\n"

        // Generate specific characteristic interfaces
        for characteristic in catalog.characteristics.sorted(by: { $0.name < $1.name }) {
            let typeName = makeTypeScriptTypeName(from: characteristic.swiftName)
            let tsValueType = mapValueType(characteristic.valueType)
            let doc = characteristic.documentation ?? characteristic.name

            contents += "/** \(doc) */\n"
            if characteristic.deprecated {
                contents += "/** @deprecated HomeKit marks this characteristic as deprecated */\n"
            }
            contents += "export interface \(typeName) extends CharacteristicBase<\(tsValueType)> {\n"
            contents += "  type: CharacteristicTypes.\(makeTypeScriptConstantName(from: characteristic.swiftName));\n"
            contents += "  value: \(tsValueType) | null;\n"
            contents += "}\n\n"
        }

        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    /// Generate service interfaces with required and optional characteristics
    private func generateServiceInterfaces(at servicesDir: URL) throws {
        let characteristicTypeNames = Dictionary(uniqueKeysWithValues:
            catalog.characteristics.map { ($0.name, makeTypeScriptTypeName(from: $0.swiftName)) }
        )

        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            let typeName = "\(service.name)Service"
            let fileURL = servicesDir.appendingPathComponent("\(typeName).ts")
            var contents = fileHeader()
            contents += "\n/**\n * \(service.name) service interface.\n * Auto-generated from homekit-services.yaml.\n */\n\n"
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

            contents += "export interface \(typeName) {\n"
            contents += "  type: ServiceTypes.\(makeTypeScriptConstantName(from: service.swiftName));\n"
            contents += "  name: string;\n"
            contents += "  isPrimary: boolean;\n"
            contents += "  characteristics: {\n"

            // Required characteristics
            for charName in service.requiredCharacteristics.sorted() {
                if let typeName = characteristicTypeNames[charName] {
                    let key = makeCharacteristicKey(charName)
                    contents += "    /** Required */\n"
                    contents += "    '\(key)': \(typeName);\n"
                }
            }

            // Optional characteristics
            for charName in service.optionalCharacteristics.sorted() {
                if let typeName = characteristicTypeNames[charName] {
                    let key = makeCharacteristicKey(charName)
                    contents += "    /** Optional */\n"
                    contents += "    '\(key)'?: \(typeName);\n"
                }
            }

            contents += "  };\n"
            contents += "}\n"

            try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    /// Generate index file that re-exports all generated types
    private func generateIndexFile(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("index.ts")
        var contents = fileHeader()
        contents += "\n/**\n * Generated HomeKit type definitions index.\n * Auto-generated from homekit-services.yaml.\n */\n\n"

        contents += "// Enums\n"
        contents += "export { ServiceTypes } from './serviceTypes';\n"
        contents += "export { CharacteristicTypes } from './characteristicTypes';\n\n"

        contents += "// Characteristics\n"
        contents += "export type * from './characteristics';\n\n"

        contents += "// Services\n"
        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            contents += "export type { \(service.name)Service } from './services/\(service.name)Service';\n"
        }

        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    // MARK: - Helpers

    private func fileHeader() -> String {
        return """
        /**
         * AUTO-GENERATED FILE - DO NOT EDIT
         * Generated by HomeKitServiceGenerator
         * Date: \(ISO8601DateFormatter().string(from: Date()))
         */
        """
    }

    private func makeTypeScriptConstantName(from swiftName: String) -> String {
        // Convert PascalCase to SCREAMING_SNAKE_CASE
        var result = ""
        for (index, char) in swiftName.enumerated() {
            if char.isUppercase && index > 0 {
                result += "_"
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
        // Convert characteristic name to camelCase key
        let components = name.split(separator: " ")
        guard !components.isEmpty else { return name }

        let first = components[0].lowercased()
        let rest = components.dropFirst().map { $0.capitalized }.joined()
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
