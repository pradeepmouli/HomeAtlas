---
name: swift-multiplatform
description: Swift multi-platform app development with SwiftUI, Swift Concurrency, SwiftData, and iOS/macOS/tvOS/watchOS targets
---

# Swift Multi-Platform Development

Use this skill when building Swift applications targeting multiple Apple platforms (iOS, macOS, tvOS, watchOS) with SwiftUI, Swift 6 concurrency, and SwiftData.

## Project Setup

### 1. Package.swift Structure

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "UI", targets: ["UI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    ],
    targets: [
        // Core business logic (all platforms)
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),

        // UI layer (SwiftUI)
        .target(
            name: "UI",
            dependencies: ["Core"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),

        // Tests
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"]
        ),
    ]
)
```

### 2. Target Platform Conditionals

Use `#if` for platform-specific code:

```swift
#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
#elseif os(watchOS)
import WatchKit
typealias PlatformColor = UIColor
#elseif os(tvOS)
import UIKit
typealias PlatformColor = UIColor
#endif

// Capability checks
#if canImport(WidgetKit)
import WidgetKit
#endif
```

### 3. SwiftUI Platform Differences

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        NavigationStack {
            mainContent
                .navigationTitle("My App")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add", systemImage: "plus") { }
                    }
                }
        }
        #elseif os(macOS)
        NavigationSplitView {
            List {
                NavigationLink("Home", destination: mainContent)
            }
        } detail: {
            mainContent
        }
        .frame(minWidth: 800, minHeight: 600)
        #elseif os(watchOS)
        NavigationStack {
            mainContent
                .navigationTitle("My App")
        }
        #elseif os(tvOS)
        TabView {
            mainContent
                .tabItem {
                    Label("Home", systemImage: "house")
                }
        }
        #endif
    }

    @ViewBuilder
    var mainContent: some View {
        Text("Hello, World!")
    }
}
```

## Swift Concurrency Patterns

### 1. Actor for Thread-Safe State

```swift
@MainActor
final class AppViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let repository: ItemRepository

    init(repository: ItemRepository) {
        self.repository = repository
    }

    func loadItems() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await repository.fetchItems()
        } catch {
            self.error = error
        }
    }

    func addItem(_ item: Item) async throws {
        try await repository.save(item)
        items.append(item)
    }
}
```

### 2. Background Actor for Heavy Work

```swift
actor ItemRepository {
    private let database: Database
    private var cache: [String: Item] = [:]

    init(database: Database) {
        self.database = database
    }

    func fetchItems() async throws -> [Item] {
        // Runs on background actor
        let items = try await database.fetch()

        // Update cache
        for item in items {
            cache[item.id] = item
        }

        return items
    }

    func save(_ item: Item) async throws {
        try await database.insert(item)
        cache[item.id] = item
    }

    // Synchronous method (actor-isolated)
    func getCached(id: String) -> Item? {
        cache[id]
    }
}
```

### 3. Task Groups for Parallel Work

```swift
func fetchAllData() async throws -> [Item] {
    try await withThrowingTaskGroup(of: [Item].self) { group in
        // Spawn multiple concurrent tasks
        group.addTask { try await self.fetchCategory("electronics") }
        group.addTask { try await self.fetchCategory("books") }
        group.addTask { try await self.fetchCategory("clothing") }

        var allItems: [Item] = []
        for try await items in group {
            allItems.append(contentsOf: items)
        }
        return allItems
    }
}
```

### 4. AsyncSequence for Streaming

```swift
actor LiveDataStream {
    private var continuations: [UUID: AsyncStream<Data>.Continuation] = [:]

    func subscribe() -> AsyncStream<Data> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task { await self?.unsubscribe(id: id) }
            }
        }
    }

    private func unsubscribe(id: UUID) {
        continuations.removeValue(forKey: id)
    }

    func broadcast(_ data: Data) {
        for continuation in continuations.values {
            continuation.yield(data)
        }
    }
}

// Usage in View
struct LiveDataView: View {
    @State private var latestData: String = "Waiting..."
    let stream: LiveDataStream

    var body: some View {
        Text(latestData)
            .task {
                for await data in await stream.subscribe() {
                    latestData = String(data: data, encoding: .utf8) ?? "Invalid"
                }
            }
    }
}
```

### 5. Sendable Conformance

```swift
// Value types are implicitly Sendable
struct Item: Sendable {
    let id: String
    let name: String
    let timestamp: Date
}

