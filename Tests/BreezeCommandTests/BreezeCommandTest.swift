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

class BreezeCommandTest: XCTestCase {
    
    let targetPath = ".build/temp"
    
    func givenRunBreeze(args: String) throws -> String {
        
        let command = productsDirectory.appendingPathComponent("breeze")
        let process = Process()
        process.executableURL = command
        process.arguments = args.arguments
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

    func test_run_whenMissingConfigFile_thenError() throws {
        let output = try givenRunBreeze(args: "")
        XCTAssertTrue(output.contains("Error: Missing expected argument '--config-file <config-file>'"))
    }
    
    func test_run_whenMissingTargetPath_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path
        let output = try givenRunBreeze(args: "--config-file \(configFile)")
        XCTAssertTrue(output.contains("Error: Missing expected argument '--target-path <target-path>'"))
    }
    
    func test_run_whenEmptyConfigFile_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.emptyConfigFile).path
        let output = try givenRunBreeze(args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(output.contains("Error: typeMismatch(Yams.Node.Mapping, Swift.DecodingError.Context(codingPath: [], debugDescription: \"Expected to decode Mapping but found Node instead.\", underlyingError: nil))"))
    }
    
    func test_run_whenInvalidConfigFile_thenError() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.invalidConfigFile).path
        let output = try givenRunBreeze(args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(output.contains("Error: keyNotFound(CodingKeys(stringValue: \"itemCodable\", intValue: nil)"))
    }
    
    func test_run_whenParametersAreSet_thenSuccess() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path
        let output = try givenRunBreeze(args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite true")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
    }
    
    func test_run_whenParametersAreSetAndForceOverrideIsFalse_thenErrorOnSecondRun() throws {
        let configFile = try Fixtures.fixture(file: Fixtures.configFile).path
        let output = try givenRunBreeze(args: "--config-file \(configFile) --target-path \(targetPath) --force-overwrite true")
        XCTAssertTrue(output.contains("✅ Project is ready at target-path"))
        
        let outputWithoutForce = try givenRunBreeze(args: "--config-file \(configFile) --target-path \(targetPath)")
        XCTAssertTrue(outputWithoutForce.contains("Error: TargetPath \(targetPath) cannot be overwritten"))
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
