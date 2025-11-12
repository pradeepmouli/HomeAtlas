// HomeAtlas Macro Declarations
// Public interface for @Snapshotable and related macros

/// Generates a type-safe snapshot struct for HomeAtlas classes.
///
/// Apply this macro to Home, Room, Zone, Accessory, Service, or Characteristic classes
/// to automatically generate a corresponding Codable snapshot struct that preserves type information.
///
/// ## Example
///
/// ```swift
/// @Snapshotable
/// public final class LightbulbService: Service {
///     public var powerState: PowerStateCharacteristic? { ... }
///     public var brightness: BrightnessCharacteristic? { ... }
/// }
/// ```
///
/// The macro generates:
///
/// ```swift
/// public struct LightbulbServiceSnapshot: Codable, Sendable {
///     public let id: String
///     public let serviceType: String
///     public let powerState: Bool?
///     public let brightness: Int?
///
///     public init(from service: LightbulbService) async throws {
///         // ... conversion logic
///     }
/// }
/// ```
///
/// ## Type Mapping
///
/// The macro automatically maps HomeKit types to snapshot types:
/// - `PowerStateCharacteristic?` → `Bool?`
/// - `BrightnessCharacteristic?` → `Int?`
/// - `[Room]` → `[RoomSnapshot]`
/// - Other properties retain their types
///
/// ## Generated Features
///
/// - **Codable conformance**: Automatically serializable to/from JSON
/// - **Sendable conformance**: Safe for concurrent access
/// - **Async initializer**: Handles async characteristic value reads
/// - **Type safety**: Compile-time validation of snapshot structure
///
@attached(peer, names: suffixed(AtlasSnapshot))
public macro Snapshotable() = #externalMacro(module: "HomeAtlasMacros", type: "SnapshotableMacro")
