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

public protocol BreezeDynamoDBServing {
    var keyName: String { get }
    init(db: DynamoDB, tableName: String, keyName: String)
    func createItem<Item: BreezeCodable>(item: Item) async throws -> Item
    func readItem<Item: BreezeCodable>(key: String) async throws -> Item
    func updateItem<Item: BreezeCodable>(item: Item) async throws -> Item
    func deleteItem<Item: BreezeCodable>(item: Item) async throws
    func listItems<Item: BreezeCodable>(key: String?, limit: Int?) async throws -> ListResponse<Item>
}
