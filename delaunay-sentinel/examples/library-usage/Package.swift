// swift-tools-version: 5.9
// Example: Using DelaunaySentinel as a library (not just the CLI)

import PackageDescription

let package = Package(
    name: "LibraryDemo",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Path to the parent delaunay-sentinel package
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "LibraryDemo",
            dependencies: [
                .product(name: "DelaunaySentinel", package: "delaunay-sentinel")
            ]
        )
    ]
)
