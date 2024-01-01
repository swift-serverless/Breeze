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
import Yams
import SLSAdapter
import XCTest

class GenerateWebhookTests: XCTestCase {
    
    let targetPath = ".build/temp-webhook"
    let subcommand = "generate-webhook"

    func test_generateWebhook_run_whenParametersAreSet_thenSuccess() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFileWebhook).path
        let output = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite -y")
        print(output)
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let serverlessConfig = try loadServerlessConfig(targetPath: targetPath, fileName: "serverless")
        try assertServerlessConfig(serverlessConfig: serverlessConfig, runtime: .providedAl2, architecture: .arm64)
        
        let serverlessConfigX86 = try loadServerlessConfig(targetPath: targetPath, fileName: "serverless-x86_64")
        try assertServerlessConfig(serverlessConfig: serverlessConfigX86, runtime: .providedAl2, architecture: .x86_64)
    }
    
    func test_generateWebhook_run_whenParametersAreSetAndForceOverrideIsFalse_thenErrorOnSecondRun() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFileWebhook).path
        let output = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite -y")
        print(output)
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let outputWithoutForce = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(outputWithoutForce.contains("Error: TargetPath \(targetPath) cannot be overwritten"))
    }
    
    func assertServerlessConfig(serverlessConfig: ServerlessConfig, runtime: Runtime, architecture: Architecture) throws {
        XCTAssertEqual(serverlessConfig.service, "swift-breeze-webhook")
        XCTAssertEqual(serverlessConfig.provider.architecture, architecture)
        XCTAssertEqual(serverlessConfig.provider.name, .aws)
        XCTAssertEqual(serverlessConfig.provider.region, .us_east_1)
        XCTAssertEqual(serverlessConfig.provider.disableRollback, false)
        XCTAssertEqual(serverlessConfig.provider.runtime, runtime)
        XCTAssertEqual(serverlessConfig.provider.httpAPI?.payload, "2.0")
        XCTAssertEqual(serverlessConfig.provider.httpAPI?.cors, false)
        XCTAssertNotNil(serverlessConfig.provider.iam)
        let getWebHook = try XCTUnwrap(serverlessConfig.functions?["getWebHook"])
        XCTAssertEqual(getWebHook.handler, "get-webhook")
        XCTAssertEqual(getWebHook.memorySize, 256)
        XCTAssertEqual(getWebHook.events.first?.httpAPI?.path, "/webhook")
        XCTAssertEqual(getWebHook.events.first?.httpAPI?.method, .get)
        XCTAssertNil(getWebHook.events.first?.httpAPI?.authorizer)
        let postWebHook = try XCTUnwrap(serverlessConfig.functions?["postWebHook"])
        XCTAssertEqual(postWebHook.handler, "post-webhook")
        XCTAssertEqual(postWebHook.memorySize, 256)
        XCTAssertEqual(postWebHook.events.first?.httpAPI?.path, "/webhook")
        XCTAssertEqual(postWebHook.events.first?.httpAPI?.method, .post)
        XCTAssertNil(postWebHook.events.first?.httpAPI?.authorizer)
    }
}
