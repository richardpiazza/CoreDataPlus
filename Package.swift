// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataPlus",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v5),
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
    ],
    targets: [
        .target(
            name: "CoreDataPlus",
            dependencies: []
        ),
        .testTarget(
            name: "CoreDataPlusTests",
            dependencies: ["CoreDataPlus"],
            resources: [
                .process("Resources")
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
