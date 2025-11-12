import Foundation

/// Identifies the type of HomeKit operation being executed when diagnostics are recorded.
public enum HomeKitOperation: String, Sendable {
    case characteristicRead = "characteristic.read"
    case characteristicWrite = "characteristic.write"
    case characteristicNotification = "characteristic.notification"
    case accessoryIdentify = "accessory.identify"
    case accessoryUpdateName = "accessory.updateName"
    case cacheWarmUp = "cache.warm_up"
    case cacheReset = "cache.reset"
    case homeUpdate = "home.update"
    case roomUpdate = "room.update"
    case zoneUpdate = "zone.update"
}

/// Metadata describing the accessory involved in an operation.
public struct AccessoryContext: Sendable {
    public let accessoryIdentifier: UUID?
    public let accessoryName: String?
    public let roomName: String?
    public let category: String?

    public init(accessoryIdentifier: UUID?, accessoryName: String?, roomName: String?, category: String?) {
        self.accessoryIdentifier = accessoryIdentifier
        self.accessoryName = accessoryName
        self.roomName = roomName
        self.category = category
    }
}

/// Metadata describing the characteristic involved in an operation.
public struct CharacteristicContext: Sendable {
    public let accessoryIdentifier: UUID?
    public let accessoryName: String?
    public let serviceIdentifier: UUID?
    public let serviceType: String?
    public let serviceName: String?
    public let characteristicIdentifier: UUID?
    public let characteristicType: String
    public let characteristicName: String?

    public init(
        accessoryIdentifier: UUID?,
        accessoryName: String?,
        serviceIdentifier: UUID?,
        serviceType: String?,
        serviceName: String?,
        characteristicIdentifier: UUID?,
        characteristicType: String,
        characteristicName: String?
    ) {
        self.accessoryIdentifier = accessoryIdentifier
        self.accessoryName = accessoryName
        self.serviceIdentifier = serviceIdentifier
        self.serviceType = serviceType
        self.serviceName = serviceName
        self.characteristicIdentifier = characteristicIdentifier
        self.characteristicType = characteristicType
        self.characteristicName = characteristicName
    }
}

/// Encapsulates HomeKit failures with accessory/service/characteristic context for deterministic diagnostics.
public enum HomeKitError: Error {
    case characteristicValueUnavailable(context: CharacteristicContext)
    case characteristicTypeMismatch(expected: String, actual: String, context: CharacteristicContext)
    case characteristicTransport(operation: HomeKitOperation, context: CharacteristicContext, underlying: Error)
    case accessoryOperationFailed(operation: HomeKitOperation, context: AccessoryContext, underlying: Error)
    case homeManagement(operation: HomeKitOperation, underlying: Error)
    case roomForHomeCannotBeInZone
    case platformUnavailable(reason: String)
}

extension HomeKitError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .characteristicValueUnavailable(let context):
            return "Characteristic value unavailable: \(context.characteristicType)"
        case .characteristicTypeMismatch(let expected, let actual, let context):
            return "Characteristic type mismatch for \(context.characteristicType). Expected \(expected) but found \(actual)."
        case .characteristicTransport(let operation, let context, let underlying):
            return "HomeKit transport failure during \(operation.rawValue) for \(context.characteristicType): \(underlying.localizedDescription)"
        case .accessoryOperationFailed(let operation, let context, let underlying):
            if let name = context.accessoryName {
                return "Accessory operation \(operation.rawValue) failed for \(name): \(underlying.localizedDescription)"
            } else {
                return "Accessory operation \(operation.rawValue) failed: \(underlying.localizedDescription)"
            }
        case .homeManagement(let operation, let underlying):
            return "Home management operation \(operation.rawValue) failed: \(underlying.localizedDescription)"
        case .roomForHomeCannotBeInZone:
            return "The room for entire home cannot be added to a zone"
        case .platformUnavailable(let reason):
            return reason
        }
    }
}

