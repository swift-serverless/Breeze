# breeze
Serverless API using AWS APIGateway, Lambda, DynamoDB in Swift

## Installation

### Swift Package Manager

Add the following packages to your swift package
```swift
// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-breeze-rest-api",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "RestAPI", targets: ["RestAPI"]),
    ],
    dependencies: [
        .package(path: "../../Breeze"),
    ],
    targets: [
        .executableTarget(
            name: "RestAPI",
             dependencies: [
                .product(name: "BreezeLambdaAPI", package: "Breeze"),
                .product(name: "BreezeDynamoDBService", package: "Breeze"),
            ]
        )
    ]
)

```

## Usage

```swift
import Foundation
import BreezeLambdaAPI
import BreezeDynamoDBService

struct Product: Codable {
    public var key: String
    public let name: String
    public let description: String
    public var createdAt: String?
    public var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case key = "sku"
        case name
        case description
        case createdAt
        case updatedAt
    }
}

extension Product: BreezeCodable { }

BreezeLambdaAPI<Product>.main()
```
