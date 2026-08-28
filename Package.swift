// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-hash-table",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Hash Table Primitive",
            targets: ["Hash Table Primitive"]
        ),
        .library(
            name: "Hash Table",
            targets: ["Hash Table"]
        ),

        .library(
            name: "Hash Indexed Primitive",
            targets: ["Hash Indexed Primitive"]
        ),

        .library(
            name: "Hash Table Test Support",
            targets: ["Hash Table Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-hash.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-property.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-property-ownership.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ownership.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ordinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-affine.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cyclic-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-finite.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-buffer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-slots.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-linear.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-storage.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-storage-split.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-storage-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-allocation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-small.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Hash Table Primitive",
            dependencies: [
                .product(name: "Index", package: "swift-index"),
                .product(name: "Hash", package: "swift-hash"),
                .product(name: "Property", package: "swift-property"),
                .product(
                    name: "Property Ownership",
                    package: "swift-property-ownership"
                ),
                .product(name: "Ownership", package: "swift-ownership"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(
                    name: "Ordinal Standard Library Integration",
                    package: "swift-ordinal"
                ),
                .product(
                    name: "Affine Standard Library Integration",
                    package: "swift-affine"
                ),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cyclic Index", package: "swift-cyclic-index"),
                .product(name: "Finite", package: "swift-finite"),
                .product(name: "Buffer", package: "swift-buffer"),
                .product(name: "Buffer Slots", package: "swift-buffer-slots"),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(name: "Storage", package: "swift-storage"),
                .product(name: "Storage Memory", package: "swift-storage-memory"),
                .product(name: "Store Split", package: "swift-storage-split"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Memory Small", package: "swift-memory-small"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation"
                ),
                .product(
                    name: "Memory Allocator Protocol",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Hash Indexed Primitive",
            dependencies: [
                "Hash Table Primitive",
                .product(name: "Hash", package: "swift-hash"),
                .product(name: "Storage", package: "swift-storage"),
                .product(name: "Buffer", package: "swift-buffer"),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(
                    name: "Buffer Linear",
                    package: "swift-buffer-linear"
                ),
                .product(name: "Storage Memory", package: "swift-storage-memory"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Memory Small", package: "swift-memory-small"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation"
                ),
                .product(
                    name: "Memory Allocator Protocol",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(
                    name: "Ordinal Standard Library Integration",
                    package: "swift-ordinal"
                ),
                .product(
                    name: "Affine Standard Library Integration",
                    package: "swift-affine"
                ),
            ]
        ),

        .target(
            name: "Hash Table",
            dependencies: [
                "Hash Table Primitive",
                "Hash Indexed Primitive",
            ]
        ),

        .target(
            name: "Hash Table Test Support",
            dependencies: [
                "Hash Table",
                .product(name: "Buffer", package: "swift-buffer"),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(name: "Hash", package: "swift-hash"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Storage", package: "swift-storage"),
                .product(name: "Storage Memory", package: "swift-storage-memory"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Memory Small", package: "swift-memory-small"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Ordinal", package: "swift-ordinal"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Hash Table Primitive Tests",
            dependencies: [
                "Hash Table",
                "Hash Table Test Support",
                .product(name: "Buffer", package: "swift-buffer"),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(name: "Storage", package: "swift-storage"),
                .product(name: "Storage Memory", package: "swift-storage-memory"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Memory Small", package: "swift-memory-small"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(
                    name: "Hash Standard Library Integration",
                    package: "swift-hash"
                ),
                .product(
                    name: "Tagged Standard Library Integration",
                    package: "swift-tagged"
                ),
                .product(
                    name: "Ordinal Standard Library Integration",
                    package: "swift-ordinal"
                ),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