public extension HomeKitError {
    var accessoryContext: AccessoryContext? {
        switch self {
        case .accessoryOperationFailed(_, let context, _):
            return context
        case .characteristicValueUnavailable(let context),
             .characteristicTypeMismatch(_, _, let context),
             .characteristicTransport(_, let context, _):
            return AccessoryContext(
                accessoryIdentifier: context.accessoryIdentifier,
                accessoryName: context.accessoryName,
                roomName: nil,
                category: nil
            )
        case .homeManagement, .roomForHomeCannotBeInZone, .platformUnavailable:
            return nil
        }
    }

    var characteristicContext: CharacteristicContext? {
        switch self {
        case .characteristicValueUnavailable(let context),
             .characteristicTypeMismatch(_, _, let context),
             .characteristicTransport(_, let context, _):
            return context
        default:
            return nil
        }
    }

    var underlyingError: Error? {
        switch self {
        case .characteristicTransport(_, _, let error),
             .accessoryOperationFailed(_, _, let error),
             .homeManagement(_, let error):
            return error
        default:
            return nil
        }
    }
}

internal extension HomeKitError {
    var diagnosticsMetadata: [String: String] {
        var data: [String: String] = [:]

        if let accessoryContext {
            if let identifier = accessoryContext.accessoryIdentifier {
                data["accessory.id"] = identifier.uuidString
            }
            if let name = accessoryContext.accessoryName {
                data["accessory.name"] = name
            }
            if let room = accessoryContext.roomName {
                data["accessory.room"] = room
            }
            if let category = accessoryContext.category {
                data["accessory.category"] = category
            }
        }

        if let characteristicContext {
            if let serviceType = characteristicContext.serviceType {
                data["service.type"] = serviceType
            }
            if let serviceName = characteristicContext.serviceName {
                data["service.name"] = serviceName
            }
            if let characteristicName = characteristicContext.characteristicName {
                data["characteristic.name"] = characteristicName
            }
            data["characteristic.type"] = characteristicContext.characteristicType
        }

        if let error = underlyingError {
            data["underlying"] = String(describing: error)
        }

        return data
    }
}

#if canImport(HomeKit)
import HomeKit

internal extension CharacteristicContext {
    init(characteristic: HMCharacteristic) {
        let service = characteristic.service
        let accessory = service?.accessory

        self.init(
            accessoryIdentifier: accessory?.uniqueIdentifier,
            accessoryName: accessory?.name,
            serviceIdentifier: service?.uniqueIdentifier,
            serviceType: service?.serviceType,
            serviceName: service?.name,
            characteristicIdentifier: characteristic.uniqueIdentifier,
            characteristicType: characteristic.characteristicType,
            characteristicName: characteristic.localizedDescription
        )
    }
}

internal extension AccessoryContext {
    init(accessory: HMAccessory) {
        self.init(
            accessoryIdentifier: accessory.uniqueIdentifier,
            accessoryName: accessory.name,
            roomName: accessory.room?.name,
            category: accessory.category.categoryType
        )
    }
}
#endif

/// Lightweight context payload used by the diagnostics system to emit structured events.
public struct DiagnosticsContext: Sendable {
    public let accessoryName: String?
    public let serviceType: String?
    public let characteristicType: String?

    public init(accessoryName: String? = nil, serviceType: String? = nil, characteristicType: String? = nil) {
        self.accessoryName = accessoryName
        self.serviceType = serviceType
        self.characteristicType = characteristicType
    }
}

internal extension DiagnosticsContext {
    init(_ context: AccessoryContext) {
        self.init(accessoryName: context.accessoryName, serviceType: nil, characteristicType: nil)
    }

    init(_ context: CharacteristicContext) {
        self.init(
            accessoryName: context.accessoryName,
            serviceType: context.serviceType,
            characteristicType: context.characteristicType
        )
    }
}

extension HomeKitError: @unchecked Sendable {}
