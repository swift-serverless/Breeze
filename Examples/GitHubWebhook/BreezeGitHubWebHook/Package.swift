// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BreezeGitHubWebHook",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "GitHubWebHook", targets: ["GitHubWebHook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-serverless/BreezeLambdaWebHook.git", branch: "main"),
        .package(url: "https://github.com/andrea-scuderi/swift-aws-lambda-runtime.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "GitHubWebHook",
             dependencies: [
                .product(name: "BreezeLambdaWebHook", package: "BreezeLambdaWebHook"),
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        .testTarget(
            name: "GitHubWebHookTests",
            dependencies: [
                .product(name: "BreezeLambdaWebHook", package: "BreezeLambdaWebHook"),
                .product(name: "Crypto", package: "swift-crypto"),
                "GitHubWebHook"
            ]
        )
    ]
)
