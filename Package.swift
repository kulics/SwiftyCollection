// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyCollection",
    products: [
        .library(
            name: "SwiftyCollection",
            targets: ["SwiftyCollection"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftyCollection",
            dependencies: []),
        .testTarget(
            name: "SwiftyCollectionTests",
            dependencies: ["SwiftyCollection"]),
    ],
    swiftLanguageVersions: [SwiftVersion.version("5.7")]
)
