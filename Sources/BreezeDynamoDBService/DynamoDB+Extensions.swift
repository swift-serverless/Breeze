//    Copyright 2021 Soto project - https://github.com/soto-project/soto
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

// Note:
// Copied and adapted from soto project (https://github.com/soto-project/soto)
// This code is temporary and it will be removed once the feature will be supported by the soto project
// A contribution to soto project has been submitted throgh PR #671 https://github.com/soto-project/soto/pull/671

import SotoDynamoDB

extension DynamoDB {
    struct ConditionalUpdateItemCodableInput<T: Encodable & Sendable>: AWSEncodableShape {
        let additionalAttributeNames: [String: String]?
        let additionalAttributeValues: [String: AttributeValue]?
        let conditionExpression: String?
        let expressionAttributeNames: [String: String]?
        let key: [String]
        let returnConsumedCapacity: ReturnConsumedCapacity?
        let returnItemCollectionMetrics: ReturnItemCollectionMetrics?
        let returnValues: ReturnValue?
        let tableName: String
        let updateExpression: String?
        let updateItem: T

        init(additionalAttributeNames: [String: String]? = nil, additionalAttributeValues: [String: AttributeValue]? = nil, conditionExpression: String? = nil, expressionAttributeNames: [String: String]? = nil, key: [String], returnConsumedCapacity: ReturnConsumedCapacity? = nil, returnItemCollectionMetrics: ReturnItemCollectionMetrics? = nil, returnValues: ReturnValue? = nil, tableName: String, updateExpression: String? = nil, updateItem: T) {
            self.additionalAttributeNames = additionalAttributeNames
            self.additionalAttributeValues = additionalAttributeValues
            self.conditionExpression = conditionExpression
            self.expressionAttributeNames = expressionAttributeNames
            self.key = key
            self.returnConsumedCapacity = returnConsumedCapacity
            self.returnItemCollectionMetrics = returnItemCollectionMetrics
            self.returnValues = returnValues
            self.tableName = tableName
            self.updateExpression = updateExpression
            self.updateItem = updateItem
        }

        func createUpdateItemInput() throws -> UpdateItemInput {
            var item = try DynamoDBEncoder().encode(self.updateItem)
            var key: [String: AttributeValue] = [:]
            self.key.forEach {
                key[$0] = item[$0]!
                item[$0] = nil
            }
            let expressionAttributeNames: [String: String]
            if let names = self.expressionAttributeNames, self.updateExpression != nil {
                expressionAttributeNames = names
            } else if let additionalAttributeNames {
                let tmpAttributeNames: [String: String] = .init(item.keys.map { ("#\($0)", $0) }) { first, _ in return first }
                expressionAttributeNames = tmpAttributeNames.merging(additionalAttributeNames, uniquingKeysWith: { _, new in new })
            } else {
                expressionAttributeNames = .init(item.keys.map { ("#\($0)", $0) }) { first, _ in return first }
            }

            let expressionAttributeValues: [String: AttributeValue]
            if let additionalAttributeValues {
                let tmpExpressionAttributeValues: [String: AttributeValue] = .init(item.map { (":\($0.key)", $0.value) }) { first, _ in return first }
                expressionAttributeValues = tmpExpressionAttributeValues.merging(additionalAttributeValues, uniquingKeysWith: { _, new in new })
            } else {
                expressionAttributeValues = .init(item.map { (":\($0.key)", $0.value) }) { first, _ in return first }
            }
            let updateExpression: String
            if let inputUpdateExpression = self.updateExpression {
                updateExpression = inputUpdateExpression
            } else {
                let expressions = item.keys.map { "#\($0) = :\($0)" }
                updateExpression = "SET \(expressions.joined(separator: ","))"
            }
            return DynamoDB.UpdateItemInput(
                conditionExpression: self.conditionExpression,
                expressionAttributeNames: expressionAttributeNames,
                expressionAttributeValues: expressionAttributeValues,
                key: key,
                returnConsumedCapacity: self.returnConsumedCapacity,
                returnItemCollectionMetrics: self.returnItemCollectionMetrics,
                returnValues: self.returnValues,
                tableName: self.tableName,
                updateExpression: updateExpression
            )
        }
    }
}
