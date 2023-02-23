// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Breeze",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "BreezeDynamoDBService",
            targets: ["BreezeDynamoDBService"]
        ),
        .library(
            name: "BreezeLambdaAPI",
            targets: ["BreezeLambdaAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.1"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", branch: "main"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
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
        .testTarget(
            name: "BreezeLambdaAPITests",
            dependencies: ["BreezeLambdaAPI"]
        ),
        .testTarget(
            name: "BreezeDynamoDBServiceTests",
            dependencies: ["BreezeDynamoDBService"]
        ),
    ]
)