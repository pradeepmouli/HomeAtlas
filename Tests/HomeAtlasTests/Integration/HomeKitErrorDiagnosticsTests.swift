import XCTest
@testable import HomeAtlas
import Foundation

/// Validates that every HomeKitError case produces complete diagnostics metadata.
///
/// This test suite ensures diagnostic observability for all error scenarios, validating
/// that each error type includes appropriate context fields for debugging and monitoring.
///
/// - Reference: T031 - Diagnostics metadata coverage
@MainActor
final class HomeKitErrorDiagnosticsTests: XCTestCase {

    // MARK: - Characteristic Errors

    func testCharacteristicValueUnavailableMetadata() {
        let context = CharacteristicContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Test Light",
            serviceIdentifier: UUID(),
            serviceType: "00000043-0000-1000-8000-0026BB765291",
            serviceName: "Lightbulb Service",
            characteristicIdentifier: UUID(),
            characteristicType: "00000025-0000-1000-8000-0026BB765291",
            characteristicName: "On"
        )

        let error = HomeKitError.characteristicValueUnavailable(context: context)
        let metadata = error.diagnosticsMetadata

        XCTAssertNotNil(metadata["accessory.name"], "Should include accessory name")
        XCTAssertEqual(metadata["accessory.name"], "Test Light")
        XCTAssertNotNil(metadata["service.type"], "Should include service type")
        XCTAssertNotNil(metadata["characteristic.type"], "Should include characteristic type")
        XCTAssertEqual(metadata["characteristic.type"], "00000025-0000-1000-8000-0026BB765291")
        XCTAssertNotNil(metadata["characteristic.name"], "Should include characteristic name")
    }

    func testCharacteristicTypeMismatchMetadata() {
        let context = CharacteristicContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Thermostat",
            serviceIdentifier: UUID(),
            serviceType: "0000004A-0000-1000-8000-0026BB765291",
            serviceName: "Thermostat Service",
            characteristicIdentifier: UUID(),
            characteristicType: "00000011-0000-1000-8000-0026BB765291",
            characteristicName: "Current Temperature"
        )

        let error = HomeKitError.characteristicTypeMismatch(
            expected: "Float",
            actual: "String",
            context: context
        )
        let metadata = error.diagnosticsMetadata

        XCTAssertNotNil(metadata["accessory.name"])
        XCTAssertEqual(metadata["accessory.name"], "Thermostat")
        XCTAssertNotNil(metadata["service.type"])
        XCTAssertNotNil(metadata["characteristic.type"])
        XCTAssertNotNil(metadata["characteristic.name"])

        // Verify error description includes expected/actual types
        let description = error.errorDescription ?? ""
        XCTAssertTrue(description.contains("Float"))
        XCTAssertTrue(description.contains("String"))
    }

    func testCharacteristicTransportMetadata() {
        let context = CharacteristicContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Smart Lock",
            serviceIdentifier: UUID(),
            serviceType: "00000045-0000-1000-8000-0026BB765291",
            serviceName: "Lock Service",
            characteristicIdentifier: UUID(),
            characteristicType: "0000001D-0000-1000-8000-0026BB765291",
            characteristicName: "Lock Target State"
        )

        let underlyingError = NSError(domain: "HMErrorDomain", code: 54, userInfo: nil)
        let error = HomeKitError.characteristicTransport(
            operation: .characteristicWrite,
            context: context,
            underlying: underlyingError
        )
        let metadata = error.diagnosticsMetadata

        XCTAssertNotNil(metadata["accessory.name"])
        XCTAssertEqual(metadata["accessory.name"], "Smart Lock")
        XCTAssertNotNil(metadata["service.type"])
        XCTAssertNotNil(metadata["characteristic.type"])
        XCTAssertNotNil(metadata["underlying"], "Should include underlying error")

        // Verify underlying error is preserved
        XCTAssertEqual(error.underlyingError as? NSError, underlyingError)
    }

    // MARK: - Accessory Errors

    func testAccessoryOperationFailedMetadata() {
        let context = AccessoryContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Front Door Camera",
            roomName: "Entryway",
            category: "17" // Camera category
        )

        let underlyingError = NSError(domain: "HMErrorDomain", code: 2, userInfo: nil)
        let error = HomeKitError.accessoryOperationFailed(
            operation: .accessoryIdentify,
            context: context,
            underlying: underlyingError
        )
        let metadata = error.diagnosticsMetadata

        XCTAssertNotNil(metadata["accessory.name"])
        XCTAssertEqual(metadata["accessory.name"], "Front Door Camera")
        XCTAssertNotNil(metadata["accessory.room"])
        XCTAssertEqual(metadata["accessory.room"], "Entryway")
        XCTAssertNotNil(metadata["accessory.category"])
        XCTAssertNotNil(metadata["underlying"])
    }

    func testAccessoryOperationFailedWithMinimalContext() {
        // Test with minimal context (e.g., newly discovered accessory)
        let context = AccessoryContext(
            accessoryIdentifier: UUID(),
            accessoryName: nil,
            roomName: nil,
            category: nil
        )

        let underlyingError = NSError(domain: "HMErrorDomain", code: 15, userInfo: nil)
        let error = HomeKitError.accessoryOperationFailed(
            operation: .accessoryUpdateName,
            context: context,
            underlying: underlyingError
        )
        let metadata = error.diagnosticsMetadata

        // Should still have accessory ID even if name is missing
        XCTAssertNotNil(metadata["accessory.id"])
        XCTAssertNotNil(metadata["underlying"])

        // Should gracefully handle missing optional fields
        XCTAssertNil(metadata["accessory.name"])
        XCTAssertNil(metadata["accessory.room"])
    }

    // MARK: - Home Management Errors

    func testHomeManagementMetadata() {
        let underlyingError = NSError(domain: "HMErrorDomain", code: 3, userInfo: nil)
        let error = HomeKitError.homeManagement(
            operation: .homeUpdate,
            underlying: underlyingError
        )
        let metadata = error.diagnosticsMetadata

        // Home management errors don't include accessory/characteristic context
        XCTAssertNil(metadata["accessory.name"])
        XCTAssertNil(metadata["service.type"])
        XCTAssertNil(metadata["characteristic.type"])

        // But should include underlying error
        XCTAssertNotNil(metadata["underlying"])
        XCTAssertEqual(error.underlyingError as? NSError, underlyingError)
    }

    // MARK: - Structural Errors

    func testRoomForHomeCannotBeInZoneMetadata() {
        let error = HomeKitError.roomForHomeCannotBeInZone
        let metadata = error.diagnosticsMetadata

        // Structural errors have no context
        XCTAssertTrue(metadata.isEmpty, "Structural error should have empty metadata")
        XCTAssertNil(error.accessoryContext)
        XCTAssertNil(error.characteristicContext)
        XCTAssertNil(error.underlyingError)

        // But should have a clear error description
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("room for entire home") ?? false)
    }

    func testPlatformUnavailableMetadata() {
        let error = HomeKitError.platformUnavailable(reason: "HomeKit not available on this platform")
        let metadata = error.diagnosticsMetadata

        // Platform errors have no context
        XCTAssertTrue(metadata.isEmpty, "Platform error should have empty metadata")
        XCTAssertNil(error.accessoryContext)
        XCTAssertNil(error.characteristicContext)

        // Reason should be in error description
        XCTAssertEqual(error.errorDescription, "HomeKit not available on this platform")
    }

    // MARK: - Context Extraction

    func testAccessoryContextExtraction() {
        let accessoryContext = AccessoryContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Test Accessory",
            roomName: "Living Room",
            category: "1"
        )

        let error = HomeKitError.accessoryOperationFailed(
            operation: .accessoryIdentify,
            context: accessoryContext,
            underlying: NSError(domain: "Test", code: 1)
        )

        let extractedContext = error.accessoryContext
        XCTAssertNotNil(extractedContext)
        XCTAssertEqual(extractedContext?.accessoryName, "Test Accessory")
        XCTAssertEqual(extractedContext?.roomName, "Living Room")
        XCTAssertEqual(extractedContext?.category, "1")
    }

    func testCharacteristicContextExtraction() {
        let charContext = CharacteristicContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Test Light",
            serviceIdentifier: UUID(),
            serviceType: "00000043-0000-1000-8000-0026BB765291",
            serviceName: "Lightbulb",
            characteristicIdentifier: UUID(),
            characteristicType: "00000025-0000-1000-8000-0026BB765291",
            characteristicName: "On"
        )

        let error = HomeKitError.characteristicValueUnavailable(context: charContext)

        let extractedContext = error.characteristicContext
        XCTAssertNotNil(extractedContext)
        XCTAssertEqual(extractedContext?.characteristicType, "00000025-0000-1000-8000-0026BB765291")
        XCTAssertEqual(extractedContext?.serviceType, "00000043-0000-1000-8000-0026BB765291")
    }

    // MARK: - DiagnosticsContext Conversion

    func testDiagnosticsContextFromAccessoryContext() {
        let accessoryContext = AccessoryContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Test Accessory",
            roomName: "Kitchen",
            category: "5"
        )

        let diagContext = DiagnosticsContext(accessoryContext)

        XCTAssertEqual(diagContext.accessoryName, "Test Accessory")
        XCTAssertNil(diagContext.serviceType)
        XCTAssertNil(diagContext.characteristicType)
    }

    func testDiagnosticsContextFromCharacteristicContext() {
        let charContext = CharacteristicContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Thermostat",
            serviceIdentifier: UUID(),
            serviceType: "0000004A-0000-1000-8000-0026BB765291",
            serviceName: "Thermostat Service",
            characteristicIdentifier: UUID(),
            characteristicType: "00000011-0000-1000-8000-0026BB765291",
            characteristicName: "Current Temperature"
        )

        let diagContext = DiagnosticsContext(charContext)

        XCTAssertEqual(diagContext.accessoryName, "Thermostat")
        XCTAssertEqual(diagContext.serviceType, "0000004A-0000-1000-8000-0026BB765291")
        XCTAssertEqual(diagContext.characteristicType, "00000011-0000-1000-8000-0026BB765291")
    }

    // MARK: - Comprehensive Coverage

    func testAllErrorCasesHaveDescriptions() {
        // Ensure every error case has a non-nil errorDescription
        let errors: [HomeKitError] = [
            .characteristicValueUnavailable(context: makeCharacteristicContext()),
            .characteristicTypeMismatch(expected: "Int", actual: "String", context: makeCharacteristicContext()),
            .characteristicTransport(operation: .characteristicRead, context: makeCharacteristicContext(), underlying: NSError(domain: "Test", code: 1)),
            .accessoryOperationFailed(operation: .accessoryIdentify, context: makeAccessoryContext(), underlying: NSError(domain: "Test", code: 2)),
            .homeManagement(operation: .homeUpdate, underlying: NSError(domain: "Test", code: 3)),
            .roomForHomeCannotBeInZone,
            .platformUnavailable(reason: "Test reason")
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error \(error) should have errorDescription")
            XCTAssertFalse(error.errorDescription?.isEmpty ?? true, "Error description should not be empty")
        }
    }

    func testAllErrorCasesProduceDiagnosticsMetadata() {
        // Every error should produce a metadata dictionary (may be empty for structural errors)
        let errors: [HomeKitError] = [
            .characteristicValueUnavailable(context: makeCharacteristicContext()),
            .characteristicTypeMismatch(expected: "Int", actual: "String", context: makeCharacteristicContext()),
            .characteristicTransport(operation: .characteristicRead, context: makeCharacteristicContext(), underlying: NSError(domain: "Test", code: 1)),
            .accessoryOperationFailed(operation: .accessoryIdentify, context: makeAccessoryContext(), underlying: NSError(domain: "Test", code: 2)),
            .homeManagement(operation: .homeUpdate, underlying: NSError(domain: "Test", code: 3)),
            .roomForHomeCannotBeInZone,
            .platformUnavailable(reason: "Test reason")
        ]

        for error in errors {
            let metadata = error.diagnosticsMetadata
            // Should always return a dictionary (even if empty)
            XCTAssertNotNil(metadata, "Error \(error) should produce metadata")
        }
    }

    // MARK: - Helpers

    private func makeCharacteristicContext() -> CharacteristicContext {
        CharacteristicContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Test Accessory",
            serviceIdentifier: UUID(),
            serviceType: "00000043-0000-1000-8000-0026BB765291",
            serviceName: "Test Service",
            characteristicIdentifier: UUID(),
            characteristicType: "00000025-0000-1000-8000-0026BB765291",
            characteristicName: "Test Characteristic"
        )
    }

    private func makeAccessoryContext() -> AccessoryContext {
        AccessoryContext(
            accessoryIdentifier: UUID(),
            accessoryName: "Test Accessory",
            roomName: "Test Room",
            category: "1"
        )
    }
}
