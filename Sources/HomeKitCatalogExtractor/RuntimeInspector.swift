import Foundation

struct RuntimeInspector {
    private let metadataPath: String?
    private let simulatorPath: String?

    init(metadataPath: String?, simulatorPath: String?) {
        self.metadataPath = metadataPath
        self.simulatorPath = simulatorPath
    }

    func inspectServiceCharacteristics(services: [ServiceEntry], characteristics: [CharacteristicEntry]) -> (services: [ServiceEntry], characteristics: [CharacteristicEntry]) {
        print("🔍 Inspecting HomeKit framework for service-characteristic relationships...")

        var updatedServices = services
        var updatedCharacteristics = characteristics

        if let metadataPath {
            do {
                let parser = MetadataParser(metadataPath: metadataPath)
                let metadata = try parser.loadServiceCharacteristicRelationships()
                let formatSummary = applyCharacteristicFormats(metadata.characteristicFormats, to: &updatedCharacteristics)
                let summary = apply(metadata.relationships, to: &updatedServices, characteristics: characteristics)

                if formatSummary.updatedCount > 0 {
                    print("   ✅ Updated value types for \(formatSummary.updatedCount) characteristics using metadata formats")
                }
                if !formatSummary.unmatchedCharacteristics.isEmpty {
                    let sample = formatSummary.unmatchedCharacteristics.prefix(3).joined(separator: ", ")
                    print("   ⚠️  Skipped format updates for \(formatSummary.unmatchedCharacteristics.count) metadata characteristics not present in headers (e.g. \(sample))")
                }
                if summary.appliedServices > 0 {
                    print("   ✅ Applied metadata-based mappings to \(summary.appliedServices) services")
                    if !summary.unmatchedServices.isEmpty {
                        let sample = summary.unmatchedServices.prefix(3).joined(separator: ", ")
                        print("   ⚠️  Skipped \(summary.unmatchedServices.count) metadata services not present in headers (e.g. \(sample))")
                    }
                    if !summary.missingCharacteristics.isEmpty {
                        let sample = summary.missingCharacteristics.prefix(3).joined(separator: ", ")
                        print("   ⚠️  Encountered \(summary.missingCharacteristics.count) characteristics missing from parsed headers (e.g. \(sample))")
                    }
                    return (updatedServices, updatedCharacteristics)
                }
                print("   ⚠️  Metadata parsing produced no service relationships; falling back to HAP specification mappings")
            } catch {
                print("   ⚠️  Failed to parse metadata at \(metadataPath): \(error)")
                print("   ℹ️  Falling back to HAP specification mappings")
            }
        } else {
            print("   ℹ️  Metadata not provided; falling back to HAP specification mappings")
        }

        let fallbackServices = applyFallbackMappings(to: updatedServices)
        return (fallbackServices, updatedCharacteristics)
    }

    private func apply(_ relationships: [ServiceCharacteristicRelationship], to services: inout [ServiceEntry], characteristics: [CharacteristicEntry]) -> MetadataApplicationSummary {
        var indexByName: [String: Int] = [:]
        for (index, service) in services.enumerated() {
            indexByName[service.name] = index
        }

        let characteristicNames = Set(characteristics.map { $0.name })
        var appliedCount = 0
        var unmatchedServices: [String] = []
        var missingCharacteristics = Set<String>()

        for relationship in relationships {
            guard let index = indexByName[relationship.serviceName] else {
                unmatchedServices.append(relationship.rawServiceDescription)
                continue
            }

            let required = uniquePreservingOrder(relationship.requiredCharacteristicNames.filter { characteristicNames.contains($0) })
            let optionalCandidates = relationship.optionalCharacteristicNames.filter { characteristicNames.contains($0) && !required.contains($0) }
            let optional = uniquePreservingOrder(optionalCandidates)

            let missing = relationship.requiredCharacteristicNames + relationship.optionalCharacteristicNames
            for name in missing where !characteristicNames.contains(name) {
                missingCharacteristics.insert(name)
            }

            services[index].requiredCharacteristics = required
            services[index].optionalCharacteristics = optional

            if !required.isEmpty || !optional.isEmpty {
                appliedCount += 1
            }
        }

        return MetadataApplicationSummary(
            appliedServices: appliedCount,
            unmatchedServices: unmatchedServices.sorted(),
            missingCharacteristics: missingCharacteristics.sorted()
        )
    }

