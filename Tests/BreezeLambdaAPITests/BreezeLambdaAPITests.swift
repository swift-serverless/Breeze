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
import AWSLambdaTesting
import BreezeDynamoDBService
@testable import BreezeLambdaAPI
import XCTest

final class BreezeLambdaAPITests: XCTestCase {
    let decoder = JSONDecoder()

    override func setUpWithError() throws {
        setEnvironmentVar(name: "LOCAL_LAMBDA_SERVER_ENABLED", value: "true", overwrite: true)
        setEnvironmentVar(name: "AWS_REGION", value: "eu-west-1", overwrite: true)
        setEnvironmentVar(name: "DYNAMO_DB_TABLE_NAME", value: "product-table", overwrite: true)
        setEnvironmentVar(name: "DYNAMO_DB_KEY", value: "sku", overwrite: true)
        LambdaInitializationContext.DynamoDB.Service = BreezeDynamoDBServiceMock.self
        LambdaInitializationContext.DynamoDB.dbTimeout = 1
    }

    override func tearDownWithError() throws {
        LambdaInitializationContext.DynamoDB.Service = BreezeDynamoDBService.self
        LambdaInitializationContext.DynamoDB.dbTimeout = 30
        BreezeDynamoDBServiceMock.reset()
    }

    let postProductsRequest = "post_products_api_gtw"

    let getProductsSkuRequest = "get_products_sku_api_gtw"

    let putProductsRequest = "put_products_api_gtw"

    let deleteProductsSkuRequest = "delete_products_sku_api_gtw"

    let getProductsRequest = "get_products_api_gtw"

    let product2022 = Product(key: "2022", name: "Swift Serverless API with async/await! 🚀🥳", description: "Swift Serverless API is MAGIC 🪄!")
    let product2023 = Product(key: "2023", name: "Swift Serverless API with async/await! 🚀🥳", description: "Swift Serverless API is MAGIC 🪄!")

    func test_create() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.create", overwrite: true)
        BreezeDynamoDBServiceMock.response = self.product2023
        let createRequest = try fixture(name: postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: Product = try apiResponse.decodeBody()
        XCTAssertEqual(response.key, "2023")
        XCTAssertEqual(response.name, "Swift Serverless API with async/await! 🚀🥳")
        XCTAssertEqual(response.description, "Swift Serverless API is MAGIC 🪄!")
    }

    func test_create_whenMissingItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.create", overwrite: true)
        BreezeDynamoDBServiceMock.response = nil
        let createRequest = try fixture(name: postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_read() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.read", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = self.product2023
        let readRequest = try fixture(name: getProductsSkuRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: readRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: Product = try apiResponse.decodeBody()
        XCTAssertEqual(response.key, "2023")
        XCTAssertEqual(response.name, "Swift Serverless API with async/await! 🚀🥳")
        XCTAssertEqual(response.description, "Swift Serverless API is MAGIC 🪄!")
    }

    func test_read_whenMissingItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.read", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = self.product2022
        let readRequest = try fixture(name: getProductsSkuRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: readRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_update() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.update", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = self.product2023
        let updateRequest = try fixture(name: putProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: updateRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: Product = try apiResponse.decodeBody()
        XCTAssertEqual(response.key, "2023")
        XCTAssertEqual(response.name, "Swift Serverless API with async/await! 🚀🥳")
        XCTAssertEqual(response.description, "Swift Serverless API is MAGIC 🪄!")
    }

    func test_update_whenMissingItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.update", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = self.product2022
        let updateRequest = try fixture(name: putProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: updateRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_delete() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.delete", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = self.product2023
        let deleteProductsSku = try fixture(name: deleteProductsSkuRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: deleteProductsSku)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: BreezeEmptyResponse = try apiResponse.decodeBody()
    }

    func test_delete_whenMissingItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.delete", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = self.product2022
        let deleteProductsSku = try fixture(name: deleteProductsSkuRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: deleteProductsSku)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_list() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.list", overwrite: true)
        BreezeDynamoDBServiceMock.response = self.product2023
        let listRequest = try fixture(name: getProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: listRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: ListResponse<Product> = try apiResponse.decodeBody()
        let item = try XCTUnwrap(response.items.first)
        XCTAssertEqual(item.key, "2023")
        XCTAssertEqual(item.name, "Swift Serverless API with async/await! 🚀🥳")
        XCTAssertEqual(item.description, "Swift Serverless API is MAGIC 🪄!")
    }

    func test_list_whenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.list", overwrite: true)
        BreezeDynamoDBServiceMock.response = nil
        let listRequest = try fixture(name: getProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: listRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(response.error, "invalidItem")
    }
}
