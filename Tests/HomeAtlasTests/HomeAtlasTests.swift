import XCTest
@testable import HomeAtlas

final class HomeAtlasTests: XCTestCase {
    func testVersion() {
        XCTAssertEqual(HomeAtlas.version, "0.1.0")
    }
}
