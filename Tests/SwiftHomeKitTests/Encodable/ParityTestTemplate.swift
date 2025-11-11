import XCTest
@testable import SwiftHomeKit

/// Parity test template that verifies encode/decode round-trip equality for Encodable wrappers.
/// Each concrete wrapper test should:
/// 1. Construct a wrapper instance with deterministic values.
/// 2. Encode using JSONEncoder.
/// 3. Decode using JSONDecoder.
/// 4. Assert field-by-field equality.
/// 5. Avoid using `Any` in encoded representations.
///
/// Extend this template by copying and customizing `WrapperParityTests` for each wrapper.
final class WrapperParityTests: XCTestCase {
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.sortedKeys]
        return e
    }()

    private let decoder = JSONDecoder()

    func test_exampleWrapper_roundTripParity() throws {
        // TODO: Replace ExampleWrapper with a real wrapper type when available.
        // let original = ExampleWrapper(id: "abc", name: "Kitchen", value: 42)
        // let data = try encoder.encode(original)
        // let decoded = try decoder.decode(ExampleWrapper.self, from: data)
        // XCTAssertEqual(original.id, decoded.id)
        // XCTAssertEqual(original.name, decoded.name)
        // XCTAssertEqual(original.value, decoded.value)
    }
}
