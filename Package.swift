// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataPlus",
    platforms: [
        .macOS(.v12),
        .macCatalyst(.v15),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "CoreDataPlus",
            targets: [
                "CoreDataPlus"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.2"),
    ],
    targets: [
        .target(
            name: "CoreDataPlus",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "CoreDataPlusTests",
            dependencies: [
                "CoreDataPlus"
            ],
            resources: [
                .process("Resources"),
                .copy("PrecompiledResources"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
