// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Breeze",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "breeze",
            targets: ["BreezeCommand"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
        .package(url: "https://github.com/swift-serverless/swift-sls-adapter", from: "0.2.1"),
        .package(url: "https://github.com/tuist/Noora.git", from: "0.45.0")
    ],
    targets: [
        .executableTarget(
            name: "BreezeCommand",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SLSAdapter", package: "swift-sls-adapter"),
                .product(name: "Stencil", package: "Stencil"),
                .product(name: "Noora", package: "Noora")
            ],
            resources: [.copy("Resources")]
        ),
        .testTarget(
            name: "BreezeCommandTests",
            dependencies: ["BreezeCommand"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
