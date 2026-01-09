// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HomeAtlasApp",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "HomeAtlasApp",
            targets: ["HomeAtlasApp"]
        )
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "HomeAtlasApp",
            dependencies: [
                .product(name: "HomeAtlas", package: "HomeAtlas")
            ],
            path: "Sources",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])
            ]
        )
    ]
)
