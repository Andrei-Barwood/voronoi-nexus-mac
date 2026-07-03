// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "affine-replica",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AffineReplica",
            targets: ["AffineReplica"]
        ),
        .executable(
            name: "affine-replica",
            targets: ["AffineReplicaCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "AffineReplica",
            dependencies: []
        ),
        .executableTarget(
            name: "AffineReplicaCLI",
            dependencies: [
                "AffineReplica",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
