// Macro tests for @Snapshotable
// Validates macro expansion and generated code

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(HomeAtlasMacros)
import HomeAtlasMacros

final class SnapshotableMacroTests: XCTestCase {

    let testMacros: [String: Macro.Type] = [
        "Snapshotable": SnapshotableMacro.self
    ]

    func testServiceClassExpansion() throws {
        assertMacroExpansion(
            """
            @Snapshotable
            public final class LightbulbService: Service {
                public var powerState: PowerStateCharacteristic? { get { nil } }
                public var brightness: BrightnessCharacteristic? { get { nil } }
            }
            """,
            expandedSource: """
            public final class LightbulbService: Service {
                public var powerState: PowerStateCharacteristic? { get { nil } }
                public var brightness: BrightnessCharacteristic? { get { nil } }
            }

            public struct LightbulbServiceAtlasSnapshot: Codable, Sendable {
                public let serviceType: String
                public let name: String?
                public let powerState: Bool?
                public let brightness: Int?

                @MainActor
                public init(from original: LightbulbService, anonymize: (String) -> String = {
                        $0
                    }) async throws {
                    self.serviceType = original.serviceType
                    self.name = original.name.map(anonymize)
                    self.powerState = try? await original.powerState?.read()
                    self.brightness = try? await original.brightness?.read()
                }
            }
            """,
            macros: testMacros
        )
    }

    func testBaseServiceExpansion() throws {
        assertMacroExpansion(
            """
            @Snapshotable
            public class Service {}
            """,
            expandedSource: """
            public class Service {}

            public struct ServiceAtlasSnapshot: Codable, Sendable {
                public let id: String
                public let name: String?
                public let serviceType: String
                public let characteristics: [CharacteristicSnapshot]

                @MainActor
                public init(from original: Service, anonymize: (String) -> String = {
                        $0
                    }) async throws {
                    self.id = anonymize(original.uniqueIdentifier.uuidString)
                    self.name = original.name.map(anonymize)
                    self.serviceType = original.serviceType
                    self.characteristics = original.allCharacteristics().map { c in
                        let id = anonymize(c.underlying.uniqueIdentifier.uuidString)
                        let characteristicType = c.underlying.characteristicType
                        let displayName = c.underlying.localizedDescription
                        let unit = c.underlying.metadata?.units?.description
                        let min = c.underlying.metadata?.minimumValue as? Double
                        let max = c.underlying.metadata?.maximumValue as? Double
                        let step = c.underlying.metadata?.stepValue as? Double
                        let readable = c.underlying.properties.contains(.readable)
                        let writable = c.underlying.properties.contains(.writable)
                        var value: CharacteristicSnapshot.AnyCodable? = nil
                        var reason: String? = nil
                        if readable {
                            if let v = c.underlying.value {
                                value = CharacteristicSnapshot.AnyCodable(v)
                            } else {
                                reason = "unavailable"
                            }
                        } else {
                            reason = "not-readable"
                        }
                        return CharacteristicSnapshot(
                            id: id,
                            characteristicType: characteristicType,
                            displayName: displayName,
                            unit: unit,
                            min: min,
                            max: max,
                            step: step,
                            readable: readable,
                            writable: writable,
                            value: value,
                            reason: reason
                        )
                    } .sorted(by: {
                            $0.displayName < $1.displayName
                        })
                }
            }
            """,
            macros: testMacros
        )
    }

    func testAccessoryExpansion() throws {
        assertMacroExpansion(
            """
            @Snapshotable
            public class Accessory {}
            """,
            expandedSource: """
            public class Accessory {}

            public struct AccessoryAtlasSnapshot: Codable, Sendable {
                public let id: String
                public let name: String
                public let services: [ServiceAtlasSnapshot]

                @MainActor
                public init(from original: Accessory, anonymize: (String) -> String = {
                        $0
                    }) async throws {
                    self.id = anonymize(original.uniqueIdentifier.uuidString)
                    self.name = anonymize(original.name)
                    self.services = try await original.allServices().map {
                        try await ServiceAtlasSnapshot(from: $0, anonymize: anonymize)
                    } .sorted(by: {
                            ($0.name ?? "") < ($1.name ?? "")
                        })
                }
            }
            """,
            macros: testMacros
        )
    }

    func testHomeExpansion() throws {
        assertMacroExpansion(
            """
            @Snapshotable
            public class Home {}
            """,
            expandedSource: """
            public class Home {}

            public struct HomeAtlasSnapshot: Codable, Sendable {
                public let id: String
                public let name: String
                public let rooms: [RoomAtlasSnapshot]
                public let zones: [ZoneAtlasSnapshot]

                @MainActor
                public init(from original: Home, anonymize: (String) -> String = {
                        $0
                    }) async throws {
                    self.id = anonymize(original.uniqueIdentifier.uuidString)
                    self.name = anonymize(original.name)
                    self.rooms = try await original.rooms.map {
                        try await RoomAtlasSnapshot(from: Room($0), anonymize: anonymize)
                    } .sorted(by: {
                            $0.name < $1.name
                        })
                    self.zones = try await original.zones.map {
                        try await ZoneAtlasSnapshot(from: Zone($0), anonymize: anonymize)
                    } .sorted(by: {
                            $0.name < $1.name
                        })
                }
            }
            """,
            macros: testMacros
        )
    }

    func testRoomExpansion() throws {
        assertMacroExpansion(
            """
            @Snapshotable
            public class Room {}
            """,
            expandedSource: """
            public class Room {}

            public struct RoomAtlasSnapshot: Codable, Sendable {
                public let id: String
                public let name: String
                public let accessories: [AccessoryAtlasSnapshot]

                @MainActor
                public init(from original: Room, anonymize: (String) -> String = {
                        $0
                    }) async throws {
                    self.id = anonymize(original.uniqueIdentifier.uuidString)
                    self.name = anonymize(original.name)
                    self.accessories = try await original.accessories.map {
                        try await AccessoryAtlasSnapshot(from: Accessory($0), anonymize: anonymize)
                    } .sorted(by: {
                            $0.name < $1.name
                        })
                }
            }
            """,
            macros: testMacros
        )
    }

    func testZoneExpansion() throws {
        assertMacroExpansion(
            """
            @Snapshotable
            public class Zone {}
            """,
            expandedSource: """
            public class Zone {}

            public struct ZoneAtlasSnapshot: Codable, Sendable {
                public let id: String
                public let name: String
                public let roomIds: [String]

                @MainActor
                public init(from original: Zone, anonymize: (String) -> String = {
                        $0
                    }) async throws {
                    self.id = anonymize(original.uniqueIdentifier.uuidString)
                    self.name = anonymize(original.name)
                    self.roomIds = original.rooms.map {
                        anonymize($0.uniqueIdentifier.uuidString)
                    } .sorted()
                }
            }
            """,
            macros: testMacros
        )
    }
}
#endif
