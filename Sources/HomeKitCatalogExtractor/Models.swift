import Foundation

/// Represents a HomeKit service extracted from SDK
struct ServiceEntry: Codable {
    let identifier: String
    let name: String
    let swiftName: String
    let documentation: String?
    let deprecated: Bool
    var requiredCharacteristics: [String] = []
    var optionalCharacteristics: [String] = []
}

/// Represents a HomeKit characteristic extracted from SDK
struct CharacteristicEntry: Codable {
    let identifier: String
    let name: String
    let swiftName: String
    var valueType: String
    let documentation: String?
    let deprecated: Bool
}

/// Complete HomeKit catalog extracted from SDK
struct HomeKitCatalog: Codable {
    let services: [ServiceEntry]
    let characteristics: [CharacteristicEntry]

    func writeYAML(to path: String) throws {
        // Ensure output directory exists
        let url = URL(fileURLWithPath: path)
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        var yaml = "# HomeKit Services and Characteristics Catalog\n"
        yaml += "# Auto-generated from iOS SDK headers\n"
        yaml += "# Generated: \(ISO8601DateFormatter().string(from: Date()))\n\n"

        // Write services
        yaml += "services:\n"
        for service in services.sorted(by: { $0.name < $1.name }) {
            yaml += "  - identifier: \(service.identifier)\n"
            yaml += "    name: \(service.name)\n"
            yaml += "    swiftName: \(service.swiftName)\n"
            if let doc = service.documentation {
                yaml += "    documentation: \"\(doc.replacingOccurrences(of: "\"", with: "\\\""))\"\n"
            }
            if service.deprecated {
                yaml += "    deprecated: true\n"
            }

            // Add characteristic lists
            if !service.requiredCharacteristics.isEmpty {
                yaml += "    requiredCharacteristics:\n"
                for char in service.requiredCharacteristics {
                    yaml += "      - \(char)\n"
                }
            }
            if !service.optionalCharacteristics.isEmpty {
                yaml += "    optionalCharacteristics:\n"
                for char in service.optionalCharacteristics {
                    yaml += "      - \(char)\n"
                }
            }

            yaml += "\n"
        }

        // Write characteristics
        yaml += "characteristics:\n"
        for characteristic in characteristics.sorted(by: { $0.name < $1.name }) {
            yaml += "  - identifier: \(characteristic.identifier)\n"
            yaml += "    name: \(characteristic.name)\n"
            yaml += "    swiftName: \(characteristic.swiftName)\n"
            yaml += "    valueType: \(characteristic.valueType)\n"
            if let doc = characteristic.documentation {
                yaml += "    documentation: \"\(doc.replacingOccurrences(of: "\"", with: "\\\""))\"\n"
            }
            if characteristic.deprecated {
                yaml += "    deprecated: true\n"
            }
            yaml += "\n"
        }

        try yaml.write(to: url, atomically: true, encoding: .utf8)
    }
}
