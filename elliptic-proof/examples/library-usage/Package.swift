// swift-tools-version: 5.9
// Example: Using EllipticProof as a library

import PackageDescription

let package = Package(
    name: "LibraryDemo",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "LibraryDemo",
            dependencies: [
                .product(name: "EllipticProof", package: "elliptic-proof")
            ]
        )
    ]
)
