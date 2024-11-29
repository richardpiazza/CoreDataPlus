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
        .package(url: "https://github.com/richardpiazza/Occurrence.git", .upToNextMajor(from: "0.7.2")),
    ],
    targets: [
        .target(
            name: "CoreDataPlus",
            dependencies: [
                .product(name: "Occurrence", package: "Occurrence"),
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
