// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftRater",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "SwiftRater",
            targets: ["SwiftRater"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftRater",
            path: "SwiftRater"
        ),
        .testTarget(
            name: "SwiftRaterTests",
            dependencies: ["SwiftRater"],
            path: "SwiftRaterTests"
        ),
    ]
)
