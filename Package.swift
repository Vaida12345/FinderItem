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
        .package(url: "https://github.com/Vaida12345/Essentials", from: "1.0.0")
    ], targets: [
        .target(name: "CComponent"),
        .target(name: "FinderItem", dependencies: ["CComponent", "Essentials"]),
        .testTarget(name: "FinderItemTests", dependencies: ["FinderItem"])
    ], swiftLanguageModes: [.v5]
)
