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

import AWSLambdaEvents
import AWSLambdaRuntime
import BreezeDynamoDBService
import Logging

struct BreezeLambdaHandler<T: BreezeCodable> {
    typealias Event = APIGatewayV2Request
    typealias Output = APIGatewayV2Response

    let service: BreezeDynamoDBServing
    let operation: BreezeOperation

    var keyName: String {
        self.service.keyName
    }

    func handle(context: AWSLambdaRuntimeCore.LambdaContext, event: APIGatewayV2Request) async -> APIGatewayV2Response {
        switch self.operation {
        case .create:
            return await self.createLambdaHandler(context: context, event: event)
        case .read:
            return await self.readLambdaHandler(context: context, event: event)
        case .update:
            return await self.updateLambdaHandler(context: context, event: event)
        case .delete:
            return await self.deleteLambdaHandler(context: context, event: event)
        case .list:
            return await self.listLambdaHandler(context: context, event: event)
        }
    }

    func createLambdaHandler(context: AWSLambdaRuntimeCore.LambdaContext, event: APIGatewayV2Request) async -> APIGatewayV2Response {
        guard let item: T = try? event.bodyObject() else {
            let error = BreezeLambdaAPIError.invalidRequest
            return APIGatewayV2Response(with: error, statusCode: .forbidden)
        }
        do {
            let result: T = try await service.createItem(item: item)
            return APIGatewayV2Response(with: result, statusCode: .created)
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .forbidden)
        }
    }

    func readLambdaHandler(context: AWSLambdaRuntimeCore.LambdaContext, event: APIGatewayV2Request) async -> APIGatewayV2Response {
        guard let key = event.pathParameters?[keyName] else {
            let error = BreezeLambdaAPIError.invalidRequest
            return APIGatewayV2Response(with: error, statusCode: .forbidden)
        }
        do {
            let result: T = try await service.readItem(key: key)
            return APIGatewayV2Response(with: result, statusCode: .ok)
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .notFound)
        }
    }

    func updateLambdaHandler(context: AWSLambdaRuntimeCore.LambdaContext, event: APIGatewayV2Request) async -> APIGatewayV2Response {
        guard let item: T = try? event.bodyObject() else {
            let error = BreezeLambdaAPIError.invalidRequest
            return APIGatewayV2Response(with: error, statusCode: .forbidden)
        }
        do {
            let result: T = try await service.updateItem(item: item)
            return APIGatewayV2Response(with: result, statusCode: .ok)
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .notFound)
        }
    }
    
    struct SimpleItem: BreezeCodable {
        var key: String
        var createdAt: String?
        var updatedAt: String?
    }

    func deleteLambdaHandler(context: AWSLambdaRuntimeCore.LambdaContext, event: APIGatewayV2Request) async -> APIGatewayV2Response {
        guard let key = event.pathParameters?[keyName],
              let createdAt = event.queryStringParameters?["createdAt"],
              let updatedAt = event.queryStringParameters?["updatedAt"] else {
            let error = BreezeLambdaAPIError.invalidRequest
            return APIGatewayV2Response(with: error, statusCode: .forbidden)
        }
        do {
            let simpleItem = SimpleItem(key: key, createdAt: createdAt, updatedAt: updatedAt)
            try await self.service.deleteItem(item: simpleItem)
            return APIGatewayV2Response(with: BreezeEmptyResponse(), statusCode: .ok)
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .notFound)
        }
    }

    func listLambdaHandler(context: AWSLambdaRuntimeCore.LambdaContext, event: APIGatewayV2Request) async -> APIGatewayV2Response {
        do {
            let key = event.queryStringParameters?["exclusiveStartKey"]
            let limit: Int? = event.queryStringParameter("limit")
            let result: ListResponse<T> = try await service.listItems(key: key, limit: limit)
            return APIGatewayV2Response(with: result, statusCode: .ok)
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .forbidden)
        }
    }
}
