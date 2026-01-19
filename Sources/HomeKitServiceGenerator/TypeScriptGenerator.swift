import Foundation

/// Generates TypeScript type definitions from HomeKit catalog
struct TypeScriptGenerator {
    private let catalog: HomeKitCatalogYAML
    private let fileManager: FileManager
    
    init(catalog: HomeKitCatalogYAML, fileManager: FileManager = .default) {
        self.catalog = catalog
        self.fileManager = fileManager
    }
    
    // MARK: - Main Generation Entry Point
    
    func generateAll(to outputPath: String) throws {
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        
        if fileManager.fileExists(atPath: outputURL.path) {
            try cleanDirectory(at: outputURL)
        } else {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true)
        }
        
        let servicesDir = outputURL.appendingPathComponent("services", isDirectory: true)
        try fileManager.createDirectory(at: servicesDir, withIntermediateDirectories: true)
        
        // Generate enums and base types
        try generateServiceTypesEnum(at: outputURL)
        try generateCharacteristicTypesEnum(at: outputURL)
        try generateCharacteristicTypeDefinitions(at: outputURL)
        
        // Generate service interfaces
        try generateServiceInterfaces(at: servicesDir)
        
        // Generate index file
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
    
    // MARK: - Type Mapping (T072)
    
    /// Maps Swift/HomeKit value types to TypeScript types
    private func swiftToTypeScriptType(_ swiftType: String) -> String {
        switch swiftType.lowercased() {
        case "bool":
            return "boolean"
        case "int", "uint", "int8", "uint8", "int16", "uint16", "int32", "uint32", "int64", "uint64":
            return "number"
        case "double", "float", "cgfloat":
            return "number"
        case "string":
            return "string"
        case "data":
            return "number[]" // Data is represented as byte array
        case "uuid":
            return "string"
        default:
            // Handle Optional<T> -> T | null
            if swiftType.hasPrefix("Optional<") {
                let innerType = String(swiftType.dropFirst(9).dropLast())
                return "\(swiftToTypeScriptType(innerType)) | null"
            }
            // Handle Array<T> or [T] -> T[]
            if swiftType.hasPrefix("Array<") || swiftType.hasPrefix("[") {
                let innerType: String
                if swiftType.hasPrefix("Array<") {
                    innerType = String(swiftType.dropFirst(6).dropLast())
                } else {
                    innerType = String(swiftType.dropFirst().dropLast())
                }
                return "\(swiftToTypeScriptType(innerType))[]"
            }
            return "any"
        }
    }
    
    // MARK: - ServiceTypes Enum Generation (T073)
    
