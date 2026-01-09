// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IntegrationExample",
    platforms: [
        .iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9)
    ],
    products: [
        .executable(name: "IntegrationExample", targets: ["IntegrationExample"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "IntegrationExample",
            dependencies: [
                .product(name: "HomeAtlas", package: "HomeAtlas")
            ]
        )
    ]
)
