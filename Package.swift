// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-hash-table-primitives",
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
            name: "Hash Table Primitives",
            targets: ["Hash Table Primitives"]
        ),

        .library(
            name: "Hash Indexed Primitive",
            targets: ["Hash Indexed Primitive"]
        ),

        .library(
            name: "Hash Table Primitives Test Support",
            targets: ["Hash Table Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-index-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-hash-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-property-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-ordinal-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-affine-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-cardinal-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-cyclic-index-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-finite-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-buffer-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-buffer-slots-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-buffer-linear-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-storage-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-storage-split-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-memory-heap-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-memory-allocation-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-tagged-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Hash Table Primitive",
            dependencies: [
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
                .product(
                    name: "Ordinal Primitives Standard Library Integration",
                    package: "swift-ordinal-primitives"
                ),
                .product(
                    name: "Affine Primitives Standard Library Integration",
                    package: "swift-affine-primitives"
                ),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
                .product(name: "Cyclic Index Primitives", package: "swift-cyclic-index-primitives"),
                .product(name: "Finite Primitives", package: "swift-finite-primitives"),
                .product(name: "Buffer Primitive", package: "swift-buffer-primitives"),
                .product(name: "Buffer Slots Primitive", package: "swift-buffer-slots-primitives"),
                .product(name: "Buffer Slots Primitives", package: "swift-buffer-slots-primitives"),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear-primitives"
                ),
                .product(name: "Storage Primitive", package: "swift-storage-primitives"),
                .product(
                    name: "Storage Contiguous Primitives",
                    package: "swift-storage-primitives"
                ),
                .product(name: "Store Primitive", package: "swift-storage-primitives"),
                .product(name: "Store Split Primitives", package: "swift-storage-split-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation-primitives"
                ),
            ]
        ),

        .target(
            name: "Hash Indexed Primitive",
            dependencies: [
                "Hash Table Primitive",
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
                .product(name: "Store Protocol Primitives", package: "swift-storage-primitives"),
                .product(name: "Buffer Protocol Primitives", package: "swift-buffer-primitives"),
                .product(name: "Buffer Primitive", package: "swift-buffer-primitives"),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear-primitives"
                ),
                .product(
                    name: "Buffer Linear Primitives",
                    package: "swift-buffer-linear-primitives"
                ),
                .product(name: "Storage Primitive", package: "swift-storage-primitives"),
                .product(
                    name: "Storage Contiguous Primitives",
                    package: "swift-storage-primitives"
                ),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation-primitives"
                ),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(
                    name: "Ordinal Primitives Standard Library Integration",
                    package: "swift-ordinal-primitives"
                ),
                .product(
                    name: "Affine Primitives Standard Library Integration",
                    package: "swift-affine-primitives"
                ),
            ]
        ),

        .target(
            name: "Hash Table Primitives",
            dependencies: [
                "Hash Table Primitive",
                "Hash Indexed Primitive",
            ]
        ),

        .target(
            name: "Hash Table Primitives Test Support",
            dependencies: [
                "Hash Table Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Hash Table Primitive Tests",
            dependencies: [
                "Hash Table Primitives",
                "Hash Table Primitives Test Support",
                .product(
                    name: "Buffer Primitives Test Support",
                    package: "swift-buffer-primitives"
                ),
                .product(
                    name: "Hash Primitives Standard Library Integration",
                    package: "swift-hash-primitives"
                ),
                .product(
                    name: "Tagged Primitives Standard Library Integration",
                    package: "swift-tagged-primitives"
                ),
                .product(
                    name: "Ordinal Primitives Standard Library Integration",
                    package: "swift-ordinal-primitives"
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
