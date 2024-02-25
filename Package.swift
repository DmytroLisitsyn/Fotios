// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fotios",
    platforms: [.macOS(.v10_15), .iOS(.v13), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(name: "Fotios", targets: ["Fotios"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Fotios", dependencies: []),
        .testTarget(name: "FotiosTests", dependencies: ["Fotios"])
    ]
)
