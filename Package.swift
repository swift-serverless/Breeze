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
        ),
        .library(
            name: "BreezeDynamoDBService",
            targets: ["BreezeDynamoDBService"]
        ),
        .library(
            name: "BreezeLambdaAPI",
            targets: ["BreezeLambdaAPI"]
        ),
        .library(
            name: "BreezeLambdaWebHook",
            targets: ["BreezeLambdaWebHook"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.1"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", from: "0.1.0"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.7.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
        .package(url: "https://github.com/swift-sprinter/swift-sls-adapter", from: "0.2.1"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.11.2"),
    ],
    targets: [
        .target(
            name: "BreezeDynamoDBService",
            dependencies: [
                .product(name: "SotoDynamoDB", package: "soto"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .target(
            name: "BreezeLambdaAPI",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                "BreezeDynamoDBService"
            ]
        ),
        .target(
            name: "BreezeLambdaWebHook",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
        .executableTarget(
            name: "BreezeCommand",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SLSAdapter", package: "swift-sls-adapter"),
                .product(name: "Stencil", package: "Stencil")
            ],
            resources: [.copy("Resources")]
        ),
        .testTarget(
            name: "BreezeLambdaAPITests",
            dependencies: [
                .product(name: "AWSLambdaTesting", package: "swift-aws-lambda-runtime"),
                "BreezeLambdaAPI"
            ],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "BreezeDynamoDBServiceTests",
            dependencies: ["BreezeDynamoDBService"]
        ),
        .testTarget(
            name: "BreezeCommandTests",
            dependencies: ["BreezeCommand"],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "BreezeLambdaWebHookTests",
            dependencies: [
                .product(name: "AWSLambdaTesting", package: "swift-aws-lambda-runtime"),
                "BreezeLambdaWebHook"
            ],
            resources: [.copy("Fixtures")]
        ),
    ]
)
