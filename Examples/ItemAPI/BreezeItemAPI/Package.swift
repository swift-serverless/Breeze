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
        .package(url: "https://github.com/swift-serverless/BreezeLambdaDynamoDBAPI.git", from: "1.0.0-rc.1"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "2.0.0-rc.1")
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
