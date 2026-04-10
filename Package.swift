// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DateRecurrencePattern",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "DateRecurrencePattern",
            targets: ["DateRecurrencePattern"]
        ),
    ],
    targets: [
        .target(name: "DateRecurrencePattern"),
        .testTarget(
            name: "DateRecurrencePatternTests",
            dependencies: ["DateRecurrencePattern"]
        ),
    ]
)
