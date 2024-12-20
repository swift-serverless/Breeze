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

import ArgumentParser
import Foundation
import SLSAdapter

struct GenerateLambdaAPI: ParsableCommand {
    
    @OptionGroup var options: BreezeCommand.Options
    
    mutating func run() throws {
        let fileManager = FileManager.default
        guard !options.configFile.isEmpty else {
            throw BreezeCommandError.invalidConfig
        }
        let url: URL = URL(fileURLWithPath: options.configFile)
        let config = try BreezeConfig.load(from: url)
        guard let params = config.breezeLambdaAPI else {
            print("GenerateLambdaAPI requires `breezeLambdaAPI` configuration.")
            throw BreezeCommandError.invalidConfig
        }
        
        try fileManager.cleanTargetPath(options.targetPath, remove: options.forceOverwrite, yes: options.yes)
        let context: [String : Any] = ["config" : config,
                                       "params" : params]
        try fileManager.applyStencils(
            basePath: "BreezeLambdaAPI",
            targetPath: options.targetPath,
            packageName: config.packageName,
            targetName: params.targetName,
            context: context
        )

        let serverlessConfig = try ServerlessConfig.dynamoDBLambdaAPI(
            service: config.service,
            dynamoDBKey: params.itemKey,
            dynamoDBTableNamePrefix: params.dynamoDBTableNamePrefix,
            httpAPIPath: params.httpAPIPath,
            region: Region(rawValue: config.awsRegion) ?? .us_east_1,
            authorizer: config.authorizer,
            cors: config.cors,
            runtime: .providedAl2,
            architecture: .arm64,
            memorySize: 256,
            executable: params.targetName,
            artifact: "\(config.buildPath)/\(params.targetName)/\(params.targetName).zip"
        )
        try serverlessConfig.writeSLS(targetPath: options.targetPath, ymlFileName: "serverless.yml")
        
        let serverlessConfig_x86_64 = try ServerlessConfig.dynamoDBLambdaAPI(
            service: config.service,
            dynamoDBKey: params.itemKey,
            dynamoDBTableNamePrefix: params.dynamoDBTableNamePrefix,
            httpAPIPath: params.httpAPIPath,
            region: Region(rawValue: config.awsRegion) ?? .us_east_1,
            authorizer: config.authorizer,
            cors: config.cors,
            runtime: .providedAl2,
            architecture: .x86_64,
            memorySize: 256,
            executable: params.targetName,
            artifact: "\(config.buildPath)/\(params.targetName)/\(params.targetName).zip"
        )
        try serverlessConfig_x86_64.writeSLS(targetPath: options.targetPath, ymlFileName: "serverless-x86_64.yml")
        print("")
        printTitle("✅ Project is ready at target-path")
        print("\(options.targetPath)\n")
        breeze()
        print()
        printTitle("💨 Use the following commands to build & deploy")
        print("cd \(options.targetPath)")
        print("./build.sh")
        print("./deploy.sh")
    }
}
