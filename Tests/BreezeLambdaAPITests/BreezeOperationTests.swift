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

import Foundation
import XCTest
@testable import BreezeLambdaAPI

final class BreezeOperationTests: XCTestCase {
    func test_createOperation() {
        XCTAssertEqual(BreezeOperation(handler: "build/Products.create"), BreezeOperation.create)
        XCTAssertEqual(BreezeOperation(handler: "create"), BreezeOperation.create)
    }
    
    func test_readOperation() {
        XCTAssertEqual(BreezeOperation(handler: "build/Products.read"), BreezeOperation.read)
        XCTAssertEqual(BreezeOperation(handler: "read"), BreezeOperation.read)
    }
    
    func test_updateOperation() {
        XCTAssertEqual(BreezeOperation(handler: "build/Products.update"), BreezeOperation.update)
        XCTAssertEqual(BreezeOperation(handler: "update"), BreezeOperation.update)
    }
    
    func test_deleteOperation() {
        XCTAssertEqual(BreezeOperation(handler: "build/Products.delete"), BreezeOperation.delete)
        XCTAssertEqual(BreezeOperation(handler: "delete"), BreezeOperation.delete)
    }
    
    func test_listOperation() {
        XCTAssertEqual(BreezeOperation(handler: "build/Products.list"), BreezeOperation.list)
        XCTAssertEqual(BreezeOperation(handler: "list"), BreezeOperation.list)
    }
}
