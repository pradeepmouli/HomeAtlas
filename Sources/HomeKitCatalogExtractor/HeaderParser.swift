import Foundation

/// Parses HomeKit header files to extract service and characteristic definitions
struct HeaderParser {
    let frameworkPath: String

    func parseServicesSync() throws -> [ServiceEntry] {
        let headerPath = "\(frameworkPath)/Headers/HMServiceTypes.h"

        print("   Parsing services from: \(headerPath)")

        guard FileManager.default.fileExists(atPath: headerPath) else {
            throw ExtractionError.headerNotFound(headerPath)
        }

        let content = try String(contentsOfFile: headerPath, encoding: .utf8)
        let services = parseServiceDefinitions(from: content)
        print("   Found \(services.count) service definitions")
        return services
    }

    func parseCharacteristicsSync() throws -> [CharacteristicEntry] {
        let headerPath = "\(frameworkPath)/Headers/HMCharacteristicTypes.h"

        print("   Parsing characteristics from: \(headerPath)")

        guard FileManager.default.fileExists(atPath: headerPath) else {
            throw ExtractionError.headerNotFound(headerPath)
        }

        let content = try String(contentsOfFile: headerPath, encoding: .utf8)
        let characteristics = parseCharacteristicDefinitions(from: content)
        print("   Found \(characteristics.count) characteristic definitions")
        return characteristics
    }

    func parseServices() async throws -> [ServiceEntry] {
        try parseServicesSync()
    }

    func parseCharacteristics() async throws -> [CharacteristicEntry] {
        try parseCharacteristicsSync()
    }

    // MARK: - Service Parsing

    private func parseServiceDefinitions(from content: String) -> [ServiceEntry] {
        var services: [ServiceEntry] = []

        // Pattern: HM_EXTERN NSString * const HMServiceType<Name> API_AVAILABLE(...)
        // Example: HM_EXTERN NSString * const HMServiceTypeLightbulb API_AVAILABLE(ios(8.0), ...)
        let pattern = #"HM_EXTERN\s+NSString\s*\*\s*const\s+HMServiceType(\w+)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return services
        }

        let nsContent = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length))

        for match in matches {
            guard match.numberOfRanges >= 2 else { continue }

            let nameRange = match.range(at: 1)
            let name = nsContent.substring(with: nameRange)

            // Swift name is typically the same as the type name but lowercased
            let swiftName = name.prefix(1).lowercased() + name.dropFirst()

            // Extract documentation comment if available
            let documentation = extractDocumentation(for: name, in: content, beforeOffset: match.range.location)

            services.append(ServiceEntry(
                identifier: "HMServiceType\(name)",
                name: name,
                swiftName: swiftName,
                documentation: documentation,
                deprecated: false
            ))
        }

        return services
    }

    // MARK: - Characteristic Parsing

    private func parseCharacteristicDefinitions(from content: String) -> [CharacteristicEntry] {
        var characteristics: [CharacteristicEntry] = []

        // Pattern: HM_EXTERN NSString * const HMCharacteristicType<Name> API_AVAILABLE(...)
        let pattern = #"HM_EXTERN\s+NSString\s*\*\s*const\s+HMCharacteristicType(\w+)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return characteristics
        }

        let nsContent = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length))

        for match in matches {
            guard match.numberOfRanges >= 2 else { continue }

            let nameRange = match.range(at: 1)
            let name = nsContent.substring(with: nameRange)

            // Swift name is typically the same as the type name but lowercased
            let swiftName = name.prefix(1).lowercased() + name.dropFirst()

            // Extract documentation comment if available
            let documentation = extractDocumentation(for: name, in: content, beforeOffset: match.range.location)

            // Infer value type from name (basic heuristics)
            let valueType = inferValueType(from: name)

            characteristics.append(CharacteristicEntry(
                identifier: "HMCharacteristicType\(name)",
                name: name,
                swiftName: swiftName,
                valueType: valueType,
                documentation: documentation,
                deprecated: false
            ))
        }

        return characteristics
    }

    // MARK: - Documentation Extraction

    private func extractDocumentation(for name: String, in content: String, beforeOffset: Int) -> String? {
        let lines = content.prefix(beforeOffset).split(separator: "\n", omittingEmptySubsequences: false)

        // Look backwards for documentation comments
        var docLines: [String] = []
        for line in lines.reversed() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("//") {
                let doc = trimmed.dropFirst(2).trimmingCharacters(in: .whitespaces)
                docLines.insert(doc, at: 0)
            } else if trimmed.hasPrefix("/*") || trimmed.contains("*/") {
                // Skip block comments for now
                break
            } else if !trimmed.isEmpty {
                // Stop at first non-comment line
                break
            }
        }

        return docLines.isEmpty ? nil : docLines.joined(separator: " ")
    }

    // MARK: - Type Inference

    private func inferValueType(from name: String) -> String {
        let lowerName = name.lowercased()

        // Boolean types
        if lowerName.contains("on") || lowerName.contains("active") ||
           lowerName.contains("enabled") || lowerName.contains("detected") ||
           lowerName.contains("muted") {
            return "Bool"
        }

        // Integer types
        if lowerName.contains("brightness") || lowerName.contains("hue") ||
           lowerName.contains("saturation") || lowerName.contains("level") {
            return "Int"
        }

        // Float types
        if lowerName.contains("temperature") || lowerName.contains("humidity") ||
           lowerName.contains("pressure") {
            return "Double"
        }

        // String types
        if lowerName.contains("name") || lowerName.contains("manufacturer") ||
           lowerName.contains("model") || lowerName.contains("serial") ||
           lowerName.contains("version") {
            return "String"
        }

        // Default to String for unknown types
        return "String"
    }
}

enum ExtractionError: Error, CustomStringConvertible {
    case headerNotFound(String)
    case tbdNotFound(String)
    case parseFailure(String)

    var description: String {
        switch self {
        case .headerNotFound(let path):
            return "Header file not found: \(path)"
        case .tbdNotFound(let path):
            return "TBD file not found: \(path)"
        case .parseFailure(let reason):
            return "Parse failure: \(reason)"
        }
    }
}
