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

import ArgumentParser
import Foundation
import SLSAdapter

@main
struct BreezeCommand: ParsableCommand {

    @Option(name: .shortAndLong, help: "YML configurarion file")
    var configFile: String
    
    @Option(name: .shortAndLong, help: "Target path")
    var targetPath: String
    
    @Option(name: .shortAndLong, help: "Force target path overwrite")
    var forceOverwrite: Bool = false
    
    mutating func run() throws {
        let fileManager = FileManager.default
        guard !configFile.isEmpty else {
            throw BreezeCommandError.invalidConfig
        }
        let url: URL = URL(fileURLWithPath: configFile)
        let config = try BreezeConfig.load(from: url)
        let params = config.breezeLambdaAPI
        
        try fileManager.cleanTargetPath(targetPath, remove: forceOverwrite)
        try fileManager.applyStencils(targetPath: targetPath, config: config)
        
        let serverlessConfig = try ServerlessConfig.dynamoDBLambdaAPI(
            service: config.service,
            dynamoDBKey: params.itemKey,
            dynamoDBTableNamePrefix: params.dynamoDBTableNamePrefix,
            httpAPIPath: params.httpAPIPath,
            region: Region(rawValue: config.awsRegion) ?? .us_east_1,
            runtime: .providedAl2,
            architecture: .arm64,
            memorySize: 256,
            executable: params.targetName,
            artifact: "\(config.buildPath)/\(params.targetName)/\(params.targetName).zip"
        )
        try serverlessConfig.writeSLS(params: params, targetPath: targetPath, ymlFileName: "serverless.yml")
        
        let serverlessConfig_x86_64 = try ServerlessConfig.dynamoDBLambdaAPI(
            service: config.service,
            dynamoDBKey: params.itemKey,
            dynamoDBTableNamePrefix: params.dynamoDBTableNamePrefix,
            httpAPIPath: params.httpAPIPath,
            region: Region(rawValue: config.awsRegion) ?? .us_east_1,
            runtime: .provided,
            architecture: .x86_64,
            memorySize: 256,
            executable: params.targetName,
            artifact: "\(config.buildPath)/\(params.targetName)/\(params.targetName).zip"
        )
        try serverlessConfig_x86_64.writeSLS(params: params, targetPath: targetPath, ymlFileName: "serverless-x86_64.yml")
        print("")
        breeze()
        printTitle("✅ Project is ready at target-path")
        print("\(targetPath)")
    }
}