    private func applyFallbackMappings(to services: [ServiceEntry]) -> [ServiceEntry] {
        var updatedServices = services
        var appliedCount = 0
        print("   ℹ️  Using HAP specification-based mapping")

        for index in updatedServices.indices {
            if let mapping = fallbackMapping(for: updatedServices[index].name) {
                updatedServices[index].requiredCharacteristics = mapping.required
                updatedServices[index].optionalCharacteristics = mapping.optional
                if !mapping.required.isEmpty || !mapping.optional.isEmpty {
                    appliedCount += 1
                }
            }
        }

        print("   ✅ Applied HAP mappings to \(appliedCount) services")
        return updatedServices
    }

    private func applyCharacteristicFormats(_ formats: [String: String], to characteristics: inout [CharacteristicEntry]) -> FormatApplicationSummary {
        guard !formats.isEmpty else {
            return FormatApplicationSummary(updatedCount: 0, unmatchedCharacteristics: [])
        }

        var indexByName: [String: Int] = [:]
        for (index, characteristic) in characteristics.enumerated() {
            indexByName[characteristic.name] = index
        }

        var updatedCount = 0
        var unmatched: [String] = []

        for (name, format) in formats {
            guard let index = indexByName[name] else {
                unmatched.append(name)
                continue
            }

            let mappedType = valueType(fromFormat: format)
            if characteristics[index].valueType != mappedType {
                characteristics[index].valueType = mappedType
                updatedCount += 1
            }
        }

        return FormatApplicationSummary(updatedCount: updatedCount, unmatchedCharacteristics: unmatched.sorted())
    }

    private func valueType(fromFormat format: String) -> String {
        switch format.lowercased() {
        case "bool":
            return "Bool"
        case "int", "uint8", "uint16", "uint32", "uint64", "uint":
            return "Int"
        case "float", "double", "percent", "temperature", "pressure":
            return "Double"
        case "data", "tlv8":
            return "Data"
        default:
            return "String"
        }
    }

    private func uniquePreservingOrder(_ values: [String]) -> [String] {
        var seen = Set<String>()
        var ordered: [String] = []
        for value in values {
            if seen.insert(value).inserted {
                ordered.append(value)
            }
        }
        return ordered
    }

