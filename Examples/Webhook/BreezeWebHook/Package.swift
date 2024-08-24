// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BreezeWebHook",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "WebHook", targets: ["WebHook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-serverless/BreezeLambdaWebHook.git", from: "0.4.0"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.1")
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
