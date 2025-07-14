// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BreezeWebHook",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "WebHook", targets: ["WebHook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-serverless/BreezeLambdaWebHook.git", branch: "main"),
        .package(url: "https://github.com/andrea-scuderi/swift-aws-lambda-runtime.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "WebHook",
             dependencies: [
                .product(name: "BreezeLambdaWebHook", package: "BreezeLambdaWebHook"),
            ]
        )
    ]
)
