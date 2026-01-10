// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HomeAtlasSwiftUIExample",
    platforms: [
        .macOS(.v15)
        
    ],
    products: [
        .executable(
            name: "HomeAtlasSwiftUIExample",
            targets: ["SwiftUIExample"]
        )
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "SwiftUIExample",
            dependencies: [
                .product(name: "HomeAtlas", package: "HomeAtlas")
            ],
            path: "Sources/SwiftUIExample",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks",
                    "-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Sources/SwiftUIExample/Info.plist"
                ])
            ]
        )
    ]
)
