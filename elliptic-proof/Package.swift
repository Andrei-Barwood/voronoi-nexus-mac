// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "elliptic-proof",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "EllipticProof",
            targets: ["EllipticProof"]
        ),
        .executable(
            name: "elliptic-proof",
            targets: ["EllipticProofCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "EllipticProof",
            dependencies: []
        ),
        .executableTarget(
            name: "EllipticProofCLI",
            dependencies: [
                "EllipticProof",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
