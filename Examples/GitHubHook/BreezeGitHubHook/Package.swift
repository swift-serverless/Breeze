// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BreezeGitHubHook",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "GitHubWebHook", targets: ["GitHubWebHook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-sprinter/Breeze.git", branch: "feature/web_hook"),
        //.package(url: "https://github.com/swift-sprinter/Breeze.git", from: "0.3.0")
    ],
    targets: [
        .executableTarget(
            name: "GitHubWebHook",
             dependencies: [
                .product(name: "BreezeLambdaWebHook", package: "Breeze"),
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        .testTarget(
            name: "GitHubWebHookTests",
            dependencies: [
                .product(name: "BreezeLambdaWebHook", package: "Breeze"),
                .product(name: "Crypto", package: "swift-crypto"),
                "GitHubWebHook"
            ]
        )
    ]
)
