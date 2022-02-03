// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ryft",
    defaultLocalization: "en-gb",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "RyftCore",
            targets: ["RyftCore"]
        ),
        .library(
            name: "RyftCard",
            targets: ["RyftCard"]
        ),
        .library(
            name: "RyftUI",
            targets: ["RyftUI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RyftCore",
            path: "RyftCore/Source",
            exclude: ["Tests", "Info.plist"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "RyftCard",
            path: "RyftCard/Source",
            exclude: ["Tests", "Info.plist"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "RyftUI",
            dependencies: ["RyftCore", "RyftCard"],
            path: "RyftUI/Source",
            exclude: ["Tests", "Info.plist"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)

