// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "delaunay-sentinel",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DelaunaySentinel",
            targets: ["DelaunaySentinel"]
        ),
        .executable(
            name: "delaunay-sentinel",
            targets: ["DelaunaySentinelCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "DelaunaySentinel",
            dependencies: []
        ),
        .executableTarget(
            name: "DelaunaySentinelCLI",
            dependencies: [
                "DelaunaySentinel",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
