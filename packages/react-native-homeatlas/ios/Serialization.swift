//
//  Serialization.swift
//  react-native-homeatlas
//
//  Provides serialization helpers to convert HomeKit types to JavaScript-compatible dictionaries.
//

import Foundation

#if canImport(HomeKit)
import HomeKit

/// Serialization helpers for converting HomeKit entities to JavaScript dictionaries.
@MainActor
enum Serialization {
    
    // MARK: - Home Serialization
    
    /// Serialize an HMHome to a dictionary.
    static func serializeHome(_ home: HMHome) -> [String: Any] {
        return [
            "id": home.uniqueIdentifier.uuidString,
            "name": home.name,
            "isPrimary": home.isPrimary,
            "accessories": home.accessories.map { serializeAccessory($0) },
            "rooms": home.rooms.map { serializeRoom($0) }
        ]
    }
    
    // MARK: - Room Serialization
    
    /// Serialize an HMRoom to a dictionary.
    static func serializeRoom(_ room: HMRoom) -> [String: Any] {
        return [
            "id": room.uniqueIdentifier.uuidString,
            "name": room.name
        ]
    }
    
    // MARK: - Accessory Serialization
    
    /// Serialize an HMAccessory to a dictionary.
    static func serializeAccessory(_ accessory: HMAccessory) -> [String: Any] {
        return [
            "id": accessory.uniqueIdentifier.uuidString,
            "name": accessory.name,
            "isReachable": accessory.isReachable,
            "isBlocked": accessory.isBlocked,
            "category": serializeAccessoryCategory(accessory.category),
            "roomId": accessory.room?.uniqueIdentifier.uuidString as Any,
            "services": accessory.services.map { serializeService($0) }
        ]
    }
    
    /// Serialize an HMAccessoryCategory to a string.
    static func serializeAccessoryCategory(_ category: HMAccessoryCategory) -> String {
        switch category.categoryType {
        case HMAccessoryCategoryTypeBridge:
            return "bridge"
        case HMAccessoryCategoryTypeFan:
            return "fan"
        case HMAccessoryCategoryTypeGarageDoorOpener:
            return "garageDoorOpener"
        case HMAccessoryCategoryTypeLightbulb:
            return "lightbulb"
        case HMAccessoryCategoryTypeDoorLock:
            return "doorLock"
        case HMAccessoryCategoryTypeOutlet:
            return "outlet"
        case HMAccessoryCategoryTypeSwitch:
            return "switch"
        case HMAccessoryCategoryTypeThermostat:
            return "thermostat"
        case HMAccessoryCategoryTypeSensor:
            return "sensor"
        case HMAccessoryCategoryTypeSecuritySystem:
            return "securitySystem"
        case HMAccessoryCategoryTypeDoor:
            return "door"
        case HMAccessoryCategoryTypeWindow:
            return "window"
        case HMAccessoryCategoryTypeWindowCovering:
            return "windowCovering"
        case HMAccessoryCategoryTypeProgrammableSwitch:
            return "programmableSwitch"
        case HMAccessoryCategoryTypeIPCamera:
            return "ipCamera"
        case HMAccessoryCategoryTypeVideoDoorbell:
            return "videoDoorbell"
        case HMAccessoryCategoryTypeAirPurifier:
            return "airPurifier"
        case HMAccessoryCategoryTypeAirHeater:
            return "airHeater"
        case HMAccessoryCategoryTypeAirConditioner:
            return "airConditioner"
        case HMAccessoryCategoryTypeAirHumidifier:
            return "airHumidifier"
        case HMAccessoryCategoryTypeAirDehumidifier:
            return "airDehumidifier"
        case HMAccessoryCategoryTypeSprinkler:
            return "sprinkler"
        case HMAccessoryCategoryTypeFaucet:
            return "faucet"
        case HMAccessoryCategoryTypeShowerHead:
            return "showerHead"
        case HMAccessoryCategoryTypeTelevision:
            return "television"
        case HMAccessoryCategoryTypeRouter:
            return "router"
        default:
            return "other"
        }
    }
    
    // MARK: - Service Serialization
    
    /// Serialize an HMService to a dictionary.
    static func serializeService(_ service: HMService) -> [String: Any] {
        return [
            "id": service.uniqueIdentifier.uuidString,
            "type": service.serviceType,
            "name": service.name,
            "isPrimary": service.isPrimaryService,
            "characteristics": service.characteristics.map { serializeCharacteristic($0) }
        ]
    }
    
    // MARK: - Characteristic Serialization
    
