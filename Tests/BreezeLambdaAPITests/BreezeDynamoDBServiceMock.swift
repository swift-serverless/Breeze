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

import BreezeDynamoDBService
@testable import BreezeLambdaAPI
import SotoDynamoDB

struct BreezeDynamoDBServiceMock: BreezeDynamoDBServing {
    var keyName: String

    static var response: (any BreezeCodable)?
    static var keyedResponse: (any BreezeCodable)?

    init(db: SotoDynamoDB.DynamoDB, tableName: String, keyName: String) {
        self.keyName = keyName
    }

    func createItem<T: BreezeCodable>(item: T) async throws -> T {
        guard let response = Self.response as? T else {
            throw BreezeLambdaAPIError.invalidRequest
        }
        return response
    }

    func readItem<T: BreezeCodable>(key: String) async throws -> T {
        guard let response = Self.keyedResponse as? T,
              response.key == key
        else {
            throw BreezeLambdaAPIError.invalidRequest
        }
        return response
    }

    func updateItem<T: BreezeCodable>(item: T) async throws -> T {
        guard let response = Self.keyedResponse as? T,
              response.key == item.key
        else {
            throw BreezeLambdaAPIError.invalidRequest
        }
        return response
    }

    func deleteItem(key: String) async throws {
        guard let response = Self.keyedResponse,
              response.key == key
        else {
            throw BreezeLambdaAPIError.invalidRequest
        }
        return
    }

    static var limit: Int?
    static var exclusiveKey: String?
    func listItems<T: BreezeCodable>(key: String?, limit: Int?) async throws -> ListResponse<T> {
        guard let response = Self.response as? T else {
            throw BreezeLambdaAPIError.invalidItem
        }
        Self.limit = limit
        Self.exclusiveKey = key
        return ListResponse(items: [response], lastEvaluatedKey: key)
    }

    static func reset() {
        Self.limit = nil
        Self.exclusiveKey = nil
        Self.response = nil
        Self.keyedResponse = nil
    }
}
