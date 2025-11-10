// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftHomeKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "SwiftHomeKit",
            targets: ["SwiftHomeKit"]
        ),
        .executable(
            name: "HomeKitCatalogExtractor",
            targets: ["HomeKitCatalogExtractor"]
        ),
        .executable(
            name: "HomeKitServiceGenerator",
            targets: ["HomeKitServiceGenerator"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0")
    ],
    targets: [
        .target(
            name: "SwiftHomeKit",
            path: "Sources/SwiftHomeKit"
        ),
        .executableTarget(
            name: "HomeKitCatalogExtractor",
            path: "Sources/HomeKitCatalogExtractor"
        ),
        .executableTarget(
            name: "HomeKitServiceGenerator",
            path: "Sources/HomeKitServiceGenerator"
        ),
        .testTarget(
            name: "SwiftHomeKitTests",
            dependencies: ["SwiftHomeKit"],
            path: "Tests/SwiftHomeKitTests"
        )
    ]
)
