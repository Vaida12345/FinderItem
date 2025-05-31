// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FinderItem",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ], products: [
        .library(name: "FinderItem", targets: ["FinderItem"])
    ], dependencies: [
        .package(url: "https://www.github.com/Vaida12345/Essentials", from: "1.0.45"),
        .package(url: "https://www.github.com/Vaida12345/DetailedDescription", from: "2.0.3"),
    ], targets: [
        .target(name: "CComponent"),
        .target(name: "FinderItem", dependencies: ["CComponent", "Essentials", "DetailedDescription"]),
        .executableTarget(name: "Client", dependencies: ["FinderItem"], path: "Client"),
        .testTarget(name: "FinderItemTests", dependencies: ["FinderItem"])
    ]
)
