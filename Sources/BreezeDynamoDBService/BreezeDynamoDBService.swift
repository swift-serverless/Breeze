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

import struct Foundation.Date
import NIO
import SotoDynamoDB

public class BreezeDynamoDBService: BreezeDynamoDBServing {
    enum ServiceError: Error {
        case notFound
        case missingParameters
    }

    let db: DynamoDB
    public let keyName: String
    let tableName: String

    public required init(db: DynamoDB, tableName: String, keyName: String) {
        self.db = db
        self.tableName = tableName
        self.keyName = keyName
    }
}

public extension BreezeDynamoDBService {
    func createItem<T: BreezeCodable>(item: T) async throws -> T {
        var item = item
        let date = Date()
        item.createdAt = date.iso8601
        item.updatedAt = date.iso8601
        let input = DynamoDB.PutItemCodableInput(
            conditionExpression: "attribute_not_exists(#keyName)",
            expressionAttributeNames: ["#keyName": keyName],
            item: item,
            tableName: tableName
        )
        let _ = try await db.putItem(input)
        return try await readItem(key: item.key)
    }

    func readItem<T: BreezeCodable>(key: String) async throws -> T {
        let input = DynamoDB.GetItemInput(
            key: [keyName: DynamoDB.AttributeValue.s(key)],
            tableName: tableName
        )
        let data = try await db.getItem(input, type: T.self)
        guard let item = data.item else {
            throw ServiceError.notFound
        }
        return item
    }

    private struct AdditionalAttributes: Encodable {
        let oldUpdatedAt: String
    }
    
    func updateItem<T: BreezeCodable>(item: T) async throws -> T {
        var item = item
        let oldUpdatedAt = item.updatedAt ?? ""
        let date = Date()
        item.updatedAt = date.iso8601
        let attributes = AdditionalAttributes(oldUpdatedAt: oldUpdatedAt)
        let input = try DynamoDB.UpdateItemCodableInput(
            additionalAttributes: attributes,
            conditionExpression: "attribute_exists(#\(keyName)) AND #updatedAt = :oldUpdatedAt AND #createdAt = :createdAt",
            key: [keyName],
            tableName: tableName,
            updateItem: item
        )
        let _ = try await db.updateItem(input)
        return try await readItem(key: item.key)
    }

    func deleteItem<T: BreezeCodable>(item: T) async throws {
        guard let updatedAt = item.updatedAt,
              let createdAt = item.createdAt else {
            throw ServiceError.missingParameters
        }
        
        let input = DynamoDB.DeleteItemInput(
            conditionExpression: "#updatedAt = :updatedAt AND #createdAt = :createdAt",
            expressionAttributeNames: ["#updatedAt": "updatedAt",
                                       "#createdAt" : "createdAt"],
            expressionAttributeValues: [":updatedAt": .s(updatedAt),
                                        ":createdAt" : .s(createdAt)],
            key: [keyName: DynamoDB.AttributeValue.s(item.key)],
            tableName: tableName
        )
        let _ = try await db.deleteItem(input)
        return
    }

    func listItems<T: BreezeCodable>(key: String?, limit: Int?) async throws -> ListResponse<T> {
        var exclusiveStartKey: [String: DynamoDB.AttributeValue]?
        if let key {
            exclusiveStartKey = [keyName: DynamoDB.AttributeValue.s(key)]
        }
        let input = DynamoDB.ScanInput(
            exclusiveStartKey: exclusiveStartKey,
            limit: limit,
            tableName: tableName
        )
        let data = try await db.scan(input, type: T.self)
        if let lastEvaluatedKeyShape = data.lastEvaluatedKey?[keyName],
           case .s(let lastEvaluatedKey) = lastEvaluatedKeyShape
        {
            return ListResponse(items: data.items ?? [], lastEvaluatedKey: lastEvaluatedKey)
        } else {
            return ListResponse(items: data.items ?? [], lastEvaluatedKey: nil)
        }
    }
}
