// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fotios",
    platforms: [.macOS(.v10_14), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "Fotios",
            targets: ["Fotios"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Fotios",
            dependencies: [],
            exclude: ["Info.plist"]),
        .testTarget(
            name: "FotiosTests",
            dependencies: ["Fotios"]),
    ]
)
