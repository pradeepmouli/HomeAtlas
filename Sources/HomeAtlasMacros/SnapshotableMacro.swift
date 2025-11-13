// @Snapshotable Macro Implementation
// Generates type-safe snapshot structs for HomeAtlas classes

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Macro that generates a type-safe snapshot struct for HomeAtlas classes.
public struct SnapshotableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ensure this is a class declaration
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.notAClass
        }

        let className = classDecl.name.text
        let snapshotName = "\(className)AtlasSnapshot"

        // Determine if the class inherits from Service
        let isService: Bool = classDecl.inheritanceClause?.inheritedTypes.contains(where: { type in
            type.type.trimmedDescription == "Service"
        }) ?? false
        let classIsHome = className == "Home"
        let classIsRoom = className == "Room"
        let classIsZone = className == "Zone"
        let classIsAccessory = className == "Accessory"
        let classIsBaseService = className == "Service"

        // Collect candidate properties
        var characteristicProps: [(name: String, type: String, mappedType: String)] = []
        if isService {
            for member in classDecl.memberBlock.members {
                guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
                // Only consider instance vars
                for binding in varDecl.bindings {
                    guard let ident = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
                    let name = ident.identifier.text
                    guard let typeAnn = binding.typeAnnotation else { continue }
                    let typeName = typeAnn.type.trimmedDescription
                    if typeName.contains("Characteristic") {
                        let mapped = mapCharacteristicTypeToValue(typeName)
                        characteristicProps.append((name: name, type: typeName, mappedType: mapped))
                    }
                }
            }
        }

        // Build struct members
        var memberLines: [String] = []
        var initLines: [String] = []

        if isService {
            memberLines.append("public let serviceType: String")
            memberLines.append("public let name: String?")
            initLines.append("self.serviceType = original.serviceType")
            initLines.append("self.name = original.name.map(anonymizeFn)")
            for prop in characteristicProps {
                memberLines.append("public let \(prop.name): \(prop.mappedType)")
                initLines.append("self.\(prop.name) = try? await original.\(prop.name)?.read()")
            }
        } else if classIsBaseService {
            // Base Service snapshot: include generic characteristic snapshots
            memberLines.append(contentsOf: [
                "public let id: String",
                "public let name: String?",
                "public let serviceType: String",
                "public let characteristics: [CharacteristicSnapshot]"
            ])
            initLines.append(contentsOf: [
                "self.id = anonymizeFn(original.uniqueIdentifier.uuidString)",
                "self.name = original.name.map(anonymizeFn)",
                "self.serviceType = original.serviceType",
                "self.characteristics = original.allCharacteristics().map { c in",
                "    let id = anonymizeFn(c.underlying.uniqueIdentifier.uuidString)",
                "    let characteristicType = c.underlying.characteristicType",
                "    let displayName = c.underlying.localizedDescription",
                "    let unit = c.underlying.metadata?.units?.description",
                "    let min = c.underlying.metadata?.minimumValue as? Double",
                "    let max = c.underlying.metadata?.maximumValue as? Double",
                "    let step = c.underlying.metadata?.stepValue as? Double",
                "    let readable: Bool",
                "    let writable: Bool",
                "    #if canImport(HomeKit)",
                "    let props = c.underlying.properties",
                "    readable = props.contains(\"readable\") || props.contains(\"HMCharacteristicPropertyReadable\")",
                "    writable = props.contains(\"writable\") || props.contains(\"HMCharacteristicPropertyWritable\")",
                "    #else",
                "    readable = false",
                "    writable = false",
                "    #endif",
                "    var value: CharacteristicSnapshot.AnyCodable? = nil",
                "    var reason: String? = nil",
                "    if readable {",
                "        if let v = c.underlying.value {",
                "            value = CharacteristicSnapshot.AnyCodable(v)",
                "        } else {",
                "            reason = \"unavailable\"",
                "        }",
                "    } else {",
                "        reason = \"not-readable\"",
                "    }",
                "    return CharacteristicSnapshot(",
                "        id: id,",
                "        characteristicType: characteristicType,",
                "        displayName: displayName,",
                "        unit: unit,",
                "        min: min,",
                "        max: max,",
                "        step: step,",
                "        readable: readable,",
                "        writable: writable,",
                "        value: value,",
                "        reason: reason",
                "    )",
                "}.sorted(by: { ($0.displayName ?? \"\") < ($1.displayName ?? \"\") })"
            ])

        } else if classIsHome {
            // Home snapshot: id, name, rooms, zones
            memberLines.append(contentsOf: [
                "public let id: String",
                "public let name: String",
                "public let rooms: [RoomAtlasSnapshot]",
                "public let zones: [ZoneAtlasSnapshot]"
            ])
            initLines.append(contentsOf: [
                "self.id = anonymizeFn(original.uniqueIdentifier.uuidString)",
                "self.name = anonymizeFn(original.name)",
                "self.rooms = try await withThrowingTaskGroup(of: RoomAtlasSnapshot.self) { group in",
                "    for room in original.rooms {",
                "        group.addTask { try await RoomAtlasSnapshot(from: Room(room), anonymize: anonymizeFn) }",
                "    }",
                "    var results: [RoomAtlasSnapshot] = []",
                "    for try await snapshot in group {",
                "        results.append(snapshot)",
                "    }",
                "    return results.sorted(by: { $0.name < $1.name })",
                "}",
                "self.zones = try await withThrowingTaskGroup(of: ZoneAtlasSnapshot.self) { group in",
                "    for zone in original.zones {",
                "        group.addTask { try await ZoneAtlasSnapshot(from: Zone(zone), anonymize: anonymizeFn) }",
                "    }",
                "    var results: [ZoneAtlasSnapshot] = []",
                "    for try await snapshot in group {",
                "        results.append(snapshot)",
                "    }",
                "    return results.sorted(by: { $0.name < $1.name })",
                "}"
            ])
        } else if classIsRoom {
            // Room snapshot: id, name, accessories
            memberLines.append(contentsOf: [
                "public let id: String",
                "public let name: String",
                "public let accessories: [AccessoryAtlasSnapshot]"
            ])
            initLines.append(contentsOf: [
                "self.id = anonymizeFn(original.uniqueIdentifier.uuidString)",
                "self.name = anonymizeFn(original.name)",
                "self.accessories = try await withThrowingTaskGroup(of: AccessoryAtlasSnapshot.self) { group in",
                "    for accessory in original.accessories {",
                "        group.addTask { try await AccessoryAtlasSnapshot(from: Accessory(accessory), anonymize: anonymizeFn) }",
                "    }",
                "    var results: [AccessoryAtlasSnapshot] = []",
                "    for try await snapshot in group {",
                "        results.append(snapshot)",
                "    }",
                "    return results.sorted(by: { $0.name < $1.name })",
                "}"
            ])
        } else if classIsZone {
            // Zone snapshot: id, name, roomIds
            memberLines.append(contentsOf: [
                "public let id: String",
                "public let name: String",
                "public let roomIds: [String]"
            ])
            initLines.append(contentsOf: [
                "self.id = anonymizeFn(original.uniqueIdentifier.uuidString)",
                "self.name = anonymizeFn(original.name)",
                "self.roomIds = original.rooms.map { anonymizeFn($0.uniqueIdentifier.uuidString) }.sorted()"
            ])
        } else if classIsAccessory {
            // Accessory snapshot: id, name, services (typed where possible)
            memberLines.append(contentsOf: [
                "public let id: String",
                "public let name: String",
                "public let services: [ServiceAtlasSnapshot]"
            ])
            initLines.append(contentsOf: [
                "self.id = anonymizeFn(original.uniqueIdentifier.uuidString)",
                "self.name = anonymizeFn(original.name)",
                "self.services = try await withThrowingTaskGroup(of: ServiceAtlasSnapshot.self) { group in",
                "    for service in original.allServices() {",
                "        group.addTask { try await ServiceAtlasSnapshot(from: service, anonymize: anonymizeFn) }",
                "    }",
                "    var results: [ServiceAtlasSnapshot] = []",
                "    for try await snapshot in group {",
                "        results.append(snapshot)",
                "    }",
                "    return results.sorted(by: { ($0.name ?? \"\") < ($1.name ?? \"\") })",
                "}"
            ])
        } else {
            // Fallback minimal for unknown classes
            memberLines.append(contentsOf: [
                "public let id: String",
                "public let name: String"
            ])
            initLines.append(contentsOf: [
                "self.id = \"\"",
                "self.name = \"\""
            ])
        }

        let structDecl: DeclSyntax = """
        public struct \(raw: snapshotName): Codable, Sendable {
            \(raw: memberLines.joined(separator: "\n    "))

            @MainActor
            public init(from original: \(raw: className), anonymize: @MainActor @escaping @Sendable (String) -> String = { $0 }) async throws {
                let anonymizeFn = anonymize
                \(raw: initLines.joined(separator: "\n        "))
            }
        }
        """

        return [structDecl]
    }
}

