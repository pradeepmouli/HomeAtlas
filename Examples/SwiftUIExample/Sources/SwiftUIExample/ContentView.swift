import SwiftUI
import HomeAtlas
#if canImport(HomeKit)
import HomeKit
#endif

// Root content view listing homes and their accessories.
@MainActor
struct ContentView: View {
    @ObservedObject var manager: HomeKitManager
    let isReady: Bool

    var body: some View {
        NavigationStack {
            Group {
#if canImport(HomeKit)
                if isReady {
                    if manager.homes.isEmpty {
                        Text("No HomeKit homes detected.")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach(manager.homes, id: \.uniqueIdentifier) { home in
                                Section(home.name) {
                                    AccessoryList(accessories: home.accessories.map { Accessory($0) })
                                }
                            }
                        }
                    }
                } else {
                    ProgressView("Discovering HomeKit homes…")
                        .padding()
                }
#else
                Text("HomeKit not available on this platform. Running in stub mode.")
                    .foregroundStyle(.secondary)
                    .padding()
#endif
            }
            .navigationTitle("HomeAtlas Demo")
        }
    }
}

// List of accessories for a given home.
@MainActor
struct AccessoryList: View {
#if canImport(HomeKit)
    let accessories: [Accessory]
#else
    let accessories: [Accessory] = []
#endif
    var body: some View {
        if accessories.isEmpty {
            Text("No accessories")
                .foregroundStyle(.tertiary)
        } else {
#if canImport(HomeKit)
            ForEach(accessories, id: \.uniqueIdentifier) { accessory in
                NavigationLink(destination: AccessoryDetail(accessory: accessory)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(accessory.name)
                            Text(accessory.category.localizedDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        ReachabilityDot(isReachable: accessory.isReachable)
                    }
                }
            }
#else
            Text("HomeKit not available")
                .foregroundStyle(.secondary)
#endif
        }
    }
}

#if canImport(HomeKit)
// Detail view for a single accessory.
@MainActor
struct AccessoryDetail: View {
    let accessory: Accessory
    var body: some View {
        List {
            Section("Metadata") {
                Text("Name: \(accessory.name)")
                Text("Reachable: \(accessory.isReachable ? "Yes" : "No")")
                if let room = accessory.room { Text("Room: \(room.name)") }
                Text("Category: \(accessory.category.localizedDescription)")
            }
            Section("Services") {
                let services = accessory.allServices()
                if services.isEmpty {
                    Text("No services")
                } else {
                    ForEach(services, id: \.uniqueIdentifier) { svc in
                        NavigationLink(destination: ServiceDetail(service: svc)) {
                            HStack {
                                Text(svc.localizedDescription)
                                Spacer()
                                if svc.isPrimaryService {
                                    Text("Primary")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.secondary.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(accessory.name)
    }
}

// Detail view for a single service showing its characteristics.
@MainActor
struct ServiceDetail: View {
    let service: Service

    var body: some View {
        List {
            Section("Service Info") {
                Text("Name: \(service.name ?? "Unnamed service")")
                Text("Type: \(service.serviceType)")
                Text("Primary: \(service.isPrimaryService ? "Yes" : "No")")
                Text("User Interactive: \(service.isUserInteractive ? "Yes" : "No")")
            }

            let characteristics = service.allCharacteristics()
            Section("Characteristics (\(characteristics.count))") {
                if characteristics.isEmpty {
                    Text("No characteristics")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(0..<characteristics.count, id: \.self) { index in
                        CharacteristicRow(characteristic: characteristics[index])
                    }
                }
            }
        }
        .navigationTitle(service.name ?? "Service")
    }
}

// Row displaying a single characteristic's information.
@MainActor
struct CharacteristicRow: View {
    let characteristic: Characteristic<Any>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(characteristic.localizedDescription)
                .font(.headline)

            HStack {
                Text("Type:")
                    .foregroundStyle(.secondary)
                Text(characteristic.characteristicType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Access the underlying HMCharacteristic to get the value
            #if canImport(HomeKit)
            if let underlyingValue = Mirror(reflecting: characteristic).descendant("underlying", "value") {
                HStack {
                    Text("Value:")
                        .foregroundStyle(.secondary)
                    Text("\(String(describing: underlyingValue))")
                        .font(.body)
                }
            }
            #endif

            if let metadata = characteristic.metadata {
                HStack {
                    Text("Format:")
                        .foregroundStyle(.secondary)
                    Text(metadata.format ?? "Unknown")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
#endif

// Small reachability indicator dot.
@MainActor
struct ReachabilityDot: View {
    let isReachable: Bool
    var body: some View {
        Circle()
            .fill(isReachable ? Color.green : Color.red)
            .frame(width: 10, height: 10)
            .accessibilityLabel(isReachable ? "Reachable" : "Unreachable")
    }
}

#Preview("Empty") {
    ContentView(manager: HomeKitManager(), isReady: true)
}
