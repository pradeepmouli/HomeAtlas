import Foundation

/// A protocol for HomeKit objects that have localized descriptions and unique identifiers.
///
/// This protocol provides a unified interface for accessing common properties
/// across HomeKit wrapper types like Service, Characteristic, and Accessory.
@MainActor
public protocol HomeKitDescribable {
    /// A localized description of the object type.
    ///
    /// For services and characteristics, this is the human-readable type name
    /// (e.g., "Lightbulb" for a lightbulb service, "Power State" for a power characteristic).
    /// For accessories, this is the category's localized description.
    var localizedDescription: String { get }

    /// The unique instance identifier for this object.
    var uniqueIdentifier: UUID { get }
}