    private func fallbackMapping(for serviceName: String) -> (required: [String], optional: [String])? {
        switch serviceName {
        case "Lightbulb":
            return (required: ["PowerState"], optional: ["Brightness", "Hue", "Saturation", "ColorTemperature", "Name"])
        case "Switch":
            return (required: ["PowerState"], optional: ["Name"])
        case "Outlet":
            return (required: ["PowerState", "OutletInUse"], optional: ["Name"])
        case "Thermostat":
            return (required: ["CurrentHeatingCooling", "TargetHeatingCooling", "CurrentTemperature", "TargetTemperature", "TemperatureUnits"], optional: ["CurrentRelativeHumidity", "TargetRelativeHumidity", "CoolingThreshold", "HeatingThreshold", "Name"])
        case "LockMechanism":
            return (required: ["CurrentLockMechanismState", "TargetLockMechanismState"], optional: ["Name"])
        case "GarageDoorOpener":
            return (required: ["CurrentDoorState", "TargetDoorState", "ObstructionDetected"], optional: ["Name", "LockCurrentState", "LockTargetState"])
        case "Fan":
            return (required: ["Active"], optional: ["CurrentFanState", "TargetFanState", "RotationDirection", "RotationSpeed", "SwingMode", "LockPhysicalControls", "Name"])
        case "TemperatureSensor":
            return (required: ["CurrentTemperature"], optional: ["Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "MotionSensor":
            return (required: ["MotionDetected"], optional: ["Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "ContactSensor":
            return (required: ["ContactState"], optional: ["Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "SmokeSensor":
            return (required: ["SmokeDetected"], optional: ["Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "LeakSensor":
            return (required: ["LeakDetected"], optional: ["Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "HumiditySensor":
            return (required: ["CurrentRelativeHumidity"], optional: ["Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "AirQualitySensor":
            return (required: ["AirQuality"], optional: ["OzoneDensity", "NitrogenDioxideDensity", "SulphurDioxideDensity", "PM2_5Density", "PM10Density", "VolatileOrganicCompoundDensity", "AirParticulateDensity", "AirParticulateSize", "CarbonMonoxideLevel", "CarbonDioxideLevel", "Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "Battery":
            return (required: ["BatteryLevel", "ChargingState", "StatusLowBattery"], optional: ["Name"])
        case "Window":
            return (required: ["CurrentPosition", "TargetPosition", "PositionState"], optional: ["HoldPosition", "ObstructionDetected", "Name"])
        case "WindowCovering":
            return (required: ["CurrentPosition", "TargetPosition", "PositionState"], optional: ["HoldPosition", "CurrentHorizontalTilt", "TargetHorizontalTilt", "CurrentVerticalTilt", "TargetVerticalTilt", "ObstructionDetected", "Name"])
        case "Door":
            return (required: ["CurrentPosition", "TargetPosition", "PositionState"], optional: ["HoldPosition", "ObstructionDetected", "Name"])
        case "Doorbell":
            return (required: ["InputEvent"], optional: ["Brightness", "Volume", "Name"])
        case "SecuritySystem":
            return (required: ["CurrentSecuritySystemState", "TargetSecuritySystemState"], optional: ["SecuritySystemAlarmType", "StatusFault", "StatusTampered", "Name"])
        case "CarbonMonoxideSensor":
            return (required: ["CarbonMonoxideDetected"], optional: ["CarbonMonoxideLevel", "CarbonMonoxidePeakLevel", "BatteryLevel", "Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "CarbonDioxideSensor":
            return (required: ["CarbonDioxideDetected"], optional: ["CarbonDioxideLevel", "CarbonDioxidePeakLevel", "Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "OccupancySensor":
            return (required: ["OccupancyDetected"], optional: ["Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "LightSensor":
            return (required: ["CurrentLightLevel"], optional: ["Name", "StatusActive", "StatusFault", "StatusTampered", "StatusLowBattery"])
        case "StatelessProgrammableSwitch":
            return (required: ["InputEvent"], optional: ["Name"])
        case "StatefulProgrammableSwitch":
            return (required: ["InputEvent", "OutputState"], optional: ["Name"])
        case "Microphone":
            return (required: ["Mute"], optional: ["Volume", "Name"])
        case "Speaker":
            return (required: ["Mute"], optional: ["Volume", "Active", "VolumeControlType", "VolumeSelector", "Name"])
        case "HeaterCooler":
            return (required: ["Active", "CurrentHeaterCoolerState", "TargetHeaterCoolerState", "CurrentTemperature"], optional: ["LockPhysicalControls", "SwingMode", "CoolingThreshold", "HeatingThreshold", "TemperatureUnits", "RotationSpeed", "Name"])
        case "HumidifierDehumidifier":
            return (required: ["Active", "CurrentHumidifierDehumidifierState", "TargetHumidifierDehumidifierState", "CurrentRelativeHumidity"], optional: ["LockPhysicalControls", "SwingMode", "WaterLevel", "HumidifierThreshold", "DehumidifierThreshold", "RotationSpeed", "Name"])
        case "Slats":
            return (required: ["SlatType", "CurrentSlatState"], optional: ["CurrentTilt", "TargetTilt", "SwingMode", "Name"])
        case "FilterMaintenance":
            return (required: ["FilterChangeIndication"], optional: ["FilterLifeLevel", "FilterResetChangeIndication", "Name"])
        case "AirPurifier":
            return (required: ["Active", "CurrentAirPurifierState", "TargetAirPurifierState"], optional: ["LockPhysicalControls", "SwingMode", "RotationSpeed", "Name"])
        case "Valve":
            return (required: ["Active", "InUse", "ValveType"], optional: ["SetDuration", "RemainingDuration", "IsConfigured", "Name"])
        case "IrrigationSystem":
            return (required: ["Active", "ProgramMode", "InUse"], optional: ["RemainingDuration", "StatusFault", "Name"])
        case "Faucet":
            return (required: ["Active"], optional: ["StatusFault", "Name"])
        default:
            return nil
        }
    }
}

struct MetadataApplicationSummary {
    let appliedServices: Int
    let unmatchedServices: [String]
    let missingCharacteristics: [String]
}

struct FormatApplicationSummary {
    let updatedCount: Int
    let unmatchedCharacteristics: [String]
}
