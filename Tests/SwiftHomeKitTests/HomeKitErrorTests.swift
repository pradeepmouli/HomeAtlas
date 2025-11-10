import XCTest
@testable import SwiftHomeKit

private enum SampleError: Error, CustomStringConvertible {
    case transport

    var description: String {
        "sample-transport"
    }
}

final class HomeKitErrorTests: XCTestCase {
    func testCharacteristicTransportCarriesMetadata() {
        let accessoryID = UUID(uuidString: "12345678-1234-1234-1234-1234567890ab")
        let serviceID = UUID(uuidString: "87654321-4321-4321-4321-ba0987654321")

        let context = CharacteristicContext(
            accessoryIdentifier: accessoryID,
            accessoryName: "Lamp",
            serviceIdentifier: serviceID,
            serviceType: "Lightbulb",
            serviceName: "Primary Light",
            characteristicIdentifier: UUID(uuidString: "00112233-4455-6677-8899-aabbccddeeff"),
            characteristicType: "PowerState",
            characteristicName: "Power"
        )

        let error = HomeKitError.characteristicTransport(
            operation: .characteristicWrite,
            context: context,
            underlying: SampleError.transport
        )

        XCTAssertEqual(error.characteristicContext?.serviceType, "Lightbulb")
        XCTAssertEqual(error.diagnosticsMetadata["characteristic.type"], "PowerState")
        XCTAssertEqual(error.diagnosticsMetadata["underlying"], "sample-transport")
        XCTAssertEqual(error.accessoryContext?.accessoryName, "Lamp")
    }

    @MainActor
    func testDiagnosticsLoggerNotifiesObservers() {
        let logger = DiagnosticsLogger.shared
        let previousThreshold = logger.latencyWarningThreshold
        logger.latencyWarningThreshold = 0 // Ensure we log even fast events
        defer { logger.latencyWarningThreshold = previousThreshold }

        let expectation = expectation(description: "Observer receives diagnostics")

        let token = logger.addObserver { event in
            guard event.operation == .characteristicWrite else { return }
            XCTAssertEqual(event.context.accessoryName, "Desk Lamp")
            XCTAssertEqual(event.context.serviceType, "Lightbulb")
            XCTAssertEqual(event.context.characteristicType, "PowerState")
            XCTAssertEqual(event.outcome, .failure)
            XCTAssertEqual(event.metadata["characteristic.type"], "PowerState")
            expectation.fulfill()
        }
        defer { logger.removeObserver(token) }

        logger.record(
            operation: .characteristicWrite,
            context: DiagnosticsContext(accessoryName: "Desk Lamp", serviceType: "Lightbulb", characteristicType: "PowerState"),
            duration: 0.01,
            outcome: .failure,
            metadata: ["characteristic.type": "PowerState"]
        )

        waitForExpectations(timeout: 1.0)
    }
}
