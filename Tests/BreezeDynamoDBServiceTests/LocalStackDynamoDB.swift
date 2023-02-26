//    Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-sprinter
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

import SotoDynamoDB
import Logging

enum LocalStackDynamoDB {
    
    static var endpoint: String = {
        if let localstack = getEnvironmentVar(name: "LOCALSTACK_ENDPOINT"),
           !localstack.isEmpty {
            return localstack
        }
        return "http://localhost:4566"
    }()

    public static var logger: Logger = {
        if let loggingLevel = getEnvironmentVar(name: "AWS_LOG_LEVEL") {
            if let logLevel = Logger.Level(rawValue: loggingLevel.lowercased()) {
                var logger = Logger(label: "breeze")
                logger.logLevel = logLevel
                return logger
            }
        }
        return AWSClient.loggingDisabled
    }()
    
    static var client = AWSClient(
        credentialProvider: .static(accessKeyId: "breeze", secretAccessKey: "magic"),
        middlewares: [AWSLoggingMiddleware()],
        httpClientProvider: .createNew
    )

    static var dynamoDB = DynamoDB(
        client: client,
        region: .useast1,
        endpoint: endpoint
    )

    static func createTable(name: String, keyName: String) async throws {
        let input = DynamoDB.CreateTableInput(
            attributeDefinitions: [.init(attributeName: keyName, attributeType: .s)],
            keySchema: [.init(attributeName: keyName, keyType: .hash)],
            provisionedThroughput: .init(readCapacityUnits: 5, writeCapacityUnits: 5),
            tableName: name
        )
        _ = try await Self.dynamoDB.createTable(input, logger: Self.logger)
        try await Self.dynamoDB.waitUntilTableExists(
            .init(tableName: name),
            logger: Self.logger
        )
    }

    static func deleteTable(name: String) async throws {
        let input = DynamoDB.DeleteTableInput(tableName: name)
        _ = try await Self.dynamoDB.deleteTable(input, logger: Self.logger)
    }
}