// Reference types must be explicitly marked
final class Configuration: @unchecked Sendable {
    // Must be thread-safe manually
    private let lock = NSLock()
    private var _settings: [String: String] = [:]

    func getSetting(_ key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return _settings[key]
    }

    func setSetting(_ key: String, value: String) {
        lock.lock()
        defer { lock.unlock() }
        _settings[key] = value
    }
}
```

## SwiftData Patterns

### 1. Model Definition

```swift
import SwiftData

@Model
final class Item {
    @Attribute(.unique) var id: String
    var name: String
    var createdAt: Date
    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \Tag.items)
    var tags: [Tag]

    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.tags = []
    }
}

@Model
final class Category {
    @Attribute(.unique) var id: String
    var name: String

    @Relationship(deleteRule: .nullify, inverse: \Item.category)
    var items: [Item]

    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
        self.items = []
    }
}

@Model
final class Tag {
    @Attribute(.unique) var id: String
    var name: String
    var items: [Item]

    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
        self.items = []
    }
}
```

### 2. Model Container Setup

```swift
import SwiftUI
import SwiftData

@main
struct MyApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                Item.self,
                Category.self,
                Tag.self,
            ])

            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic  // iCloud sync
            )

            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
```

### 3. Querying Data in Views

```swift
import SwiftUI
import SwiftData

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext

    // Query all items, sorted by creation date
    @Query(sort: \Item.createdAt, order: .reverse)
    private var items: [Item]

    // Filtered query
    // @Query(filter: #Predicate<Item> { $0.category?.name == "Electronics" })
    // private var electronics: [Item]

    var body: some View {
        List {
            ForEach(items) { item in
                ItemRow(item: item)
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                addItem()
            }
        }
    }

    private func addItem() {
        let newItem = Item(name: "New Item")
        modelContext.insert(newItem)

        // Save happens automatically, but can force:
        // try? modelContext.save()
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}
```

### 4. Background Context Operations

```swift
actor ItemService {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func importItems(_ data: [ItemData]) async throws {
        // Create background context
        let context = ModelContext(container)

        for itemData in data {
            let item = Item(name: itemData.name)
            context.insert(item)
        }

        try context.save()
    }

    func fetchItem(id: String) async throws -> Item? {
        let context = ModelContext(container)

        let predicate = #Predicate<Item> { $0.id == id }
        let descriptor = FetchDescriptor<Item>(predicate: predicate)

        return try context.fetch(descriptor).first
    }
}
```

### 5. Complex Predicates

```swift
import Foundation

// Multiple conditions
let predicate = #Predicate<Item> { item in
    item.name.contains("Widget") &&
    item.createdAt > Date().addingTimeInterval(-86400) &&
    item.category?.name == "Electronics"
}

@Query(filter: predicate, sort: \.createdAt)
var recentElectronicWidgets: [Item]

// Dynamic predicates
struct FilteredItemList: View {
    @State private var searchText = ""

    var body: some View {
        ItemList(searchText: searchText)
            .searchable(text: $searchText)
    }
}

struct ItemList: View {
    let searchText: String

    @Query private var items: [Item]

    init(searchText: String) {
        self.searchText = searchText

        let predicate: Predicate<Item>
        if searchText.isEmpty {
            predicate = #Predicate { _ in true }
        } else {
            predicate = #Predicate { $0.name.contains(searchText) }
        }

        _items = Query(filter: predicate, sort: \.name)
    }

    var body: some View {
        List(items) { item in
            Text(item.name)
        }
    }
}
```

## Platform-Specific Features

### iOS-Specific

```swift
#if os(iOS)
import UIKit

extension View {
    func hapticFeedback() -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

// Safe area insets
struct ContentView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    var body: some View {
        Text("Top inset: \(safeAreaInsets.top)")
    }
}
#endif
```

### macOS-Specific

```swift
#if os(macOS)
import AppKit

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            AdvancedSettings()
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 500, height: 400)
    }
}

// Menu bar app
@main
struct MenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("My App", systemImage: "star") {
            MenuContent()
        }
        .menuBarExtraStyle(.window)
    }
}
#endif
```

### watchOS-Specific

```swift
#if os(watchOS)
import WatchKit

struct WorkoutView: View {
    @State private var isActive = false

