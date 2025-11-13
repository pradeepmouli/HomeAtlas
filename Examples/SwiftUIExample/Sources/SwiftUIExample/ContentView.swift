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
                if services.isEmpty { Text("No services") }
                ForEach(services, id: \.uniqueIdentifier) { svc in
                    Text(svc.name)
                }
            }
        }
        .navigationTitle(accessory.name)
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
