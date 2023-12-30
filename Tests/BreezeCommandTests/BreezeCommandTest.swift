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

class BreezeCommandTest: XCTestCase {
    
    let targetPath = ".build/temp"
    
    func givenRunBreeze(subcommand: String, args: String) throws -> String {
        
        let command = productsDirectory.appendingPathComponent("breeze")
        let process = Process()
        process.executableURL = command
        var arguments = args.arguments
        arguments.insert(subcommand, at: 0)
        process.arguments = arguments
        let outputQueue = DispatchQueue(label: "output-queue")

        var outputData = Data()
        var errorData = Data()

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            outputQueue.async {
                outputData.append(data)
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            outputQueue.async {
                errorData.append(data)
            }
        }
        #endif
        try process.run()
        
        #if os(Linux)
        outputQueue.sync {
            outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        }
        #endif
        
        process.waitUntilExit()
    
        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
        #endif

        return outputQueue.sync {
            if process.terminationStatus != 0 {
                return String(data: errorData, encoding: .utf8) ?? ""
            }
            return String(data: outputData, encoding: .utf8) ?? ""
        }
    }

    func test_generateLambdaAPI_run_whenMissingConfigFile_thenError() throws {
        let output = try givenRunBreeze(subcommand: "generate-lambda-api", args: "")
        XCTAssertTrue(output.contains("Error: Missing expected argument '--config-file <config-file>'"))
    }
    
