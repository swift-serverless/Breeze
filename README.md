# Breeze

![Breeze](logo.png)

[![Swift 5.7](https://img.shields.io/badge/Swift-5.7-blue.svg)](https://swift.org/download/) 

Serverless API using AWS APIGateway, Lambda, and DynamoDB in Swift is like a breeze!

## Abstract

This package provides the code to build a Serverless REST API in Swift based on Lambda, APIGateway and DynamoDB.
Breeze implements all the Lambdas required to build a CRUD interface to persist a Swift Codable struct on DynamoDB.
Once a `Codable` is conformed to `BreezeCodable`, all you need to do for your Lambda code is to pass it to `BreezeLambdaAPI` the type placeholder.

## Lambda initialization

During the initialization, the `BreezeLambdaAPI` reads the configuration from the following `Environment` variables:
- `AWS_REGION`: AWS Region
- `_HANDLER`: The handler name specifies the CRUD operation implemented by the Lambda using the following format `{executable_name}.{BreezeOperation}`

```
enum BreezeOperation: String {
    case create
    case read
    case update
    case delete
    case list
}
```
(example: `build/RestAPI.create` where `build/RestAPI` is the executable name and `create` is the BreezeOperation).
- `DYNAMO_DB_TABLE_NAME`: DynamoDB table name.
- `DYNAMO_DB_KEY`: DynamoDB Primary Key

## APIGateway Requests and Responses

`BreezeLambdaAPI` receives an APIGateway event, extracts the relevant parameters and performs a `BreezeOperation` on `BreezeDynamoDBService`.

- `create`

Decodes a `BreezeCodable` from the `APIGatewayV2Request.body` and calls `createItem` on `BreezeDynamoDBService`.
Returns the created `BreezeCodable`.

- `read`

Gets the value of the `BreezeCodable.key` from the `APIGatewayV2Request.pathParameters` dictionary and calls `readItem` on `BreezeDynamoDBService`.
Returns the `BreezeCodable` if persisted on DynamoDB.

- `update`

Decodes a `BreezeCodable` from the `APIGatewayV2Request.body` and calls `updateItem` on `BreezeDynamoDBService`.
Returns the updated `BreezeCodable`.

- `delete`

Gets the value of the `BreezeCodable.key` from the `APIGatewayV2Request.pathParameters` dictionary and calls `deleteItem` on `BreezeDynamoDBService`.
Returns the `BreezeCodable` if persisted on DynamoDB.

- `list`

Gets the value of the `exclusiveStartKey` and `limit` from the `APIGatewayV2Request.pathParameters` dictionary and calls `listItems` on `BreezeDynamoDBService`.
Returns the `ListResponse` containing the items if persisted on DynamoDB.

```
struct ListResponse<T: Codable>: Codable {
    let items: [T]
    let lastEvaluatedKey: String?
}
```

 (See SotoDynamoDB documentation for more info [*](https://soto.codes/reference/DynamoDB.html))

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
