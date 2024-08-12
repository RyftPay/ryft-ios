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
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "JOSESwift",
            path: "frameworks/JOSESwift.xcframework/"
        ),
        .binaryTarget(
            name: "CheckoutEventLoggerKit",
            path: "frameworks/CheckoutEventLoggerKit.xcframework/"
        ),
        .binaryTarget(
            name: "Checkout3DS",
            path: "frameworks/Checkout3DS.xcframework/"
        ),
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
                "JOSESwift",
                "CheckoutEventLoggerKit",
                "Checkout3DS"
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