    /// Serialize an HMCharacteristic to a dictionary.
    static func serializeCharacteristic(_ characteristic: HMCharacteristic) -> [String: Any] {
        var dict: [String: Any] = [
            "id": characteristic.uniqueIdentifier.uuidString,
            "type": characteristic.characteristicType,
            "supportsRead": characteristic.properties.contains(HMCharacteristicPropertyReadable),
            "supportsWrite": characteristic.properties.contains(HMCharacteristicPropertyWritable),
            "supportsNotify": characteristic.properties.contains(HMCharacteristicPropertySupportsEventNotification)
        ]
        
        // Add value if readable and available
        if let value = characteristic.value {
            dict["value"] = serializeCharacteristicValue(value)
        } else {
            dict["value"] = NSNull()
        }
        
        // Add metadata for numeric characteristics
        if let metadata = characteristic.metadata {
            dict["minValue"] = metadata.minimumValue as Any
            dict["maxValue"] = metadata.maximumValue as Any
            dict["stepValue"] = metadata.stepValue as Any
        } else {
            dict["minValue"] = NSNull()
            dict["maxValue"] = NSNull()
            dict["stepValue"] = NSNull()
        }
        
        return dict
    }
    
    /// Serialize a characteristic value to a JavaScript-compatible type.
    static func serializeCharacteristicValue(_ value: Any) -> Any {
        switch value {
        case let boolValue as Bool:
            return boolValue
        case let intValue as Int:
            return intValue
        case let floatValue as Float:
            return Double(floatValue)
        case let doubleValue as Double:
            return doubleValue
        case let stringValue as String:
            return stringValue
        case let dataValue as Data:
            // Convert Data to number array
            return [UInt8](dataValue)
        case let arrayValue as [Any]:
            return arrayValue.map { serializeCharacteristicValue($0) }
        default:
            // Fallback: convert to string
            return String(describing: value)
        }
    }
    
    // MARK: - Deserialization
    
    /// Deserialize a JavaScript value to a HomeKit characteristic value.
    static func deserializeCharacteristicValue(_ value: Any, for characteristic: HMCharacteristic) -> Any? {
        // Get the expected format from metadata
        guard let metadata = characteristic.metadata else {
            // No metadata, try to infer from current value
            if let currentValue = characteristic.value {
                return coerceValue(value, toTypeOf: currentValue)
            }
            // Last resort: return as-is
            return value
        }
        
        // Use metadata format to deserialize
        switch metadata.format {
        case HMCharacteristicMetadataFormatBool:
            if let boolValue = value as? Bool {
                return boolValue
            }
            if let intValue = value as? Int {
                return intValue != 0
            }
            return nil
            
        case HMCharacteristicMetadataFormatInt:
            if let intValue = value as? Int {
                return intValue
            }
            if let doubleValue = value as? Double {
                return Int(doubleValue)
            }
            return nil
            
        case HMCharacteristicMetadataFormatFloat:
            if let doubleValue = value as? Double {
                return Float(doubleValue)
            }
            if let intValue = value as? Int {
                return Float(intValue)
            }
            return nil
            
        case HMCharacteristicMetadataFormatString:
            if let stringValue = value as? String {
                return stringValue
            }
            return String(describing: value)
            
        case HMCharacteristicMetadataFormatUInt8, 
             HMCharacteristicMetadataFormatUInt16,
             HMCharacteristicMetadataFormatUInt32,
             HMCharacteristicMetadataFormatUInt64:
            if let intValue = value as? Int {
                return intValue
            }
            if let doubleValue = value as? Double {
                return Int(doubleValue)
            }
            return nil
            
        case HMCharacteristicMetadataFormatData:
            if let dataValue = value as? Data {
                return dataValue
            }
            if let arrayValue = value as? [UInt8] {
                return Data(arrayValue)
            }
            return nil
            
        default:
            return value
        }
    }
    
    /// Coerce a value to match the type of a reference value.
    private static func coerceValue(_ value: Any, toTypeOf reference: Any) -> Any? {
        switch reference {
        case is Bool:
            if let boolValue = value as? Bool {
                return boolValue
            }
            if let intValue = value as? Int {
                return intValue != 0
            }
            return nil
            
        case is Int:
            if let intValue = value as? Int {
                return intValue
            }
            if let doubleValue = value as? Double {
                return Int(doubleValue)
            }
            return nil
            
        case is Float:
            if let doubleValue = value as? Double {
                return Float(doubleValue)
            }
            if let intValue = value as? Int {
                return Float(intValue)
            }
            return nil
            
        case is Double:
            if let doubleValue = value as? Double {
                return doubleValue
            }
            if let intValue = value as? Int {
                return Double(intValue)
            }
            return nil
            
        case is String:
            if let stringValue = value as? String {
                return stringValue
            }
            return String(describing: value)
            
        default:
            return value
        }
    }
}

#endif
