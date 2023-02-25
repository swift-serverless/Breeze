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
import BreezeLambdaAPI
import AWSLambdaEvents

struct Fixtures {
    
    // MARK: - Fixtures JSONs
    
    // create
    static let postProductsRequest = "post_products_api_gtw"
    // read
    static let getProductsSkuRequest = "get_products_sku_api_gtw"
    // update
    static let putProductsRequest = "put_products_api_gtw"
    // delete
    static let deleteProductsSkuRequest = "delete_products_sku_api_gtw"
    // list
    static let getProductsRequest = "get_products_api_gtw"

    // invalid
    static let postInvalidRequest = "post_invalid_api_gtw"
    // invalid_request
    static let getInvalidRequest = "get_invalid_api_gtw"

    // MARK: - Test Product
    static let product2022 = Product(key: "2022", name: "Swift Serverless API with async/await! 🚀🥳", description: "BreezeLambaAPI is magic 🪄!")
    static let product2023 = Product(key: "2023", name: "Swift Serverless API with async/await! 🚀🥳", description: "BreezeLambaAPI is magic 🪄!")

    // MARK: - Functions
    static func fixture(name: String, type: String) throws -> Data {
        guard let fixtureUrl = Bundle.module.url(forResource: name, withExtension: type, subdirectory: "Fixtures") else {
            throw TestError.missingFixture
        }
        return try Data(contentsOf: fixtureUrl)
    }
}
