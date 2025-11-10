import XCTest
@testable import SwiftHomeKit

final class SwiftHomeKitTests: XCTestCase {
    func testLibraryVersion() {
        XCTAssertEqual(SwiftHomeKit.version, "0.1.0")
    }
}
