// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RecurrenceKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "RecurrenceKit",
            targets: ["RecurrenceKit"]
        ),
    ],
    targets: [
        .target(name: "RecurrenceKit"),
        .testTarget(
            name: "RecurrenceKitTests",
            dependencies: ["RecurrenceKit"]
        ),
    ]
)
