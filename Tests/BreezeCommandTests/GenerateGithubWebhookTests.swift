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

class GenerateGithubWebhookTests: XCTestCase {
    
    let targetPath = ".build/temp"
    let subcommand = "generate-github-webhook"

    func test_generateGithubWebhook_run_whenParametersAreSet_thenSuccess() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFileGithubWebhook).path
        let output = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite -y")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let serverlessConfig = try loadServerlessConfig(targetPath: targetPath, fileName: "serverless")
        try assertServerlessConfig(serverlessConfig: serverlessConfig, runtime: .providedAl2, architecture: .arm64)
        
        let serverlessConfigX86 = try loadServerlessConfig(targetPath: targetPath, fileName: "serverless-x86_64")
        try assertServerlessConfig(serverlessConfig: serverlessConfigX86, runtime: .providedAl2, architecture: .x86_64)
    }
    
    func test_generateGithubWebhook_run_whenParametersAreSetAndForceOverrideIsFalse_thenErrorOnSecondRun() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFileGithubWebhook).path
        let output = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite -y")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let outputWithoutForce = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(outputWithoutForce.contains("Error: TargetPath \(targetPath) cannot be overwritten"))
    }
    
    func assertServerlessConfig(serverlessConfig: ServerlessConfig, runtime: Runtime, architecture: Architecture) throws {
        XCTAssertEqual(serverlessConfig.service, "swift-breeze-github-webhook")
        XCTAssertEqual(serverlessConfig.provider.architecture, architecture)
        XCTAssertEqual(serverlessConfig.provider.name, .aws)
        XCTAssertEqual(serverlessConfig.provider.region, .us_east_1)
        XCTAssertEqual(serverlessConfig.provider.disableRollback, false)
        XCTAssertEqual(serverlessConfig.provider.runtime, runtime)
        XCTAssertEqual(serverlessConfig.provider.httpAPI?.payload, "2.0")
        XCTAssertEqual(serverlessConfig.provider.httpAPI?.cors, false)
        XCTAssertNotNil(serverlessConfig.provider.iam)
        let githubWebHook = try XCTUnwrap(serverlessConfig.functions?["githubWebHook"])
        XCTAssertEqual(githubWebHook.handler, "github-webhook")
        XCTAssertEqual(githubWebHook.memorySize, 256)
        XCTAssertEqual(githubWebHook.environment?.dictionary?["WEBHOOK_SECRET"], .string("${ssm:/dev/swift-webhook/webhook_secret}"))
        XCTAssertEqual(githubWebHook.events.first?.httpAPI?.path, "/github-webhook")
        XCTAssertEqual(githubWebHook.events.first?.httpAPI?.method, .post)
        XCTAssertNil(githubWebHook.events.first?.httpAPI?.authorizer)
    }
}
