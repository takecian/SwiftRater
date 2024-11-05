// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SwiftRater",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
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
            path: "SwiftRater",
            exclude: ["Info.plist"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "SwiftRaterTests",
            dependencies: ["SwiftRater"],
            path: "SwiftRaterTests",
            exclude: ["Info.plist"]
        ),
    ]
)
