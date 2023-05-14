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

import SotoCore
import SotoDynamoDB
import XCTest
@testable import BreezeDynamoDBService

struct Product: BreezeCodable {
    var key: String
    var name: String
    var description: String
    var createdAt: String?
    var updatedAt: String?
}

final class BreezeDynamoDBServiceTests: XCTestCase {
    
    let tableName = "Breeze"
    let keyName = "key"
    var sut: BreezeDynamoDBService!
    
    let product2023 = Product(key: "2023", name: "Swift Serverless API 2022", description: "Test")
    let product2022 = Product(key: "2022", name: "Swift Serverless API with async/await! 🚀🥳", description: "BreezeLambaAPI is magic 🪄!")
    
    override func setUp() async throws {
        try await super.setUp()
        try await LocalStackDynamoDB.createTable(name: tableName, keyName: keyName)
        let db = LocalStackDynamoDB.dynamoDB
        sut = BreezeDynamoDBService(db: db, tableName: tableName, keyName: keyName)
    }

    override func tearDown() async throws {
        sut = nil
        try await LocalStackDynamoDB.deleteTable(name: tableName)
        try await super.tearDown()
    }
    
    func test_createItem() async throws {
        let value = try await sut.createItem(item: product2023)
        XCTAssertEqual(value.key, product2023.key)
        XCTAssertEqual(value.name, product2023.name)
        XCTAssertEqual(value.description, product2023.description)
        XCTAssertNotNil(value.createdAt?.iso8601)
        XCTAssertNotNil(value.updatedAt?.iso8601)
    }
    
    func test_createItemDuplicate_shouldThrowConditionalCheckFailedException() async throws {
        let value = try await sut.createItem(item: product2023)
        XCTAssertEqual(value.key, product2023.key)
        XCTAssertEqual(value.name, product2023.name)
        XCTAssertEqual(value.description, product2023.description)
        XCTAssertNotNil(value.createdAt?.iso8601)
        XCTAssertNotNil(value.updatedAt?.iso8601)
        do {
            _ = try await sut.createItem(item: product2023)
            XCTFail("It should throw conditionalCheckFailedException")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_readItem() async throws {
        let cretedItem = try await sut.createItem(item: product2023)
        let readedItem: Product = try await sut.readItem(key: "2023")
        XCTAssertEqual(cretedItem.key, readedItem.key)
        XCTAssertEqual(cretedItem.name, readedItem.name)
        XCTAssertEqual(cretedItem.description, readedItem.description)
        XCTAssertEqual(cretedItem.createdAt?.iso8601, readedItem.createdAt?.iso8601)
        XCTAssertEqual(cretedItem.updatedAt?.iso8601, readedItem.updatedAt?.iso8601)
    }
    
    func test_readItem_whenItemIsMissing() async throws {
        let value = try await sut.createItem(item: product2023)
        XCTAssertEqual(value.key, "2023")
        do {
            let _: Product = try await sut.readItem(key: "2022")
            XCTFail("It should throw when Item is missing")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_updateItem() async throws {
        var value = try await sut.createItem(item: product2023)
        value.name = "New Name"
        value.description = "New Description"
        let newValue = try await sut.updateItem(item: value)
        XCTAssertEqual(value.key, newValue.key)
        XCTAssertEqual(value.name, newValue.name)
        XCTAssertEqual(value.description, newValue.description)
        XCTAssertEqual(value.createdAt?.iso8601, newValue.createdAt?.iso8601)
        XCTAssertNotEqual(value.updatedAt?.iso8601, newValue.updatedAt?.iso8601)
    }
    
    func test_updateItem_whenItemHasChanged_shouldThrowConditionalCheckFailedException() async throws {
        var value = try await sut.createItem(item: product2023)
        value.name = "New Name"
        value.description = "New Description"
        let newValue = try await sut.updateItem(item: value)
        XCTAssertEqual(value.key, newValue.key)
        XCTAssertEqual(value.name, newValue.name)
        XCTAssertEqual(value.description, newValue.description)
        XCTAssertEqual(value.createdAt?.iso8601, newValue.createdAt?.iso8601)
        XCTAssertNotEqual(value.updatedAt?.iso8601, newValue.updatedAt?.iso8601)
        do {
            let _: Product = try await sut.updateItem(item: product2023)
            XCTFail("It should throw conditionalCheckFailedException")
        } catch {
            XCTAssertNotNil(error)
        }
        
        do {
            let _: Product = try await sut.updateItem(item: product2022)
            XCTFail("It should throw conditionalCheckFailedException")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_deleteItem() async throws {
        let value = try await sut.createItem(item: product2023)
        XCTAssertEqual(value.key, "2023")
        try await sut.deleteItem(item: value)
        let readedItem: Product? = try? await sut.readItem(key: "2023")
        XCTAssertNil(readedItem)
    }
    
    func test_deleteItem_whenItemIsMissing() async throws {
        let value = try await sut.createItem(item: product2023)
        XCTAssertEqual(value.key, "2023")
        try await sut.deleteItem(item: value)
    }
    
    func test_listItem() async throws {
        let value1 = try await sut.createItem(item: product2022)
        let value2 = try await sut.createItem(item: product2023)
        let list: ListResponse<Product> = try await sut.listItems(key: nil, limit: nil)
        XCTAssertEqual(list.items.count, 2)
        let keys = Set(list.items.map { $0.key })
        XCTAssertTrue(keys.contains(value1.key))
        XCTAssertTrue(keys.contains(value2.key))
    }
}