    private func generateServiceTypesEnum(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("serviceTypes.ts")
        var content = generatedFileHeader()
        content += "/**\n * HomeKit Service Type identifiers\n * Auto-generated from HomeKit catalog\n */\n"
        content += "export enum ServiceTypes {\n"
        
        let sortedServices = catalog.services.sorted(by: { $0.name < $1.name })
        for (index, service) in sortedServices.enumerated() {
            let enumKey = makeTypeScriptEnumKey(from: service.swiftName, fallback: service.name)
            let docComment = documentationComment(for: service.documentation, defaultText: "Service type: \(service.name)")
            
            content += "  /** \(docComment) */\n"
            if service.deprecated {
                content += "  /** @deprecated HomeKit marks this service as deprecated */\n"
            }
            content += "  \(enumKey) = '\(service.identifier)'"
            if index < sortedServices.count - 1 {
                content += ","
            }
            content += "\n"
        }
        
        content += "}\n"
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - CharacteristicTypes Enum Generation (T074)
    
    private func generateCharacteristicTypesEnum(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("characteristicTypes.ts")
        var content = generatedFileHeader()
        content += "/**\n * HomeKit Characteristic Type identifiers\n * Auto-generated from HomeKit catalog\n */\n"
        content += "export enum CharacteristicTypes {\n"
        
        let sortedCharacteristics = catalog.characteristics.sorted(by: { $0.name < $1.name })
        for (index, characteristic) in sortedCharacteristics.enumerated() {
            let enumKey = makeTypeScriptEnumKey(from: characteristic.swiftName, fallback: characteristic.name)
            let docComment = documentationComment(for: characteristic.documentation, defaultText: "Characteristic type: \(characteristic.name)")
            
            content += "  /** \(docComment) */\n"
            if characteristic.deprecated {
                content += "  /** @deprecated HomeKit marks this characteristic as deprecated */\n"
            }
            content += "  \(enumKey) = '\(characteristic.identifier)'"
            if index < sortedCharacteristics.count - 1 {
                content += ","
            }
            content += "\n"
        }
        
        content += "}\n"
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Characteristic Type Definitions (T076)
    
    private func generateCharacteristicTypeDefinitions(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("characteristics.ts")
        var content = generatedFileHeader()
        
        content += "/**\n * HomeKit Characteristic Type Definitions\n * Auto-generated from HomeKit catalog\n */\n\n"
        content += "import { Characteristic } from '../types/characteristic';\n\n"
        
        // Create type aliases for each characteristic with proper value type
        let sortedCharacteristics = catalog.characteristics.sorted(by: { $0.name < $1.name })
        for characteristic in sortedCharacteristics {
            let typeName = makeTypeScriptTypeName(from: characteristic.swiftName, fallback: characteristic.name, suffix: "Characteristic")
            let valueType = swiftToTypeScriptType(characteristic.valueType)
            let docComment = documentationComment(for: characteristic.documentation, defaultText: "Type-safe characteristic for \(characteristic.name)")
            
            content += "/**\n * \(docComment)\n"
            if characteristic.deprecated {
                content += " * @deprecated HomeKit marks this characteristic as deprecated\n"
            }
            content += " */\n"
            content += "export type \(typeName) = Characteristic<\(valueType)>;\n\n"
        }
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Service Interface Generation (T075)
    
    private func generateServiceInterfaces(at servicesDir: URL) throws {
        // Build characteristic type map for quick lookup
        var characteristicTypeMap: [String: (valueType: String, deprecated: Bool)] = [:]
        for characteristic in catalog.characteristics {
            characteristicTypeMap[characteristic.name] = (
                valueType: swiftToTypeScriptType(characteristic.valueType),
                deprecated: characteristic.deprecated
            )
        }
        
        // Reserved property names that exist in the base Service interface
        let reservedPropertyNames = Set(["id", "type", "name", "isPrimary", "characteristics"])
        
        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            let typeName = "\(service.name)Service"
            let fileURL = servicesDir.appendingPathComponent("\(typeName).ts")
            
            var content = generatedFileHeader()
            content += "/**\n * \(typeName) interface\n * Auto-generated from HomeKit catalog\n */\n\n"
            content += "import { Service, Characteristic } from '../../types/service';\n\n"
            
            let docComment = documentationComment(for: service.documentation, defaultText: "Service interface for \(service.name)")
            content += "/**\n * \(docComment)\n"
            if service.deprecated {
                content += " * @deprecated HomeKit marks this service as deprecated\n"
            }
            content += " */\n"
            content += "export interface \(typeName) extends Service {\n"
            content += "  /** Service type identifier */\n"
            content += "  readonly type: '\(service.identifier)';\n"
            content += "  /** Service characteristics */\n"
            content += "  readonly characteristics: Characteristic[];\n"
            
            // Add typed characteristic properties
            let allCharacteristics = service.requiredCharacteristics + service.optionalCharacteristics
            var usedPropertyNames = Set<String>()
            
            for charName in allCharacteristics {
                guard let charInfo = characteristicTypeMap[charName] else {
                    continue
                }
                
                let propertyName = makeTypeScriptPropertyName(from: charName, usedNames: &usedPropertyNames)
                
                // Skip properties that conflict with base Service interface
                if reservedPropertyNames.contains(propertyName) {
                    continue
                }
                
                let isRequired = service.requiredCharacteristics.contains(charName)
                let optionalMarker = isRequired ? "" : "?"
                
                content += "\n  /**\n   * \(isRequired ? "Required" : "Optional") characteristic: \(charName)\n"
                if charInfo.deprecated {
                    content += "   * @deprecated HomeKit marks this characteristic as deprecated\n"
                }
                content += "   */\n"
                content += "  readonly \(propertyName)\(optionalMarker): Characteristic<\(charInfo.valueType)>;\n"
            }
            
            content += "}\n"
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
    
    // MARK: - Index File Generation (T077)
    
    private func generateIndexFile(at outputURL: URL) throws {
        let fileURL = outputURL.appendingPathComponent("index.ts")
        var content = generatedFileHeader()
        
        content += "/**\n * Generated HomeKit Type Definitions\n * Re-exports all generated types, enums, and interfaces\n */\n\n"
        
        content += "// Type enums\n"
        content += "export { ServiceTypes } from './serviceTypes';\n"
        content += "export { CharacteristicTypes } from './characteristicTypes';\n\n"
        
        content += "// Characteristic type definitions\n"
        content += "export * from './characteristics';\n\n"
        
        content += "// Service interfaces\n"
        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            let typeName = "\(service.name)Service"
            content += "export { \(typeName) } from './services/\(typeName)';\n"
        }
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Helper Functions
    
    private func generatedFileHeader() -> String {
        let date = ISO8601DateFormatter().string(from: Date())
        return """
        // This file is auto-generated. Do not edit manually.
        // Generated: \(date)
        // Generator: HomeKitServiceGenerator (TypeScript)
        
        
        """
    }
    
    private func documentationComment(for doc: String?, defaultText: String) -> String {
        if let doc = doc, !doc.isEmpty {
            return doc.replacingOccurrences(of: "\n", with: " ")
        }
        return defaultText
    }
    
    private func makeTypeScriptEnumKey(from primary: String, fallback: String) -> String {
        // Convert to SCREAMING_SNAKE_CASE for enum keys
        let name = primary.isEmpty ? fallback : primary
        var result = ""
        var previousWasUpper = true
        
        for char in name {
            if char.isUppercase {
                if !previousWasUpper && !result.isEmpty {
                    result += "_"
                }
                result.append(char)
                previousWasUpper = true
            } else {
                result.append(char.uppercased())
                previousWasUpper = false
            }
        }
        
        // Remove any non-alphanumeric characters except underscore
        result = result.filter { $0.isLetter || $0.isNumber || $0 == "_" }
        
        // Ensure it starts with a letter
        if let first = result.first, first.isNumber {
            result = "N_" + result
        }
        
        return result
    }
    
    private func makeTypeScriptTypeName(from primary: String, fallback: String, suffix: String = "") -> String {
        let name = primary.isEmpty ? fallback : primary
        var result = name.prefix(1).uppercased() + name.dropFirst()
        
        // Remove any non-alphanumeric characters
        result = result.filter { $0.isLetter || $0.isNumber }
        
        return result + suffix
    }
    
    private func makeTypeScriptPropertyName(from characteristicName: String, usedNames: inout Set<String>) -> String {
        // Convert to camelCase
        var result = ""
        var capitalizeNext = false
        
        for char in characteristicName {
            if char == "_" || char == "-" || char == " " {
                capitalizeNext = true
            } else if capitalizeNext {
                result.append(char.uppercased())
                capitalizeNext = false
            } else {
                result.append(char.lowercased())
            }
        }
        
        // Ensure it starts with lowercase
        if let first = result.first, first.isUppercase {
            result = first.lowercased() + result.dropFirst()
        }
        
        // Remove any non-alphanumeric characters
        result = result.filter { $0.isLetter || $0.isNumber }
        
        // Handle collisions
        var candidate = result
        var counter = 2
        while usedNames.contains(candidate) {
            candidate = "\(result)\(counter)"
            counter += 1
        }
        
        usedNames.insert(candidate)
        return candidate
    }
}
