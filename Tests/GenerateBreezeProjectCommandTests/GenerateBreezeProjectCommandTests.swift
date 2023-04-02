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

import XCTest

class GenerateBreezeProjectCommandTest: XCTestCase {
    
    func givenRunWithError(arguments: String) throws -> String {
        let breezeBinary = productsDirectory.appendingPathComponent("breeze")
        let process = Process()
        process.executableURL = breezeBinary
        process.arguments = arguments.arguments
        
        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = nil
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func givenRunWithSuccess(arguments: String) throws -> String {
        let breezeBinary = productsDirectory.appendingPathComponent("breeze")
        let process = Process()
        process.executableURL = breezeBinary
        process.arguments = arguments.arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    func test_run_whenMissingConfigFile_thenError() throws {
        let output = try givenRunWithError(arguments: "")
        XCTAssertTrue(output.contains("Error: Missing expected argument '--config-file <config-file>'"))
    }
    
    func test_run_whenMissingTargetPath_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path

        let output = try givenRunWithError(arguments: "--config-file \(configFile)")
        XCTAssertTrue(output.contains("Error: Missing expected argument '--target-path <target-path>'"))
    }
    
    func test_run_whenEmptyConfigFile_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.emptyConfigFile).path
        
        let output = try givenRunWithError(arguments: "--config-file \(configFile) --target-path ./temp")
        XCTAssertTrue(output.contains("Error: typeMismatch(Yams.Node.Mapping, Swift.DecodingError.Context(codingPath: [], debugDescription: \"Expected to decode Mapping but found Node instead.\", underlyingError: nil))"))
    }
    
    func test_run_whenInvalidConfigFile_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.invalidConfigFile).path
        
        let output = try givenRunWithError(arguments: "--config-file \(configFile) --target-path ./temp")
        XCTAssertTrue(output.contains("Error: keyNotFound(CodingKeys(stringValue: \"itemCodable\", intValue: nil)"))
    }
    
    func test_run_whenParametersAreSet_thenSuccess() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path
        
        let output = try givenRunWithSuccess(arguments: "--config-file \(configFile) --target-path ./temp --force-overwrite true")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        let example = try Fixtures.example(file: "serverless.yml")
    }
    
    func test_run_whenParametersAreSetAndForceOverrideIsFalse_thenErrorOnSecondRun() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path
        
        let output = try givenRunWithSuccess(arguments: "--config-file \(configFile) --target-path ./temp --force-overwrite true")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let outputWithoutForce = try givenRunWithError(arguments: "--config-file \(configFile) --target-path ./temp")
        XCTAssertTrue(outputWithoutForce.contains("Error: TargetPath ./temp cannot be overwritten"))
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
