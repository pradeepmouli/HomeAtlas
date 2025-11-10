import Foundation

struct ServiceGenerator {
    private let catalog: HomeKitCatalogYAML
    private let fileManager: FileManager

    init(catalog: HomeKitCatalogYAML, fileManager: FileManager = .default) {
        self.catalog = catalog
        self.fileManager = fileManager
    }

    func generateAll(to outputPath: String) throws {
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)

        if fileManager.fileExists(atPath: outputURL.path) {
            try cleanDirectory(at: outputURL)
        } else {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true)
        }

        let servicesDir = outputURL.appendingPathComponent("Services", isDirectory: true)
        let characteristicsDir = outputURL.appendingPathComponent("Characteristics", isDirectory: true)
        try fileManager.createDirectory(at: servicesDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: characteristicsDir, withIntermediateDirectories: true)

        let serviceConstantNames = try generateServiceTypeFile(at: outputURL)
        let characteristicConstantNames = try generateCharacteristicTypeFile(at: outputURL)
        let characteristicTypeNames = try generateCharacteristicWrappers(
            at: characteristicsDir,
            characteristicConstantNames: characteristicConstantNames
        )

        let characteristicsByName = Dictionary(uniqueKeysWithValues: catalog.characteristics.map { ($0.name, $0) })

        for service in catalog.services.sorted(by: { $0.name < $1.name }) {
            try generateServiceClass(
                for: service,
                at: servicesDir,
                serviceConstantNames: serviceConstantNames,
                characteristicConstantNames: characteristicConstantNames,
                characteristicsByName: characteristicsByName,
                characteristicTypeNames: characteristicTypeNames
            )
        }
    }

    // MARK: - Directory Management

    private func cleanDirectory(at url: URL) throws {
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        for entry in contents {
            try fileManager.removeItem(at: entry)
        }
    }

    // MARK: - Type Constants

    private func generateServiceTypeFile(at outputURL: URL) throws -> [String: String] {
        var usedNames = Set<String>()
        var nameMap: [String: String] = [:]

        let sortedServices = catalog.services.sorted(by: { $0.name < $1.name })
        var homeKitLines: [String] = []
        var fallbackLines: [String] = []

        for service in sortedServices {
            let constantName = makeConstantName(
                primary: service.swiftName,
                fallback: service.name,
                suffix: "Service",
                usedNames: &usedNames
            )
            nameMap[service.name] = constantName

            let doc = documentationComment(for: service.documentation, defaultText: "Service type identifier for \(service.name).")
            homeKitLines.append("    /// \(doc)\n    static let \(constantName): String = \(service.identifier)")
            fallbackLines.append("    /// \(doc)\n    static let \(constantName): String = \"\(service.identifier)\"")
        }

        let header = generatedFileHeader()
        var contents = header
        contents += "#if canImport(HomeKit)\nimport HomeKit\n#endif\n\n"
        contents += "#if canImport(HomeKit)\npublic extension ServiceType {\n"
        contents += homeKitLines.joined(separator: "\n\n")
        contents += "\n}\n#else\npublic extension ServiceType {\n"
        contents += fallbackLines.joined(separator: "\n\n")
        contents += "\n}\n#endif\n"

        let fileURL = outputURL.appendingPathComponent("ServiceType+Generated.swift")
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)

        return nameMap
    }

    private func generateCharacteristicTypeFile(at outputURL: URL) throws -> [String: String] {
        var usedNames = Set<String>()
        var nameMap: [String: String] = [:]

        let sortedCharacteristics = catalog.characteristics.sorted(by: { $0.name < $1.name })
        var homeKitLines: [String] = []
        var fallbackLines: [String] = []

        for characteristic in sortedCharacteristics {
            let constantName = makeConstantName(
                primary: characteristic.swiftName,
                fallback: characteristic.name,
                suffix: "Characteristic",
                usedNames: &usedNames
            )
            nameMap[characteristic.name] = constantName

            let doc = documentationComment(for: characteristic.documentation, defaultText: "Characteristic type identifier for \(characteristic.name).")
            homeKitLines.append("    /// \(doc)\n    static let \(constantName): String = \(characteristic.identifier)")
            fallbackLines.append("    /// \(doc)\n    static let \(constantName): String = \"\(characteristic.identifier)\"")
        }

        let header = generatedFileHeader()
        var contents = header
        contents += "#if canImport(HomeKit)\nimport HomeKit\n#endif\n\n"
        contents += "#if canImport(HomeKit)\npublic extension CharacteristicType {\n"
        contents += homeKitLines.joined(separator: "\n\n")
        contents += "\n}\n#else\npublic extension CharacteristicType {\n"
        contents += fallbackLines.joined(separator: "\n\n")
        contents += "\n}\n#endif\n"

        let fileURL = outputURL.appendingPathComponent("CharacteristicType+Generated.swift")
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)

        return nameMap
    }

    private func generateCharacteristicWrappers(
        at characteristicsDir: URL,
        characteristicConstantNames: [String: String]
    ) throws -> [String: String] {
        var usedTypeNames = Set<String>()
        var nameMap: [String: String] = [:]

        for characteristic in catalog.characteristics.sorted(by: { $0.name < $1.name }) {
            guard let constantName = characteristicConstantNames[characteristic.name] else {
                print("⚠️  Missing constant mapping for characteristic \(characteristic.name)")
                continue
            }

            let typeName = makeCharacteristicTypeName(
                primary: characteristic.swiftName,
                fallback: characteristic.name,
                usedNames: &usedTypeNames
            )
            nameMap[characteristic.name] = typeName

            let valueType = characteristicValueType(for: characteristic.valueType)
            let doc = documentationComment(
                for: characteristic.documentation,
                defaultText: "Strongly-typed wrapper for \(characteristic.name) characteristic."
            )

            let fileURL = characteristicsDir.appendingPathComponent("\(typeName).swift")
            var contents = generatedFileHeader()
            contents += "#if canImport(HomeKit)\nimport HomeKit\n#endif\n\n"
            contents += "#if canImport(HomeKit)\n"
            contents += "/// \(doc)\n"
            if characteristic.deprecated {
                contents += "@available(*, deprecated, message: \"HomeKit marks this characteristic as deprecated.\")\n"
            }
            contents += "@MainActor\npublic final class \(typeName): Characteristic<\(valueType)>, GeneratedCharacteristic {\n"
            contents += "    public typealias WrappedValue = \(valueType)\n"
            contents += "    public static let characteristicType: String = CharacteristicType.\(constantName)\n\n"
            contents += "    public override init(underlying: HMCharacteristic) {\n        super.init(underlying: underlying)\n    }\n}\n"
            contents += "#else\npublic typealias \(typeName) = Characteristic<\(valueType)>\n#endif\n"

            try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        }

        return nameMap
    }

    // MARK: - Service Class Generation

    private func generateServiceClass(
        for service: ServiceEntryYAML,
        at servicesDir: URL,
        serviceConstantNames: [String: String],
        characteristicConstantNames: [String: String],
        characteristicsByName: [String: CharacteristicEntryYAML],
        characteristicTypeNames: [String: String]
    ) throws {
        let header = generatedFileHeader()
        let typeName = "\(service.name)Service"
        let fileURL = servicesDir.appendingPathComponent("\(typeName).swift")
        let serviceConstant = serviceConstantNames[service.name] ?? makeFallbackName(from: service.swiftName)

        var contents = header
        contents += "#if canImport(HomeKit)\nimport HomeKit\n#endif\n\n"
        contents += "@MainActor\npublic final class \(typeName): Service, GeneratedService {\n"
        contents += "    public static let serviceType: String = ServiceType.\(serviceConstant)\n"

        let requiredConstLines = makeCharacteristicArray(
            entries: service.requiredCharacteristics,
            label: "requiredCharacteristicTypes",
            characteristicConstantNames: characteristicConstantNames
        )
        if let requiredConstLines {
            contents += "\n" + requiredConstLines
        }

        let optionalConstLines = makeCharacteristicArray(
            entries: service.optionalCharacteristics,
            label: "optionalCharacteristicTypes",
            characteristicConstantNames: characteristicConstantNames
        )
        if let optionalConstLines {
            contents += "\n" + optionalConstLines
        }

        contents += "\n#if canImport(HomeKit)\n    public init(underlying: HMService) {\n        super.init(underlying: underlying)\n    }\n\n    public convenience init?(service: Service) {\n        guard service.serviceType == Self.serviceType else { return nil }\n        self.init(underlying: service.underlying)\n    }\n#endif\n"

        var usedPropertyNames = Set<String>()
        let orderedCharacteristics = orderedCharacteristicEntries(
            required: service.requiredCharacteristics,
            optional: service.optionalCharacteristics
        )

        for entry in orderedCharacteristics {
            guard let characteristic = characteristicsByName[entry.name] else {
                print("⚠️  Skipping unknown characteristic \(entry.name) for service \(service.name)")
                continue
            }

            guard let constantName = characteristicConstantNames[entry.name] else {
                print("⚠️  Missing constant mapping for characteristic \(entry.name)")
                continue
            }

            let propertyName = makePropertyName(
                from: characteristic.swiftName,
                fallback: characteristic.name,
                usedNames: &usedPropertyNames
            )
            let genericType = characteristicValueType(for: characteristic.valueType)
            let commentPrefix = entry.isRequired ? "Required" : "Optional"
            let doc = documentationComment(for: characteristic.documentation, defaultText: "\(commentPrefix) characteristic: \(characteristic.name).")

            if let wrapperType = characteristicTypeNames[entry.name] {
                contents += "\n    /// \(doc)\n    public var \(propertyName): \(wrapperType)? {\n#if canImport(HomeKit)\n        characteristic(\(wrapperType).self)\n#else\n        characteristic(ofType: CharacteristicType.\(constantName))\n#endif\n    }\n"
            } else {
                contents += "\n    /// \(doc)\n    public var \(propertyName): Characteristic<\(genericType)>? {\n        characteristic(ofType: CharacteristicType.\(constantName))\n    }\n"
            }
        }

        contents += "}\n"

        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func makeCharacteristicArray(entries: [String], label: String, characteristicConstantNames: [String: String]) -> String? {
        guard !entries.isEmpty else { return nil }
        let resolved = entries.compactMap { characteristicConstantNames[$0] }
        guard !resolved.isEmpty else { return nil }

        let joined = resolved.map { "        CharacteristicType.\($0)" }.joined(separator: ",\n")
        return "    public static let \(label): [String] = [\n\(joined)\n    ]\n"
    }

    private func orderedCharacteristicEntries(required: [String], optional: [String]) -> [(name: String, isRequired: Bool)] {
        var seen = Set<String>()
        var ordered: [(name: String, isRequired: Bool)] = []

        for name in required {
            if seen.insert(name).inserted {
                ordered.append((name, true))
            }
        }

        for name in optional {
            if seen.insert(name).inserted {
                ordered.append((name, false))
            }
        }

        return ordered
    }

    // MARK: - Helpers

    private func generatedFileHeader() -> String {
        "// AUTO-GENERATED BY HomeKitServiceGenerator -- DO NOT EDIT\n// Generated on \(ISO8601DateFormatter().string(from: Date()))\n\nimport Foundation\n\n"
    }

    private func makeConstantName(primary: String, fallback: String, suffix: String, usedNames: inout Set<String>) -> String {
        let preferred = primary.isEmpty ? fallback : primary
        var candidate = sanitizeIdentifier(preferred)
        if candidate.isEmpty {
            candidate = sanitizeIdentifier(fallback)
        }

        if reservedConstantNames.contains(candidate) {
            candidate += suffix
        }

        if candidate.first?.isNumber == true {
            candidate = "_" + candidate
        }

        var unique = candidate
        var index = 2
        while usedNames.contains(unique) {
            unique = candidate + String(index)
            index += 1
        }
        usedNames.insert(unique)

        if swiftKeywords.contains(unique) {
            return "`\(unique)`"
        }
        return unique
    }

    private func makePropertyName(from primary: String, fallback: String, usedNames: inout Set<String>) -> String {
        let preferred = primary.isEmpty ? fallback : primary
        var candidate = sanitizeIdentifier(preferred)
        if candidate.isEmpty {
            candidate = sanitizeIdentifier(fallback)
        }

        if reservedPropertyNames.contains(candidate) {
            candidate += "Characteristic"
        }

        if candidate.first?.isNumber == true {
            candidate = "_" + candidate
        }

        var unique = candidate
        var index = 2
        while usedNames.contains(unique) {
            unique = candidate + String(index)
            index += 1
        }
        usedNames.insert(unique)

        if swiftKeywords.contains(unique) {
            return "`\(unique)`"
        }
        return unique
    }

    private func sanitizeIdentifier(_ raw: String) -> String {
        guard !raw.isEmpty else { return "" }
        var result = ""
        result.reserveCapacity(raw.count)
        for character in raw {
            if character.isLetter || character.isNumber || character == "_" {
                result.append(character)
            }
        }
        if let first = result.first {
            let lowerFirst = String(first).lowercased()
            result.replaceSubrange(result.startIndex...result.startIndex, with: lowerFirst)
        }
        return result
    }

    private func documentationComment(for documentation: String?, defaultText: String) -> String {
        let preferred = documentation?.isEmpty == false ? documentation! : defaultText
        return preferred.replacingOccurrences(of: "\"", with: "\\\"")
    }

    private func characteristicValueType(for valueType: String) -> String {
        switch valueType.lowercased() {
        case "bool":
            return "Bool"
        case "int":
            return "Int"
        case "double", "float":
            return "Double"
        case "data":
            return "Data"
        default:
            return "String"
        }
    }

    private func makeFallbackName(from raw: String) -> String {
        let cleaned = sanitizeIdentifier(raw)
        return swiftKeywords.contains(cleaned) ? "`\(cleaned)`" : cleaned
    }

    private func makeCharacteristicTypeName(primary: String, fallback: String, usedNames: inout Set<String>) -> String {
        let preferred = primary.isEmpty ? fallback : primary
        var candidate = sanitizeIdentifier(preferred)
        if candidate.isEmpty {
            candidate = sanitizeIdentifier(fallback)
        }

        if candidate.lowercased().hasSuffix("characteristic") {
            let endIndex = candidate.index(candidate.endIndex, offsetBy: -"characteristic".count)
            candidate = String(candidate[..<endIndex])
        }

        if candidate.isEmpty {
            candidate = "Characteristic"
        }

        candidate = capitalizeFirstIdentifier(candidate)

        var base = candidate.hasSuffix("Characteristic") ? candidate : candidate + "Characteristic"

        if base.first?.isNumber == true {
            base = "_" + base
        }

        var unique = base
        var index = 2
        while usedNames.contains(unique) {
            unique = base + String(index)
            index += 1
        }
        usedNames.insert(unique)

        if swiftKeywords.contains(unique) {
            return "`\(unique)`"
        }

        return unique
    }

    private func capitalizeFirstIdentifier(_ identifier: String) -> String {
        guard let first = identifier.first else { return identifier }
        var result = identifier
        result.replaceSubrange(result.startIndex...result.startIndex, with: String(first).uppercased())
        return result
    }

    private let reservedConstantNames: Set<String> = [
        "serviceType",
        "characteristicType"
    ]

    private let reservedPropertyNames: Set<String> = [
        "serviceType",
        "name",
        "accessory",
        "isPrimaryService",
        "isUserInteractive",
        "uniqueIdentifier",
        "allCharacteristics",
        "characteristic",
        "description",
        "hashValue"
    ]

    private let swiftKeywords: Set<String> = [
        "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import",
        "init", "inout", "internal", "let", "operator", "private", "protocol", "public",
        "static", "struct", "subscript", "typealias", "var", "break", "case", "continue",
        "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat",
        "return", "switch", "where", "while", "as", "any", "catch", "false", "is", "nil", "rethrows",
        "super", "self", "throw", "throws", "true", "try", "_", "associativity", "convenience",
        "dynamic", "didset", "final", "get", "infix", "indirect", "lazy", "left", "mutating",
        "none", "nonmutating", "optional", "override", "postfix", "precedence", "prefix",
        "Protocol", "required", "right", "set", "some", "type", "unowned", "weak", "willset"
    ]
}
