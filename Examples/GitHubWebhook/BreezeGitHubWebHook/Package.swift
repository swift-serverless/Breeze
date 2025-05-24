// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(macOS)
let platforms: [PackageDescription.SupportedPlatform]? = [.macOS(.v15), .iOS(.v13)]
#else
let platforms: [PackageDescription.SupportedPlatform]? = nil
#endif

let package = Package(
    name: "BreezeGitHubWebHook",
    platforms: platforms,
    products: [
        .executable(name: "GitHubWebHook", targets: ["GitHubWebHook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
//        .package(url: "https://github.com/swift-serverless/BreezeLambdaWebHook.git", from: "0.5.0"),
        .package(url: "https://github.com/swift-serverless/BreezeLambdaWebHook.git", branch: "feature/swift-6"),
//        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.2")
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", branch: "main"),
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
