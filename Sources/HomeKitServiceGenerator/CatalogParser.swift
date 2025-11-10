import Foundation

/// YAML catalog structure matching the extractor output
struct HomeKitCatalogYAML: Codable {
    let services: [ServiceEntryYAML]
    let characteristics: [CharacteristicEntryYAML]

    static func load(from path: String) throws -> HomeKitCatalogYAML {
        let url = URL(fileURLWithPath: path)
        let content = try String(contentsOf: url, encoding: .utf8)
        return try parseYAML(content)
    }

    private static func parseYAML(_ content: String) throws -> HomeKitCatalogYAML {
        // Simple YAML parser for our specific format
        var services: [ServiceEntryYAML] = []
        var characteristics: [CharacteristicEntryYAML] = []

        enum Section {
            case services
            case characteristics
        }

        var currentSection: Section? = nil
        var currentServiceScalars: [String: String] = [:]
        var currentServiceArrays: [String: [String]] = [:]
        var currentCharacteristic: [String: String] = [:]
        var activeListKey: String? = nil

        func flushService() {
            guard !currentServiceScalars.isEmpty else { return }
            if let service = ServiceEntryYAML(from: currentServiceScalars, arrays: currentServiceArrays) {
                services.append(service)
            }
            currentServiceScalars.removeAll(keepingCapacity: true)
            currentServiceArrays.removeAll(keepingCapacity: true)
        }

        func flushCharacteristic() {
            guard !currentCharacteristic.isEmpty else { return }
            if let characteristic = CharacteristicEntryYAML(from: currentCharacteristic) {
                characteristics.append(characteristic)
            }
            currentCharacteristic.removeAll(keepingCapacity: true)
        }

        for rawLine in content.split(separator: "\n") {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            // Skip comments and empty lines
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            // Section headers
            if trimmed == "services:" {
                flushService()
                flushCharacteristic()
                currentSection = .services
                activeListKey = nil
                continue
            } else if trimmed == "characteristics:" {
                flushService()
                flushCharacteristic()
                currentSection = .characteristics
                activeListKey = nil
                continue
            }

            // Start of a new mapping entry
            if trimmed.hasPrefix("- identifier:") {
                if currentSection == .services {
                    flushService()
                } else if currentSection == .characteristics {
                    flushCharacteristic()
                }
            }

            // List item without explicit key (e.g., "- Active")
            if trimmed.hasPrefix("- ") && !trimmed.contains(":") {
                if let listKey = activeListKey {
                    let value = String(trimmed.dropFirst(2))
                    if currentSection == .services {
                        currentServiceArrays[listKey, default: []].append(value)
                    }
                }
                continue
            }

            // Parse key-value pairs
            guard let colonIndex = trimmed.firstIndex(of: ":") else {
                continue
            }

            var key = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            var value = String(trimmed[trimmed.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)

            if key.hasPrefix("- ") {
                key = String(key.dropFirst(2))
            }

            if value.isEmpty {
                activeListKey = key
                if currentSection == .services && currentServiceArrays[key] == nil {
                    currentServiceArrays[key] = []
                }
                continue
            } else {
                activeListKey = nil
            }

            if value.hasPrefix("\"") && value.hasSuffix("\"") && value.count >= 2 {
                value = String(value.dropFirst().dropLast())
            }

            switch currentSection {
            case .services:
                currentServiceScalars[key] = value
            case .characteristics:
                currentCharacteristic[key] = value
            case .none:
                break
            }
        }

        flushService()
        flushCharacteristic()

        return HomeKitCatalogYAML(services: services, characteristics: characteristics)
    }

}

struct ServiceEntryYAML: Codable {
    let identifier: String
    let name: String
    let swiftName: String
    let documentation: String?
    let deprecated: Bool
    let requiredCharacteristics: [String]
    let optionalCharacteristics: [String]

    init?(from dict: [String: String], arrays: [String: [String]]) {
        guard let identifier = dict["identifier"],
              let name = dict["name"],
              let swiftName = dict["swiftName"] else {
            return nil
        }

        self.identifier = identifier
        self.name = name
        self.swiftName = swiftName
        self.documentation = dict["documentation"]
        self.deprecated = dict["deprecated"] == "true"
        self.requiredCharacteristics = arrays["requiredCharacteristics"] ?? []
        self.optionalCharacteristics = arrays["optionalCharacteristics"] ?? []
    }
}

struct CharacteristicEntryYAML: Codable {
    let identifier: String
    let name: String
    let swiftName: String
    let valueType: String
    let documentation: String?
    let deprecated: Bool

    init?(from dict: [String: String]) {
        guard let identifier = dict["identifier"],
              let name = dict["name"],
              let swiftName = dict["swiftName"],
              let valueType = dict["valueType"] else {
            return nil
        }

        self.identifier = identifier
        self.name = name
        self.swiftName = swiftName
        self.valueType = valueType
        self.documentation = dict["documentation"]
        self.deprecated = dict["deprecated"] == "true"
    }
}
