// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "HomeAtlas",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v13),
        .tvOS(.v18),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "HomeAtlas",
            targets: ["HomeAtlas"]
        ),
        .executable(
            name: "HomeKitCatalogExtractor",
            targets: ["HomeKitCatalogExtractor"]
        ),
        .executable(
            name: "HomeKitServiceGenerator",
            targets: ["HomeKitServiceGenerator"]
        ),
        // SwiftUI demo application showcasing basic HomeAtlas usage.
        .executable(
            name: "HomeAtlasSwiftUIExample",
            targets: ["HomeAtlasSwiftUIExample"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0")
    ],
    targets: [
    // Macro compiler plugin
        .macro(
            name: "HomeAtlasMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/HomeAtlasMacros"
        ),

        // Main library with macro support
        .target(
            name: "HomeAtlas",
            dependencies: ["HomeAtlasMacros"],
            path: "Sources/HomeAtlas"
        ),
        .executableTarget(
            name: "HomeKitCatalogExtractor",
            path: "Sources/HomeKitCatalogExtractor"
        ),
        .executableTarget(
            name: "HomeKitServiceGenerator",
            path: "Sources/HomeKitServiceGenerator"
        ),
        // Example SwiftUI application (macOS/iOS) demonstrating library usage.
        .executableTarget(
            name: "HomeAtlasSwiftUIExample",
            dependencies: ["HomeAtlas"],
            path: "Examples/SwiftUIExample/Sources/SwiftUIExample"
        ),
        .testTarget(
            name: "HomeAtlasTests",
            dependencies: ["HomeAtlas"],
            path: "Tests/HomeAtlasTests"
        ),
        .testTarget(
            name: "HomeAtlasMacrosTests",
            dependencies: [
                "HomeAtlasMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            path: "Tests/HomeAtlasMacrosTests"
        )
    ]
)
