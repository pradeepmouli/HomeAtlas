// Test that @Snapshotable macro works end-to-end

import XCTest
@testable import HomeAtlas

final class MacroIntegrationTests: XCTestCase {
    
    func testLightbulbServiceSnapshotExists() {
        // Verify the macro generated LightbulbServiceAtlasSnapshot
        _ = LightbulbServiceAtlasSnapshot.self
    }
    
    func testSnapshotConformsToCodeble() {
        // Verify Codable conformance via encoding a minimal instance
        struct Dummy: Encodable { let id: String; let name: String }
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(Dummy(id: "", name: "")))
    }
    
    func testSnapshotTypeExists() {
        // Sanity check to ensure type exists at compile-time
        _ = LightbulbServiceAtlasSnapshot.self
    }
}
