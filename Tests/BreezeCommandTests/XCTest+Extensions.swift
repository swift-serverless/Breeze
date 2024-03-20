//    Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-serverless
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
import XCTest
import Yams
import SLSAdapter

extension XCTestCase {
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
    
    func loadServerlessConfig(targetPath: String, fileName: String) throws -> ServerlessConfig {
        let decoder = YAMLDecoder()
        let serverlessPath = targetPath.appending("/\(fileName).yml")
        let serverlessYML = URL(fileURLWithPath: serverlessPath)
        let data = try Data(contentsOf: serverlessYML)
        return try decoder.decode(ServerlessConfig.self, from: data)
    }
}

extension String {
    fileprivate var arguments: [String] {
        split(separator: " ").map { String($0) }
    }
}
