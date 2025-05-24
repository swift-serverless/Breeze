// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(macOS)
let platforms: [PackageDescription.SupportedPlatform]? = [.macOS(.v15), .iOS(.v13)]
#else
let platforms: [PackageDescription.SupportedPlatform]? = nil
#endif

let package = Package(
    name: "BreezeItemAPI",
    platforms: platforms,
    products: [
        .executable(name: "ItemAPI", targets: ["ItemAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-serverless/BreezeLambdaDynamoDBAPI.git", branch: "feature/swift-6"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", branch: "main")
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
