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
        try super.setUpWithError()
        setEnvironmentVar(name: "LOCAL_LAMBDA_SERVER_ENABLED", value: "true", overwrite: true)
        setEnvironmentVar(name: "AWS_REGION", value: "eu-west-1", overwrite: true)
        setEnvironmentVar(name: "DYNAMO_DB_TABLE_NAME", value: "product-table", overwrite: true)
        setEnvironmentVar(name: "DYNAMO_DB_KEY", value: "sku", overwrite: true)
        LambdaInitializationContext.DynamoDB.Service = BreezeDynamoDBServiceMock.self
        LambdaInitializationContext.DynamoDB.dbTimeout = 1
    }

    override func tearDownWithError() throws {
        unsetenv("LOCAL_LAMBDA_SERVER_ENABLED")
        unsetenv("AWS_REGION")
        unsetenv("DYNAMO_DB_TABLE_NAME")
        unsetenv("DYNAMO_DB_KEY")
        unsetenv("_HANDLER")
        LambdaInitializationContext.DynamoDB.Service = BreezeDynamoDBService.self
        LambdaInitializationContext.DynamoDB.dbTimeout = 30
        BreezeDynamoDBServiceMock.reset()
        try super.tearDownWithError()
    }
    
    func test_initWhenMissing_AWS_REGION_thenDefaultRegion() async throws {
        unsetenv("AWS_REGION")
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.create", overwrite: true)
        BreezeDynamoDBServiceMock.response = Fixtures.product2023
        let createRequest = try Fixtures.fixture(name: Fixtures.postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        _ = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
    }

    func test_initWhenMissing__HANDLER_thenThrowError() async throws {
        BreezeDynamoDBServiceMock.response = Fixtures.product2023
        let createRequest = try Fixtures.fixture(name: Fixtures.postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        do {
            _ = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
            XCTFail("It should throw an Error when _HANDLER is missing")
        } catch BreezeLambdaAPIError.invalidHandler {
            XCTAssert(true)
        } catch {
            XCTFail("Is should throw an BreezeLambdaAPIError.invalidHandler")
        }
    }
    
    func test_initWhenInvalid__HANDLER_thenThrowError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.c", overwrite: true)
        BreezeDynamoDBServiceMock.response = Fixtures.product2023
        let createRequest = try Fixtures.fixture(name: Fixtures.postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        do {
            _ = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
            XCTFail("It should throw an Error when _HANDLER is invalid")
        } catch BreezeLambdaAPIError.invalidHandler {
            XCTAssert(true)
        } catch {
            XCTFail("Is should throw an BreezeLambdaAPIError.invalidHandler")
        }
    }
    
    func test_initWhenMissing_DYNAMO_DB_TABLE_NAME_thenThrowError() async throws {
        unsetenv("DYNAMO_DB_TABLE_NAME")
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.create", overwrite: true)
        BreezeDynamoDBServiceMock.response = Fixtures.product2023
        let createRequest = try Fixtures.fixture(name: Fixtures.postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        do {
            _ = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
            XCTFail("It should throw an Error when DYNAMO_DB_TABLE_NAME is missing")
        } catch BreezeLambdaAPIError.tableNameNotFound {
            XCTAssert(true)
        } catch {
            XCTFail("Is should throw an BreezeLambdaAPIError.tableNameNotFound")
        }
    }
    
    func test_initWhenMissing_DYNAMO_DB_KEY_thenThrowError() async throws {
        unsetenv("DYNAMO_DB_KEY")
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.create", overwrite: true)
        BreezeDynamoDBServiceMock.response = Fixtures.product2023
        let createRequest = try Fixtures.fixture(name: Fixtures.postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        do {
            _ = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
            XCTFail("It should throw an Error when DYNAMO_DB_KEY is missing")
        } catch BreezeLambdaAPIError.keyNameNotFound {
            XCTAssert(true)
        } catch {
            XCTFail("Is should throw an BreezeLambdaAPIError.keyNameNotFound")
        }
    }
    
    func test_create() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.create", overwrite: true)
        BreezeDynamoDBServiceMock.response = Fixtures.product2023
        let createRequest = try Fixtures.fixture(name: Fixtures.postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: Product = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .created)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.key, "2023")
        XCTAssertEqual(response.name, "Swift Serverless API with async/await! 🚀🥳")
        XCTAssertEqual(response.description, "BreezeLambaAPI is magic 🪄!")
    }

    func test_create_whenInvalidItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.create", overwrite: true)
        BreezeDynamoDBServiceMock.response = nil
        let createRequest = try Fixtures.fixture(name: Fixtures.postInvalidRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .forbidden)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }
    
    func test_create_whenMissingItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.create", overwrite: true)
        BreezeDynamoDBServiceMock.response = nil
        let createRequest = try Fixtures.fixture(name: Fixtures.postProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .forbidden)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_read() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.read", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2023
        let readRequest = try Fixtures.fixture(name: Fixtures.getProductsSkuRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: readRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: Product = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .ok)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.key, "2023")
        XCTAssertEqual(response.name, "Swift Serverless API with async/await! 🚀🥳")
        XCTAssertEqual(response.description, "BreezeLambaAPI is magic 🪄!")
    }
    
    func test_read_whenInvalidRequest_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.read", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2023
        let readRequest = try Fixtures.fixture(name: Fixtures.getInvalidRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: readRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .forbidden)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_read_whenMissingItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.read", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2022
        let readRequest = try Fixtures.fixture(name: Fixtures.getProductsSkuRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: readRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .notFound)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_update() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.update", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2023
        let updateRequest = try Fixtures.fixture(name: Fixtures.putProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: updateRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: Product = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .ok)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.key, "2023")
        XCTAssertEqual(response.name, "Swift Serverless API with async/await! 🚀🥳")
        XCTAssertEqual(response.description, "BreezeLambaAPI is magic 🪄!")
    }
    
    func test_update_whenInvalidRequest_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.update", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2023
        let updateRequest = try Fixtures.fixture(name: Fixtures.getInvalidRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: updateRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .forbidden)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_update_whenMissingItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.update", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2022
        let updateRequest = try Fixtures.fixture(name: Fixtures.putProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: updateRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .notFound)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_delete() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.delete", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2023
        let deleteProductsSku = try Fixtures.fixture(name: Fixtures.deleteProductsSkuRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: deleteProductsSku)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: BreezeEmptyResponse = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .ok)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertNotNil(response)
    }
    
    func test_delete_whenInvalidRequest_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.delete", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2023
        let deleteProductsSku = try Fixtures.fixture(name: Fixtures.getInvalidRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: deleteProductsSku)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .forbidden)
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_delete_whenMissingItem_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.delete", overwrite: true)
        BreezeDynamoDBServiceMock.keyedResponse = Fixtures.product2022
        let deleteProductsSku = try Fixtures.fixture(name: Fixtures.deleteProductsSkuRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: deleteProductsSku)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .notFound)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }

    func test_list() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.list", overwrite: true)
        BreezeDynamoDBServiceMock.response = Fixtures.product2023
        let listRequest = try Fixtures.fixture(name: Fixtures.getProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: listRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: ListResponse<Product> = try apiResponse.decodeBody()
        let item = try XCTUnwrap(response.items.first)
        XCTAssertEqual(BreezeDynamoDBServiceMock.limit, 1)
        XCTAssertEqual(BreezeDynamoDBServiceMock.exclusiveKey, "2023")
        XCTAssertEqual(apiResponse.statusCode, .ok)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(item.key, "2023")
        XCTAssertEqual(item.name, "Swift Serverless API with async/await! 🚀🥳")
        XCTAssertEqual(item.description, "BreezeLambaAPI is magic 🪄!")
    }

    func test_list_whenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/Products.list", overwrite: true)
        BreezeDynamoDBServiceMock.response = nil
        let listRequest = try Fixtures.fixture(name: Fixtures.getProductsRequest, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: listRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaAPI<Product>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .forbidden)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidItem")
    }
}
