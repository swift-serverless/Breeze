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

import AsyncHTTPClient
import AWSLambdaEvents
import AWSLambdaRuntimeCore
import BreezeDynamoDBService
import Foundation
import SotoDynamoDB

public extension LambdaInitializationContext {
    enum DynamoDB {
        public static var Service: BreezeDynamoDBServing.Type = BreezeDynamoDBService.self
        public static var dbTimeout: Int64 = 30
    }
}

public class BreezeLambdaAPI<T: BreezeCodable>: LambdaHandler {
    public typealias Event = APIGatewayV2Request
    public typealias Output = APIGatewayV2Response

    let dbTimeout: Int64
    let region: Region
    let db: SotoDynamoDB.DynamoDB
    let service: BreezeDynamoDBServing
    let tableName: String
    let keyName: String
    let operation: BreezeOperation
    var httpClient: HTTPClient

    static func currentRegion() -> Region {
        if let awsRegion = Lambda.env("AWS_REGION") {
            let value = Region(rawValue: awsRegion)
            return value
        } else {
            return .useast1
        }
    }

    static func tableName() throws -> String {
        guard let tableName = Lambda.env("DYNAMO_DB_TABLE_NAME") else {
            throw BreezeLambdaAPIError.tableNameNotFound
        }
        return tableName
    }

    static func keyName() throws -> String {
        guard let tableName = Lambda.env("DYNAMO_DB_KEY") else {
            throw BreezeLambdaAPIError.keyNameNotFound
        }
        return tableName
    }

    public required init(context: LambdaInitializationContext) async throws {
        guard let handler = Lambda.env("_HANDLER"),
              let operation = BreezeOperation(handler: handler)
        else {
            throw BreezeLambdaAPIError.invalidHandler
        }
        self.operation = operation
        context.logger.info("operation: \(operation)")
        self.region = Self.currentRegion()
        context.logger.info("region: \(region)")
        self.dbTimeout = LambdaInitializationContext.DynamoDB.dbTimeout
        context.logger.info("dbTimeout: \(dbTimeout)")
        self.tableName = try Self.tableName()
        context.logger.info("tableName: \(tableName)")
        self.keyName = try Self.keyName()
        context.logger.info("keyName: \(keyName)")

        let lambdaRuntimeTimeout: TimeAmount = .seconds(dbTimeout)
        let timeout = HTTPClient.Configuration.Timeout(
            connect: lambdaRuntimeTimeout,
            read: lambdaRuntimeTimeout
        )

        let configuration = HTTPClient.Configuration(timeout: timeout)
        self.httpClient = HTTPClient(
            eventLoopGroupProvider: .shared(context.eventLoop),
            configuration: configuration
        )

        let awsClient = AWSClient(httpClientProvider: .shared(self.httpClient))
        self.db = SotoDynamoDB.DynamoDB(client: awsClient, region: self.region)

        self.service = LambdaInitializationContext.DynamoDB.Service.init(
            db: self.db,
            tableName: self.tableName,
            keyName: self.keyName
        )

        context.terminator.register(name: "shutdown") { eventLoop in
            context.logger.info("shutdown: started")
            let promise = eventLoop.makePromise(of: Void.self)
            Task {
                do {
                    try awsClient.syncShutdown()
                    try await self.httpClient.shutdown()
                    promise.succeed()
                    context.logger.info("shutdown: succeed")
                } catch {
                    promise.fail(error)
                    context.logger.info("shutdown: fail")
                }
            }
            return promise.futureResult
        }
    }

    public func handle(_ event: AWSLambdaEvents.APIGatewayV2Request, context: AWSLambdaRuntimeCore.LambdaContext) async throws -> AWSLambdaEvents.APIGatewayV2Response {
        return await BreezeLambdaHandler<T>(service: self.service, operation: self.operation).handle(context: context, event: event)
    }
}
