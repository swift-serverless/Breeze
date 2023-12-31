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

class BreezeCommandTests: XCTestCase {
    
    let targetPath = ".build/temp"
    let subcommand = "generate-lambda-api"

    func test_breezeCommand_run_whenMissingConfigFile_thenError() throws {
        let output = try givenRunBreeze(subcommand: subcommand, args: "")
        XCTAssertTrue(output.contains("Error: Missing expected argument '--config-file <config-file>'"))
    }
    
    func test_breezeCommand_run_whenMissingTargetPath_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFileLambdaAPI).path
        let output = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile)")
        XCTAssertTrue(output.contains("Error: Missing expected argument '--target-path <target-path>'"))
    }
    
    func test_breezeCommand_run_whenEmptyConfigFile_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.emptyConfigFile).path
        let output = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(output.contains("Error: typeMismatch(Yams.Node.Mapping, Swift.DecodingError.Context(codingPath: [], debugDescription: \"Expected to decode Mapping but found Node instead.\", underlyingError: nil))"))
    }
    
    func test_breezeCommand_run_whenInvalidConfigFile_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.invalidConfigFile).path
        let output = try givenRunBreeze(subcommand: subcommand, args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(output.contains("Error: keyNotFound(CodingKeys(stringValue: \"itemCodable\", intValue: nil)"))
    }
}
