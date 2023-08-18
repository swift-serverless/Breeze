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
import AsyncHTTPClient
@testable import BreezeLambdaWebHook
import XCTest

final class BreezeLambdaWebHookTests: XCTestCase {

    let decoder = JSONDecoder()

    override func setUpWithError() throws {
        try super.setUpWithError()
        setEnvironmentVar(name: "LOCAL_LAMBDA_SERVER_ENABLED", value: "true", overwrite: true)
        LambdaInitializationContext.WebHook.timeout = 1
    }

    override func tearDownWithError() throws {
        unsetenv("LOCAL_LAMBDA_SERVER_ENABLED")
        unsetenv("_HANDLER")
        LambdaInitializationContext.WebHook.timeout = 30
        try super.tearDownWithError()
    }
    
    func test_postWhenMissingBody_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/webhook.get", overwrite: true)
        let createRequest = try Fixtures.fixture(name: Fixtures.getWebHook, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaWebHook<MyPostWebHook>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .badRequest)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }
    
    func test_postWhenBody_thenValue() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/webhook.post", overwrite: true)
        let createRequest = try Fixtures.fixture(name: Fixtures.postWebHook, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaWebHook<MyPostWebHook>.self, with: request)
        let response: String = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .ok)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response, "body value")
    }
    
    func test_getWhenMissingQuery_thenError() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/webhook.get", overwrite: true)
        let createRequest = try Fixtures.fixture(name: Fixtures.postWebHook, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaWebHook<MyGetWebHook>.self, with: request)
        let response: APIGatewayV2Response.BodyError = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .badRequest)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.error, "invalidRequest")
    }
    
    func test_getWhenQuery_thenValue() async throws {
        setEnvironmentVar(name: "_HANDLER", value: "build/webhook.post", overwrite: true)
        let createRequest = try Fixtures.fixture(name: Fixtures.getWebHook, type: "json")
        let request = try decoder.decode(APIGatewayV2Request.self, from: createRequest)
        let apiResponse: APIGatewayV2Response = try await Lambda.test(BreezeLambdaWebHook<MyGetWebHook>.self, with: request)
        let response: [String: String] = try apiResponse.decodeBody()
        XCTAssertEqual(apiResponse.statusCode, .ok)
        XCTAssertEqual(apiResponse.headers, [ "Content-Type": "application/json" ])
        XCTAssertEqual(response.count, 2)
    }
}