    var body: some View {
        VStack {
            Text("Heart Rate: 120 BPM")
                .font(.title2)

            Button(isActive ? "Pause" : "Start") {
                isActive.toggle()
            }
            .tint(isActive ? .red : .green)
        }
        .navigationTitle("Workout")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("End", role: .destructive) {
                    // End workout
                }
            }
        }
    }
}
#endif
```

### tvOS-Specific

```swift
#if os(tvOS)
struct MediaView: View {
    @FocusState private var focusedItem: String?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                ForEach(videos) { video in
                    VideoCard(video: video)
                        .focusable()
                        .focused($focusedItem, equals: video.id)
                        .scaleEffect(focusedItem == video.id ? 1.1 : 1.0)
                }
            }
        }
    }
}
#endif
```

## Testing

### 1. Swift Testing Framework

```swift
import Testing
@testable import Core

@Suite("Item Tests")
struct ItemTests {
    @Test("Item initialization")
    func testInitialization() {
        let item = Item(name: "Test Item")

        #expect(item.name == "Test Item")
        #expect(item.id.isEmpty == false)
        #expect(item.createdAt <= Date())
    }

    @Test("Item with category")
    func testCategory() {
        let category = Category(name: "Electronics")
        let item = Item(name: "iPhone")
        item.category = category

        #expect(item.category?.name == "Electronics")
    }

    @Test("Async repository fetch", arguments: [
        ["item1", "item2"],
        ["item3", "item4", "item5"]
    ])
    func testRepositoryFetch(itemNames: [String]) async throws {
        let repository = ItemRepository(database: MockDatabase())

        // Seed data
        for name in itemNames {
            try await repository.save(Item(name: name))
        }

        let items = try await repository.fetchItems()
        #expect(items.count == itemNames.count)
    }
}
```

### 2. Testing with ModelContainer

```swift
import Testing
import SwiftData

@Suite("SwiftData Tests")
struct SwiftDataTests {
    var container: ModelContainer

    init() throws {
        let schema = Schema([Item.self, Category.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
    }

    @Test("Insert and fetch item")
    func testInsertFetch() throws {
        let context = ModelContext(container)

        let item = Item(name: "Test")
        context.insert(item)
        try context.save()

        let descriptor = FetchDescriptor<Item>()
        let items = try context.fetch(descriptor)

        #expect(items.count == 1)
        #expect(items.first?.name == "Test")
    }
}
```

## Build Configuration

### Debug vs Release

```swift
#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif

// Or use compiler flags
// Build Settings > Swift Compiler - Custom Flags > Other Swift Flags
// Debug: -DDEBUG
// Release: -DRELEASE

#if DEBUG
print("Debug mode active")
#endif
```

### Custom Build Configurations

In Package.swift:
```swift
targets: [
    .target(
        name: "Core",
        swiftSettings: [
            .define("ENABLE_LOGGING", .when(configuration: .debug)),
            .define("USE_MOCK_API", .when(configuration: .debug)),
        ]
    ),
]
```

Usage:
```swift
#if ENABLE_LOGGING
Logger.log("Detailed debug info")
#endif
```

## Common Patterns

### Dependency Injection

```swift
protocol ItemRepositoryProtocol {
    func fetchItems() async throws -> [Item]
    func save(_ item: Item) async throws
}

@MainActor
final class AppViewModel: ObservableObject {
    private let repository: ItemRepositoryProtocol

    init(repository: ItemRepositoryProtocol) {
        self.repository = repository
    }
}

// Usage
ContentView()
    .environmentObject(AppViewModel(repository: LiveItemRepository()))

// Testing
let viewModel = AppViewModel(repository: MockItemRepository())
```

### Environment Values

```swift
private struct AppConfigKey: EnvironmentKey {
    static let defaultValue = AppConfig()
}

extension EnvironmentValues {
    var appConfig: AppConfig {
        get { self[AppConfigKey.self] }
        set { self[AppConfigKey.self] = newValue }
    }
}

// Usage
struct MyView: View {
    @Environment(\.appConfig) private var config

    var body: some View {
        Text("API URL: \(config.apiURL)")
    }
}

// Provide
ContentView()
    .environment(\.appConfig, AppConfig(apiURL: "https://api.example.com"))
```

## Performance Tips

1. **Use @Query sparingly** - Each @Query creates a new fetch request
2. **Batch updates** - Use ModelContext for multiple operations
3. **Background contexts** - Heavy work should use background ModelContext
4. **Lazy loading** - Use AsyncImage, LazyVStack, LazyHStack
5. **Task prioritization** - Use `.task(priority:)` for important work

## Resources

- Swift Evolution: https://github.com/swiftlang/swift-evolution
- SwiftUI Documentation: https://developer.apple.com/documentation/swiftui
- Swift Concurrency: https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html
- SwiftData: https://developer.apple.com/documentation/swiftdata
