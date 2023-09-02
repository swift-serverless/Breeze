# Breeze
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-sprinter%2FBreeze%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swift-sprinter/Breeze) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-sprinter%2FBreeze%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swift-sprinter/Breeze) ![Breeze CI](https://github.com/swift-sprinter/Breeze/actions/workflows/swift-test.yml/badge.svg) [![codecov](https://codecov.io/gh/swift-sprinter/Breeze/branch/main/graph/badge.svg?token=PJR7YGBSQ0)](https://codecov.io/gh/swift-sprinter/Breeze)

[![security status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/security?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)
[![stability status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/stability?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)
[![licensing status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/licensing?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)

![Breeze](logo.png)

Serverless API using AWS APIGateway, Lambda, and DynamoDB in Swift is like a breeze!

## Abstract

This package provides the code to build a Serverless REST API in Swift based on AWS Lambda, APIGateway and DynamoDB.

The following diagram represents the infrastructure architecture of a CRUD REST Serverless API:

![AWS Serverless Rest API](images/AWS-Serverless-REST-API.svg)

The APIGateway exposes the API interface through endpoints and converts the HTTP requests to APIGatewayV2Request events for the Lambdas.
Each Lambda receives events from the APIGateway, decodes the events to extract parameters, operates on a DynamoDB table and returns a response payload to the APIGateway. DynamoDB will be accessed through the Lambdas to persist a key-value pair representing data. 

With a single line of code, Breeze implements all the Lambdas required for the CRUD interface converting APIGatewayV2Request to an operation on a DynamoDB table and responding with APIGatewayV2Response to the APIGateway.

# Usage

## Lambda customisation

Define a `Codable` struct or class like the `Item` one's in the example and pass it to `BreezeLambdaAPI` using the type placeholder.

```swift
import Foundation
import BreezeLambdaAPI
import BreezeDynamoDBService

struct Item: Codable {
    public var key: String
    public let name: String
    public let description: String
    public var createdAt: String?
    public var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case description
        case createdAt
        case updatedAt
    }
}

extension Item: BreezeCodable { }

BreezeLambdaAPI<Item>.main()
```

It's required the `Codable` struct or class to conform to the `BreezeCodable` protocol:

```swift
public protocol BreezeCodable: Codable {
    var key: String { get set }
    var createdAt: String? { get set }
    var updatedAt: String? { get set }
}
```

The code above is the business logic required inside all the Lambdas.
All you need to do is to decide the struct conforming `BreezeCodable` to persist on DynamoDB.

Each lambda will be initialized with a specific `_HANDLER` and it will run the code to implement the required logic needed by one of the CRUD functions. The code needs to be packaged and deployed using the referenced architecture.

### Optimistic locking

Optimistic locking is a strategy to ensure that the BreezeCodable Item is not updated by another request before updating or deleting it.
The fields `updatedAt` and `createdAt` are used to implement optimistic locking.
Refer to the [DynamoDB documentation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBMapper.OptimisticLocking.html) for more details.

## Lambda package with Swift Package Manager

To package the Lambda is required to create a Swift Package using the following `Package.swift` file.

```swift
// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-breeze-item-api",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "ItemAPI", targets: ["ItemAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-sprinter/Breeze.git", from: "0.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "ItemAPI",
             dependencies: [
                .product(name: "BreezeLambdaAPI", package: "Breeze"),
                .product(name: "BreezeDynamoDBService", package: "Breeze"),
            ]
        )
    ]
)

```

To be executed on a Lambda, the package needs to be built on `AmazonLinux2` and deployed.

# Deployment Examples

The API can be deployed on AWS in multiple ways.

Refer to the [Examples/ItemAPI](Examples/ItemAPI) folder to explore a deployment example using the Serverless Framework.

# Generate the deployment with the command line

The package contains a command line tool to generate the deployment of the swift package, the `serverless.yml` file and the relevant commands to deploy the Lambda code on AWS using the Serverless Framework.

## The command line tool

```bash
swift run breeze --help
```

output:

```bash
OVERVIEW: Breeze command line

Generate the deployment of a Serverless API using Breeze.
The command generates of the swift package, the `serverless.yml` file and the relevant commands in the target path to deploy the Lambda code on AWS using the Serverless Framework.

USAGE: breeze --config-file <config-file> --target-path <target-path> [--force-overwrite] [-y]

OPTIONS:
  -c, --config-file <config-file>
                          YML configurarion file
  -t, --target-path <target-path>
                          Target path
  -f, --force-overwrite   Force target path overwrite
  -y
  -h, --help              Show help information.
```

## Configuration file

Define a configuration file with the following format:
```yml
service: swift-breeze-rest-item-api
 awsRegion: us-east-1
 swiftVersion: 5.7.3
 swiftConfiguration: release
 packageName: BreezeItemAPI
 buildPath: build
 cors: false
 authorizer: #optional
         name: appleJWT
         type: JWTAuthorizer
         issuerUrl: https://appleid.apple.com
         audience:
             - APP_BUNDLE_IDENTIFIER #Change this with the App BUNDLE_IDENTIFIER
 breezeLambdaAPI:
     targetName: ItemAPI
     itemCodable: Item
     itemKey: itemKey
     httpAPIPath: /items
     dynamoDBTableNamePrefix: items
```

Configuration parameters:
- `awsRegion`: AWS Region
- `swiftVersion`: Swift version
- `swiftConfiguration`: Swift configuration (debug or release)
- `packageName`: Swift Package name
- `buildPath`: Swift Package build path where the Lambda executable will be generated
- `cors`: Enable CORS (default: false)
- `authorizer`: Optional. If defined, the API will be protected by the specified authorizer. The authorizer can be a custom one or a predefined one. `APP_BUNDLE_IDENTIFIER` is the App Bundle Identifier of the iOS App that will use the API.
If you don't want to use a custom authorizer, remove the `authorizer` section.
- `breezeLambdaAPI`: Breeze Lambda API configuration
    - `targetName`: The name of the target that will be generated by the Swift Package Manager
    - `itemCodable`: The name of the `Codable` struct or class that will be persisted on DynamoDB
    - `itemKey`: The name of the key of the `Codable` struct or class that will be persisted on DynamoDB
    - `httpAPIPath`: The path of the API
    - `dynamoDBTableNamePrefix`: The prefix of the DynamoDB table name


## Run the command line tool:

The following command will run using the example configuration file and generate the deployment files in the `.build/temp` folder.

```bash
swift run breeze -c Sources/BreezeCommand/Resources/breeze.yml -t .build/temp
```

output:

```bash
⚙️ Loading configuration file

/Users/andreascuderi/Documents/workspace/Breeze/Sources/BreezeCommand/Resources/breeze.yml

service: swift-breeze-rest-item-api
awsRegion: us-east-1
swiftVersion: 5.7.3
swiftConfiguration: release
packageName: BreezeItemAPI
buildPath: build
cors: false
breezeLambdaAPI:
    targetName: ItemAPI
    itemCodable: Item
    itemKey: itemKey
    httpAPIPath: /items
    dynamoDBTableNamePrefix: items

🔎 Verifing target path

🧹 .build/temp

✅ Target path ready!

📁 Generating project from template

📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/SwiftPackage/Package.swift
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/SwiftPackage/Sources/SwiftTarget/main.swift
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/Dockerfile
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/remove.sh
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/.gitignore
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/deploy.sh
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/update.sh
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/Makefile
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/README.md
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/build.sh
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/swagger.json
🛫 .build/temp/SwiftPackage/Sources/SwiftTarget
🛬 .build/temp/SwiftPackage/Sources/ItemAPI
🛫 .build/temp/SwiftPackage
🛬 .build/temp/BreezeItemAPI
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/serverless.yml
📄 /Users/andreascuderi/Documents/workspace/Breeze/.build/temp/serverless-x86_64.yml

✅ Project is ready at target-path

.build/temp

🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵
🎵💨💨💨💨💨💨🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵
🎵💨🎵🎵🎵🎵🎵💨🎵💨💨💨💨💨🎵🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵
🎵💨🎵🎵🎵🎵🎵💨🎵💨🎵🎵🎵🎵💨🎵💨🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵💨🎵🎵💨🎵🎵🎵🎵🎵🎵
🎵💨💨💨💨💨💨🎵🎵💨🎵🎵🎵🎵💨🎵💨💨💨💨💨🎵🎵💨💨💨💨💨🎵🎵🎵🎵🎵💨🎵🎵🎵💨💨💨💨💨🎵🎵
🎵💨🎵🎵🎵🎵🎵💨🎵💨💨💨💨💨🎵🎵💨🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵
🎵💨🎵🎵🎵🎵🎵💨🎵💨🎵🎵🎵💨🎵🎵💨🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵
🎵💨💨💨💨💨💨🎵🎵💨🎵🎵🎵🎵💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵
🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵

💨 Use the following commands to build & deploy

cd .build/temp
./build.sh
./deploy.sh
```

Follow the instructions to build and deploy the project. For more information about the deployment, please refer to the generated `README.md` file.

# Implementation Specs

## Lambda initialization

During the Lambda's initialization, the `BreezeLambdaAPI` reads the configuration from the following `Environment` variables:
- `AWS_REGION`: AWS Region
- `_HANDLER`: The handler name specifies the CRUD operation implemented by the Lambda using the following format `{executable_name}.{BreezeOperation}` or `{BreezeOperation}`

```swift
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

Gets the value of the `BreezeCodable.key` from the `APIGatewayV2Request.pathParameters` dictionary, the value of `updatedAt` and `createdAt` from `APIGatewayV2Request.queryStringParameters` dictionary and calls `deleteItem` on `BreezeDynamoDBService`.
Returns the `BreezeCodable` if persisted on DynamoDB.

- `list`

Gets the value of the `exclusiveStartKey` and `limit` from the `APIGatewayV2Request.queryStringParameters` dictionary and calls `listItems` on `BreezeDynamoDBService`.
Returns the `ListResponse` containing the items if persisted on DynamoDB.

```swift
struct ListResponse<T: Codable>: Codable {
    let items: [T]
    let lastEvaluatedKey: String?
}
```

 (See SotoDynamoDB documentation for more info [*](https://soto.codes/reference/DynamoDB.html))
