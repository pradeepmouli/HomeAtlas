// AUTO-GENERATED DIRECTORY: Sources/HomeAtlas/Encoding/
// Part of HomeAtlas rebrand and JSON serialization feature (003)

import Foundation

/// Snapshot representation of a Home for JSON serialization
public struct HomeSnapshot: Codable, Sendable {
    public let id: String
    public let name: String
    public let rooms: [RoomSnapshot]
    public let zones: [ZoneSnapshot]
    public let metadata: Metadata?

    public struct Metadata: Codable, Sendable {
        public let createdAt: String?
        public let updatedAt: String?
    }
}

/// Snapshot representation of a Zone
public struct ZoneSnapshot: Codable, Sendable {
    public let id: String
    public let name: String
    public let roomIds: [String]
}

/// Snapshot representation of a Room
public struct RoomSnapshot: Codable, Sendable {
    public let id: String
    public let name: String
    public let accessories: [AccessorySnapshot]
}

/// Snapshot representation of an Accessory
public struct AccessorySnapshot: Codable, Sendable {
    public let id: String
    public let name: String
    public let manufacturer: String?
    public let model: String?
    public let firmwareVersion: String?
    public let services: [ServiceSnapshot]
}

/// Snapshot representation of a Service
public struct ServiceSnapshot: Codable, Sendable {
    public let id: String
    public let name: String?
    public let serviceType: String
    public let characteristics: [CharacteristicSnapshot]
}

/// Snapshot representation of a Characteristic
public struct CharacteristicSnapshot: Codable, Sendable {
    public let id: String
    public let characteristicType: String
    public let displayName: String?
    public let unit: String?
    public let min: Double?
    public let max: Double?
    public let step: Double?
    public let readable: Bool
    public let writable: Bool
    public let value: AnyCodable?
    public let reason: String?

    /// Wrapper to allow encoding Any values as Codable
    public struct AnyCodable: Codable, @unchecked Sendable {
        public let value: Any

        public init(_ value: Any) {
            self.value = value
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if container.decodeNil() {
                self.value = NSNull()
            } else if let bool = try? container.decode(Bool.self) {
                self.value = bool
            } else if let int = try? container.decode(Int.self) {
                self.value = int
            } else if let double = try? container.decode(Double.self) {
                self.value = double
            } else if let string = try? container.decode(String.self) {
                self.value = string
            } else if let array = try? container.decode([AnyCodable].self) {
                self.value = array.map { $0.value }
            } else if let dictionary = try? container.decode([String: AnyCodable].self) {
                self.value = dictionary.mapValues { $0.value }
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unsupported type"
                )
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch value {
            case is NSNull:
                try container.encodeNil()
            case let bool as Bool:
                try container.encode(bool)
            case let int as Int:
                try container.encode(int)
            case let double as Double:
                try container.encode(double)
            case let string as String:
                try container.encode(string)
            case let array as [Any]:
                try container.encode(array.map { AnyCodable($0) })
            case let dictionary as [String: Any]:
                try container.encode(dictionary.mapValues { AnyCodable($0) })
            default:
                let context = EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unsupported type: \(type(of: value))"
                )
                throw EncodingError.invalidValue(value, context)
            }
        }
    }
}
