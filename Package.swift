// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GKLogger",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GKLogger",
            targets: ["GKLogger"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GKLogger",
            dependencies: [],
            
            resources: [.process("Resources")]),
        .testTarget(
            name: "GKLoggerTests",
            dependencies: ["GKLogger"]),
    ]
)
