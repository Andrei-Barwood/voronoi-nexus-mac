// swift-tools-version: 5.9
// Example: Using AffineReplica as a library (not just the CLI)

import PackageDescription

let package = Package(
    name: "LibraryDemo",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Path to the parent affine-replica package
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "LibraryDemo",
            dependencies: [
                .product(name: "AffineReplica", package: "affine-replica")
            ]
        )
    ]
)
