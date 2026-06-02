// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ryft",
    defaultLocalization: "en-gb",
    platforms: [
        .iOS(.v12)
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
    dependencies: [
        .package(
            url: "https://github.com/unravelin/ravelin-3ds-sdk-ios-xcframework-distribution.git",
            from: "2.0.1"
        )
    ],
    targets: [
        .target(
            name: "RyftCore",
            path: "RyftCore/Source",
            exclude: ["Tests", "Info.plist"],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .target(
            name: "RyftCard",
            path: "RyftCard/Source",
            exclude: ["Tests", "Info.plist"],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .target(
            name: "RyftUI",
            dependencies: [
                "RyftCore",
                "RyftCard",
                .product(name: "Ravelin3DS", package: "ravelin-3ds-sdk-ios-xcframework-distribution")
            ],
            path: "RyftUI/Source",
            exclude: ["Tests", "Info.plist"],
            resources: [
                .process("Resources"),
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
    ]
)

