import Foundation

struct ServiceCharacteristicRelationship {
    let serviceName: String
    let rawServiceDescription: String
    let requiredCharacteristicNames: [String]
    let optionalCharacteristicNames: [String]
}

struct MetadataParseResult {
    let relationships: [ServiceCharacteristicRelationship]
    let characteristicFormats: [String: String]
}

enum MetadataParserError: Error, CustomStringConvertible {
    case metadataFileMissing(String)
    case invalidRootStructure
    case missingHAPSection

    var description: String {
        switch self {
        case .metadataFileMissing(let path):
            return "Metadata file not found at \(path)"
        case .invalidRootStructure:
            return "Unexpected metadata plist structure"
        case .missingHAPSection:
            return "Metadata plist missing HAP definitions"
        }
    }
}

struct MetadataParser {
    private let metadataPath: String

    init(metadataPath: String) {
        self.metadataPath = metadataPath
    }

    func loadServiceCharacteristicRelationships() throws -> MetadataParseResult {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: metadataPath) else {
            throw MetadataParserError.metadataFileMissing(metadataPath)
        }

        let url = URL(fileURLWithPath: metadataPath)
        let data = try Data(contentsOf: url)
        var format = PropertyListSerialization.PropertyListFormat.binary

        guard let root = try PropertyListSerialization.propertyList(from: data, options: [], format: &format) as? [String: Any] else {
            throw MetadataParserError.invalidRootStructure
        }

        guard let plistDictionary = root["PlistDictionary"] as? [String: Any],
              let hap = plistDictionary["HAP"] as? [String: Any],
              let services = hap["Services"] as? [String: Any],
              let characteristics = hap["Characteristics"] as? [String: Any] else {
            throw MetadataParserError.missingHAPSection
        }

    let lookup = buildCharacteristicNameLookup(from: characteristics)
    let characteristicNameMap = lookup.identifierMap
    let characteristicFormats = lookup.formatByName

        var relationships: [ServiceCharacteristicRelationship] = []
        relationships.reserveCapacity(services.count)

        for (_, value) in services {
            guard let service = value as? [String: Any],
                  let description = service["DefaultDescription"] as? String,
                  let characteristicBlock = service["Characteristics"] as? [String: Any] else {
                continue
            }

            let requiredUUIDs = stringArray(from: characteristicBlock["Required"])
            let optionalUUIDs = stringArray(from: characteristicBlock["Optional"])

            let requiredNames = uniquePreservingOrder(requiredUUIDs.compactMap { characteristicNameMap[$0.uppercased()] })
            let optionalNames = uniquePreservingOrder(optionalUUIDs.compactMap { characteristicNameMap[$0.uppercased()] })

            let relationship = ServiceCharacteristicRelationship(
                serviceName: canonicalIdentifier(from: description),
                rawServiceDescription: description,
                requiredCharacteristicNames: requiredNames,
                optionalCharacteristicNames: optionalNames
            )
            relationships.append(relationship)
        }

        return MetadataParseResult(relationships: relationships, characteristicFormats: characteristicFormats)
    }

    private func buildCharacteristicNameLookup(from dictionary: [String: Any]) -> (identifierMap: [String: String], formatByName: [String: String]) {
        var map: [String: String] = [:]
        map.reserveCapacity(dictionary.count)
        var formats: [String: String] = [:]

        for (key, value) in dictionary {
            guard let entry = value as? [String: Any],
                  let description = entry["DefaultDescription"] as? String else {
                continue
            }

            let identifier = canonicalIdentifier(from: description)

            if let format = entry["Format"] as? String {
                formats[identifier] = format.lowercased()
            }

            if let shortUUID = entry["ShortUUID"] as? String {
                map[shortUUID.uppercased()] = identifier
            }
            map[key.uppercased()] = identifier
            if let longUUID = entry["UUID"] as? String {
                map[longUUID.uppercased()] = identifier
            }
        }

        return (identifierMap: map, formatByName: formats)
    }

    private func canonicalIdentifier(from description: String) -> String {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return ""
        }

        let words = trimmed.split(separator: " ").map { word -> String in
            guard let first = word.first else { return "" }
            let rest = word.dropFirst()
            return String(first).uppercased() + rest
        }

        let joined = words.joined()
        let withoutHyphen = joined.replacingOccurrences(of: "-", with: "")
        var result = ""
        result.reserveCapacity(withoutHyphen.count)
        for character in withoutHyphen {
            if character == "." {
                result.append("_")
                continue
            }
            if character.isLetter || character.isNumber || character == "_" {
                result.append(character)
            }
        }
        return result
    }

    private func stringArray(from value: Any?) -> [String] {
        guard let array = value as? [Any] else {
            return []
        }
        return array.compactMap { element -> String? in
            if let string = element as? String {
                return string
            }
            if let number = element as? NSNumber {
                return number.stringValue
            }
            return nil
        }
    }

    private func uniquePreservingOrder(_ values: [String]) -> [String] {
        var seen = Set<String>()
        var output: [String] = []
        for value in values where !value.isEmpty {
            if seen.insert(value).inserted {
                output.append(value)
            }
        }
        return output
    }
}