    func test_generateLambdaAPI_run_whenMissingTargetPath_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path
        let output = try givenRunBreeze(subcommand: "generate-lambda-api", args: "--config-file \(configFile)")
        XCTAssertTrue(output.contains("Error: Missing expected argument '--target-path <target-path>'"))
    }
    
    func test_generateLambdaAPI_run_whenEmptyConfigFile_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.emptyConfigFile).path
        let output = try givenRunBreeze(subcommand: "generate-lambda-api", args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(output.contains("Error: typeMismatch(Yams.Node.Mapping, Swift.DecodingError.Context(codingPath: [], debugDescription: \"Expected to decode Mapping but found Node instead.\", underlyingError: nil))"))
    }
    
    func test_generateLambdaAPI_run_whenInvalidConfigFile_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.invalidConfigFile).path
        let output = try givenRunBreeze(subcommand: "generate-lambda-api", args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(output.contains("Error: keyNotFound(CodingKeys(stringValue: \"itemCodable\", intValue: nil)"))
    }

    
    func test_generateLambdaAPI_run_whenParametersAreSet_thenSuccess() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path
        let output = try givenRunBreeze(subcommand: "generate-lambda-api", args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite -y")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let serverlessConfig = try loadServerlessConfig(targetPath: targetPath, fileName: "serverless")
        try assertServerlessConfig(serverlessConfig: serverlessConfig, runtime: .providedAl2, architecture: .arm64)
        
        let serverlessConfigX86 = try loadServerlessConfig(targetPath: targetPath, fileName: "serverless-x86_64")
        try assertServerlessConfig(serverlessConfig: serverlessConfigX86, runtime: .provided, architecture: .x86_64)
    }
    
    func test_generateLambdaAPI_run_whenParametersAreSet_andSignInWithAppleConfig_thenSuccess() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFileSignInWithApple).path
        let output = try givenRunBreeze(subcommand: "generate-lambda-api", args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite -y")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let serverlessConfig = try loadServerlessConfig(targetPath: targetPath, fileName: "serverless")
        try assertServerlessConfigWithJWT(serverlessConfig: serverlessConfig, runtime: .providedAl2, architecture: .arm64)
        
        let serverlessConfigX86 = try loadServerlessConfig(targetPath: targetPath, fileName: "serverless-x86_64")
        try assertServerlessConfigWithJWT(serverlessConfig: serverlessConfigX86, runtime: .provided, architecture: .x86_64)
    }
    
    func test_generateLambdaAPI_run_whenParametersAreSetAndForceOverrideIsFalse_thenErrorOnSecondRun() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path
        let output = try givenRunBreeze(subcommand: "generate-lambda-api", args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite -y")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let outputWithoutForce = try givenRunBreeze(subcommand: "generate-lambda-api", args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(outputWithoutForce.contains("Error: TargetPath \(targetPath) cannot be overwritten"))
    }
    
    func loadServerlessConfig(targetPath: String, fileName: String) throws -> ServerlessConfig {
        let decoder = YAMLDecoder()
        let serverlessPath = targetPath.appending("/\(fileName).yml")
        let serverlessYML = URL(fileURLWithPath: serverlessPath)
        let data = try Data(contentsOf: serverlessYML)
        return try decoder.decode(ServerlessConfig.self, from: data)
    }
    
    func assertServerlessConfig(serverlessConfig: ServerlessConfig, runtime: Runtime, architecture: Architecture) throws {
        XCTAssertEqual(serverlessConfig.service, "swift-breeze-rest-item-api")
        XCTAssertEqual(serverlessConfig.provider.architecture, architecture)
        XCTAssertEqual(serverlessConfig.provider.name, .aws)
        XCTAssertEqual(serverlessConfig.provider.region, .us_east_1)
        XCTAssertEqual(serverlessConfig.provider.disableRollback, false)
        XCTAssertEqual(serverlessConfig.provider.runtime, runtime)
        XCTAssertEqual(serverlessConfig.provider.httpAPI?.payload, "2.0")
        XCTAssertEqual(serverlessConfig.provider.httpAPI?.cors, false)
        XCTAssertNil(serverlessConfig.provider.httpAPI?.authorizers)
        XCTAssertEqual(serverlessConfig.provider.environment?.dictionary?["DYNAMO_DB_TABLE_NAME"], .string("${self:custom.tableName}"))
        XCTAssertEqual(serverlessConfig.provider.environment?.dictionary?["DYNAMO_DB_KEY"], .string("${self:custom.keyName}"))
        XCTAssertNotNil(serverlessConfig.provider.iam)
        XCTAssertEqual(serverlessConfig.package?.artifact, "build/ItemAPI/ItemAPI.zip")
        XCTAssertEqual(serverlessConfig.custom?.dictionary?["tableName"], .string("items-table-${sls:stage}"))
        XCTAssertEqual(serverlessConfig.custom?.dictionary?["keyName"], .string("itemKey"))
        let createItemAPI = try XCTUnwrap(serverlessConfig.functions?["createItemAPI"])
        XCTAssertEqual(createItemAPI.handler, "create")
        XCTAssertEqual(createItemAPI.memorySize, 256)
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.path, "/items")
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.method, .post)
        XCTAssertNil(createItemAPI.events.first?.httpAPI?.authorizer)
        let readItemAPI = try XCTUnwrap(serverlessConfig.functions?["readItemAPI"])
        XCTAssertEqual(readItemAPI.handler, "read")
        XCTAssertEqual(readItemAPI.memorySize, 256)
        XCTAssertEqual(readItemAPI.events.first?.httpAPI?.path, "/items/{itemKey}")
        XCTAssertEqual(readItemAPI.events.first?.httpAPI?.method, .get)
        XCTAssertNil(readItemAPI.events.first?.httpAPI?.authorizer)
        let updateItemAPI = try XCTUnwrap(serverlessConfig.functions?["updateItemAPI"])
        XCTAssertEqual(updateItemAPI.handler, "update")
        XCTAssertEqual(updateItemAPI.memorySize, 256)
        XCTAssertEqual(updateItemAPI.events.first?.httpAPI?.path, "/items")
        XCTAssertEqual(updateItemAPI.events.first?.httpAPI?.method, .put)
        XCTAssertNil(updateItemAPI.events.first?.httpAPI?.authorizer)
        let deleteItemAPI = try XCTUnwrap(serverlessConfig.functions?["deleteItemAPI"])
        XCTAssertEqual(deleteItemAPI.handler, "delete")
        XCTAssertEqual(deleteItemAPI.memorySize, 256)
        XCTAssertEqual(deleteItemAPI.events.first?.httpAPI?.path, "/items/{itemKey}")
        XCTAssertEqual(deleteItemAPI.events.first?.httpAPI?.method, .delete)
        XCTAssertNil(deleteItemAPI.events.first?.httpAPI?.authorizer)
        let listItemAPI = try XCTUnwrap(serverlessConfig.functions?["listItemAPI"])
        XCTAssertEqual(listItemAPI.handler, "list")
        XCTAssertEqual(listItemAPI.memorySize, 256)
        XCTAssertEqual(listItemAPI.events.first?.httpAPI?.path, "/items")
        XCTAssertEqual(listItemAPI.events.first?.httpAPI?.method, .get)
        XCTAssertNil(listItemAPI.events.first?.httpAPI?.authorizer)
        
        let resources = try XCTUnwrap(serverlessConfig.resources?.dictionary?["Resources"])
        let itemAPITable = try XCTUnwrap(resources.dictionary?["ItemAPITable"])
        let properties = try XCTUnwrap(itemAPITable.dictionary?["Properties"])
        let type = try XCTUnwrap(itemAPITable.dictionary?["Type"])
        let tableName = try XCTUnwrap(properties.dictionary?["TableName"])
        let keySchema = try XCTUnwrap(properties.dictionary?["KeySchema"])
        let billingMode = try XCTUnwrap(properties.dictionary?["BillingMode"])
        let attributeDefinitions = try XCTUnwrap(properties.dictionary?["AttributeDefinitions"])
        let attributeDefinition = try XCTUnwrap(attributeDefinitions.array?.first)
        XCTAssertEqual(tableName, .string("${self:custom.tableName}"))
        XCTAssertEqual(type, .string("AWS::DynamoDB::Table"))
        XCTAssertEqual(attributeDefinition.dictionary?["AttributeType"], .string("S"))
        XCTAssertEqual(attributeDefinition.dictionary?["AttributeName"], .string("${self:custom.keyName}"))
        XCTAssertEqual(keySchema.array?.first?.dictionary?["KeyType"], .string("HASH"))
        XCTAssertEqual(keySchema.array?.first?.dictionary?["AttributeName"], .string("${self:custom.keyName}"))
    }
    
    func assertServerlessConfigWithJWT(serverlessConfig: ServerlessConfig, runtime: Runtime, architecture: Architecture) throws {
        XCTAssertEqual(serverlessConfig.service, "swift-breeze-rest-item-api")
        XCTAssertEqual(serverlessConfig.provider.architecture, architecture)
        XCTAssertEqual(serverlessConfig.provider.name, .aws)
        XCTAssertEqual(serverlessConfig.provider.region, .us_east_1)
        XCTAssertEqual(serverlessConfig.provider.disableRollback, false)
        XCTAssertEqual(serverlessConfig.provider.runtime, runtime)
        XCTAssertEqual(serverlessConfig.provider.httpAPI?.payload, "2.0")
        XCTAssertEqual(serverlessConfig.provider.httpAPI?.cors, false)
        let autorizers = try XCTUnwrap(serverlessConfig.provider.httpAPI?.authorizers?.dictionary?["appleJWT"])
        XCTAssertEqual(autorizers.dictionary?["identitySource"], .string("$request.header.Authorization"))
        XCTAssertEqual(autorizers.dictionary?["issuerUrl"], .string("https://appleid.apple.com"))
        XCTAssertEqual(autorizers.dictionary?["audience"]?.array?.first, .string("APP_BUNDLE_IDENTIFIER"))
        XCTAssertEqual(serverlessConfig.provider.environment?.dictionary?["DYNAMO_DB_TABLE_NAME"], .string("${self:custom.tableName}"))
        XCTAssertEqual(serverlessConfig.provider.environment?.dictionary?["DYNAMO_DB_KEY"], .string("${self:custom.keyName}"))
        XCTAssertNotNil(serverlessConfig.provider.iam)
        XCTAssertEqual(serverlessConfig.package?.artifact, "build/ItemAPI/ItemAPI.zip")
        XCTAssertEqual(serverlessConfig.custom?.dictionary?["tableName"], .string("items-table-${sls:stage}"))
        XCTAssertEqual(serverlessConfig.custom?.dictionary?["keyName"], .string("itemKey"))
        let createItemAPI = try XCTUnwrap(serverlessConfig.functions?["createItemAPI"])
        XCTAssertEqual(createItemAPI.handler, "create")
        XCTAssertEqual(createItemAPI.memorySize, 256)
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.path, "/items")
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.method, .post)
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.authorizer?.dictionary?["name"], .string("appleJWT"))
        let readItemAPI = try XCTUnwrap(serverlessConfig.functions?["readItemAPI"])
        XCTAssertEqual(readItemAPI.handler, "read")
        XCTAssertEqual(readItemAPI.memorySize, 256)
        XCTAssertEqual(readItemAPI.events.first?.httpAPI?.path, "/items/{itemKey}")
        XCTAssertEqual(readItemAPI.events.first?.httpAPI?.method, .get)
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.authorizer?.dictionary?["name"], .string("appleJWT"))
        let updateItemAPI = try XCTUnwrap(serverlessConfig.functions?["updateItemAPI"])
        XCTAssertEqual(updateItemAPI.handler, "update")
        XCTAssertEqual(updateItemAPI.memorySize, 256)
        XCTAssertEqual(updateItemAPI.events.first?.httpAPI?.path, "/items")
        XCTAssertEqual(updateItemAPI.events.first?.httpAPI?.method, .put)
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.authorizer?.dictionary?["name"], .string("appleJWT"))
        let deleteItemAPI = try XCTUnwrap(serverlessConfig.functions?["deleteItemAPI"])
        XCTAssertEqual(deleteItemAPI.handler, "delete")
        XCTAssertEqual(deleteItemAPI.memorySize, 256)
        XCTAssertEqual(deleteItemAPI.events.first?.httpAPI?.path, "/items/{itemKey}")
        XCTAssertEqual(deleteItemAPI.events.first?.httpAPI?.method, .delete)
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.authorizer?.dictionary?["name"], .string("appleJWT"))
        let listItemAPI = try XCTUnwrap(serverlessConfig.functions?["listItemAPI"])
        XCTAssertEqual(listItemAPI.handler, "list")
        XCTAssertEqual(listItemAPI.memorySize, 256)
        XCTAssertEqual(listItemAPI.events.first?.httpAPI?.path, "/items")
        XCTAssertEqual(listItemAPI.events.first?.httpAPI?.method, .get)
        XCTAssertEqual(createItemAPI.events.first?.httpAPI?.authorizer?.dictionary?["name"], .string("appleJWT"))
        
        let resources = try XCTUnwrap(serverlessConfig.resources?.dictionary?["Resources"])
        let itemAPITable = try XCTUnwrap(resources.dictionary?["ItemAPITable"])
        let properties = try XCTUnwrap(itemAPITable.dictionary?["Properties"])
        let type = try XCTUnwrap(itemAPITable.dictionary?["Type"])
        let tableName = try XCTUnwrap(properties.dictionary?["TableName"])
        let keySchema = try XCTUnwrap(properties.dictionary?["KeySchema"])
        let billingMode = try XCTUnwrap(properties.dictionary?["BillingMode"])
        let attributeDefinitions = try XCTUnwrap(properties.dictionary?["AttributeDefinitions"])
        let attributeDefinition = try XCTUnwrap(attributeDefinitions.array?.first)
        XCTAssertEqual(tableName, .string("${self:custom.tableName}"))
        XCTAssertEqual(type, .string("AWS::DynamoDB::Table"))
        XCTAssertEqual(attributeDefinition.dictionary?["AttributeType"], .string("S"))
        XCTAssertEqual(attributeDefinition.dictionary?["AttributeName"], .string("${self:custom.keyName}"))
        XCTAssertEqual(keySchema.array?.first?.dictionary?["KeyType"], .string("HASH"))
        XCTAssertEqual(keySchema.array?.first?.dictionary?["AttributeName"], .string("${self:custom.keyName}"))
    }
    
    var productsDirectory: URL {
#if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
#else
    return Bundle.main.bundleURL
#endif
    }
    
}

extension String {
    fileprivate var arguments: [String] {
        split(separator: " ").map { String($0) }
    }
}
