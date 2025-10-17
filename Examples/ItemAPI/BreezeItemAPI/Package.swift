// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BreezeItemAPI",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "ItemAPI", targets: ["ItemAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-serverless/BreezeLambdaDynamoDBAPI.git", from: "1.1.0"),
        .package(url: "https://github.com/awslabs/swift-aws-lambda-runtime.git", from: "2.2.0")
    ],
    targets: [
        .executableTarget(
            name: "ItemAPI",
             dependencies: [
                .product(name: "BreezeLambdaAPI", package: "BreezeLambdaDynamoDBAPI"),
                .product(name: "BreezeDynamoDBService", package: "BreezeLambdaDynamoDBAPI"),
            ]
        )
    ]
)
