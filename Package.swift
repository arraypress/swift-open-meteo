// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-open-meteo",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .library(name: "OpenMeteo", targets: ["OpenMeteo"]),
    ],
    targets: [
        .target(name: "OpenMeteo"),
        .testTarget(
            name: "OpenMeteoTests",
            dependencies: ["OpenMeteo"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
