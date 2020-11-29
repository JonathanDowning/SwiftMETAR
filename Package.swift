// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "METAR",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "METAR", targets: ["METAR"])
    ],
    targets: [
        .target(name: "METAR"),
        .testTarget(name: "METARTests", dependencies: ["METAR"])
    ]
)