// MARK: - Helpers

/// Map a Characteristic wrapper type to the value type in snapshot
private func mapCharacteristicTypeToValue(_ typeName: String) -> String {
    let bare = typeName.replacingOccurrences(of: "?", with: "")
    // Prefer auto-generated mapping from the catalog/codegen if available.
    if let generated = GeneratedCharacteristicValueMapping[bare] {
        return generated
    }
    let mapping: [String: String] = [
        "PowerStateCharacteristic": "Bool?",
        "BrightnessCharacteristic": "Int?",
        "HueCharacteristic": "Double?",
        "SaturationCharacteristic": "Double?",
        "ColorTemperatureCharacteristic": "Int?",
        "TargetTemperatureCharacteristic": "Double?",
        "CurrentTemperatureCharacteristic": "Double?",
        "NameCharacteristic": "String?",
        // Expanded mappings
        "ActiveCharacteristic": "Int?",
        "BatteryLevelCharacteristic": "Int?",
        "ChargingStateCharacteristic": "Int?",
        "StatusLowBatteryCharacteristic": "Int?",
        "CurrentHeatingCoolingCharacteristic": "Int?",
        "TargetHeatingCoolingCharacteristic": "Int?",
        "CurrentRelativeHumidityCharacteristic": "Double?",
        "TargetRelativeHumidityCharacteristic": "Double?",
        "CoolingThresholdCharacteristic": "Double?",
        "HeatingThresholdCharacteristic": "Double?",
        "TemperatureUnitsCharacteristic": "Int?",
        "MotionDetectedCharacteristic": "Bool?",
        "ContactStateCharacteristic": "Int?",
        "SmokeDetectedCharacteristic": "Int?",
        "LeakDetectedCharacteristic": "Int?",
        "AirQualityCharacteristic": "Int?",
        "OzoneDensityCharacteristic": "Double?",
        "NitrogenDioxideDensityCharacteristic": "Double?",
        "SulphurDioxideDensityCharacteristic": "Double?",
        "PM2_5DensityCharacteristic": "Double?",
        "PM10DensityCharacteristic": "Double?",
        "VolatileOrganicCompoundDensityCharacteristic": "Double?",
        "AirParticulateDensityCharacteristic": "Double?",
        "AirParticulateSizeCharacteristic": "Double?",
        "CarbonMonoxideLevelCharacteristic": "Double?",
        "CarbonDioxideLevelCharacteristic": "Double?",
        "OutletInUseCharacteristic": "Int?",
        "CurrentLockMechanismStateCharacteristic": "Int?",
        "TargetLockMechanismStateCharacteristic": "Int?",
        "CurrentDoorStateCharacteristic": "Int?",
        "TargetDoorStateCharacteristic": "Int?",
        "ObstructionDetectedCharacteristic": "Bool?",
        "CurrentFanStateCharacteristic": "Int?",
        "TargetFanStateCharacteristic": "Int?",
        "RotationDirectionCharacteristic": "Int?",
        "RotationSpeedCharacteristic": "Double?",
        "SwingModeCharacteristic": "Int?",
        "LockPhysicalControlsCharacteristic": "Int?",
        "CurrentPositionCharacteristic": "Int?",
        "TargetPositionCharacteristic": "Int?",
        "PositionStateCharacteristic": "Int?",
        "HoldPositionCharacteristic": "Int?",
        "CurrentHorizontalTiltCharacteristic": "Int?",
        "TargetHorizontalTiltCharacteristic": "Int?",
        "CurrentVerticalTiltCharacteristic": "Int?",
        "TargetVerticalTiltCharacteristic": "Int?",
        "StatusActiveCharacteristic": "Int?",
        "StatusFaultCharacteristic": "Int?",
        "StatusTamperedCharacteristic": "Int?"
    ]
    return mapping[bare] ?? "Any?"
}

/// Macro expansion errors
enum MacroError: Error, CustomStringConvertible {
    case notAClass
    case invalidSyntax

    var description: String {
        switch self {
        case .notAClass:
            return "@Snapshotable can only be applied to class declarations"
        case .invalidSyntax:
            return "Failed to generate valid snapshot syntax"
        }
    }
}
