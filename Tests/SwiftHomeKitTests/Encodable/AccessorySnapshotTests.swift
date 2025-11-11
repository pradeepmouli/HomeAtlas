import XCTest
@testable import SwiftHomeKit

/// Tests demonstrating the recommended DTO (Data Transfer Object) pattern for serialization.
/// Since wrapper classes store non-Encodable HomeKit types, this shows how to create
/// Encodable snapshots for diagnostics/logging use cases.
final class AccessorySnapshotTests: XCTestCase {

    /// Example DTO for serializing Accessory state
    struct AccessorySnapshot: Codable, Equatable {
        let name: String
        let uniqueIdentifier: UUID
        let isReachable: Bool
        let isBlocked: Bool
        let categoryType: String

        /// Extract encodable properties from Accessory wrapper
        init(name: String, id: UUID, reachable: Bool, blocked: Bool, category: String) {
            self.name = name
            self.uniqueIdentifier = id
            self.isReachable = reachable
            self.isBlocked = blocked
            self.categoryType = category
        }
    }

    func test_accessorySnapshot_encodesAndDecodes() throws {
        // Arrange: Create a snapshot with known values
        let original = AccessorySnapshot(
            name: "Living Room Light",
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!,
            reachable: true,
            blocked: false,
            category: "Lightbulb"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        // Act: Encode to JSON
        let data = try encoder.encode(original)

        // Assert: JSON contains expected fields
        let json = String(data: data, encoding: .utf8)!
        XCTAssertTrue(json.contains("\"name\" : \"Living Room Light\""))
        XCTAssertTrue(json.contains("\"isReachable\" : true"))
        XCTAssertTrue(json.contains("\"categoryType\" : \"Lightbulb\""))

        // Act: Decode back
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AccessorySnapshot.self, from: data)

        // Assert: Round-trip preserves all values
        XCTAssertEqual(original, decoded)
        XCTAssertEqual(decoded.name, "Living Room Light")
        XCTAssertEqual(decoded.isReachable, true)
        XCTAssertEqual(decoded.categoryType, "Lightbulb")
    }

    func test_accessorySnapshot_multipleItemsEncode() throws {
        // Arrange: Create array of snapshots
        let snapshots = [
            AccessorySnapshot(name: "Light 1", id: UUID(), reachable: true, blocked: false, category: "Lightbulb"),
            AccessorySnapshot(name: "Thermostat", id: UUID(), reachable: true, blocked: false, category: "Thermostat"),
            AccessorySnapshot(name: "Lock", id: UUID(), reachable: false, blocked: false, category: "DoorLock")
        ]

        // Act: Encode array
        let encoder = JSONEncoder()
        let data = try encoder.encode(snapshots)

        // Decode and verify
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([AccessorySnapshot].self, from: data)

        // Assert: All items preserved
        XCTAssertEqual(decoded.count, 3)
        XCTAssertEqual(decoded[0].name, "Light 1")
        XCTAssertEqual(decoded[1].categoryType, "Thermostat")
        XCTAssertEqual(decoded[2].isReachable, false)
    }

    func test_accessorySnapshot_noAnyTypes() {
        // This test validates Constitution Principle I: no Any leakage
        // The AccessorySnapshot type is value-based with explicit types:
        // String, UUID, Bool - no Any anywhere in the serialization path

        let snapshot = AccessorySnapshot(
            name: "Test",
            id: UUID(),
            reachable: true,
            blocked: false,
            category: "Outlet"
        )

        // Verify all properties are typed (compiler enforces this, test documents intent)
        XCTAssertTrue(type(of: snapshot.name) == String.self)
        XCTAssertTrue(type(of: snapshot.uniqueIdentifier) == UUID.self)
        XCTAssertTrue(type(of: snapshot.isReachable) == Bool.self)
        XCTAssertTrue(type(of: snapshot.categoryType) == String.self)
    }
}
