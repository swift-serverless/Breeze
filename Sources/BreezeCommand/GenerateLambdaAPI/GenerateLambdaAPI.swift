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
import Noora

struct GenerateLambdaAPI: AsyncParsableCommand {
    
    @OptionGroup var options: BreezeCommand.Options
    
    mutating func run() async throws {
        let noora = Noora(theme: BreezeNoora.theme)
        noora.breezeHeader()
        
        let options = self.options
        let fileManager = FileManager.default
        
        // Load configuration
        let (config, params) = try await noora.loadConfig { updateMessage in
            guard !options.configFile.isEmpty else {
                throw BreezeCommandError.invalidConfig
            }
            let url: URL = URL(fileURLWithPath: options.configFile)
            let config = try BreezeConfig.load(from: url) { text in
                let formattedText = noora.format(text)
                print("\tfrom: \(formattedText)\n")
            }
            guard let params = config.breezeLambdaAPI else {
                noora.error("GenerateLambdaAPI requires `breezeLambdaAPI` configuration.")
                throw BreezeCommandError.invalidConfig
            }
            return (config, params)
        }
        
        // Verify target path
        try await noora.verifyTarget { progress in
            try await fileManager.cleanTargetPath(
                options.targetPath,
                remove: options.forceOverwrite,
                yes: options.yes,
                noora: noora
            )
        }
        let context: [String : Any] = ["config" : config,
                                       "params" : params]
        
        // Generate project
        try await noora.generateProject { progress in
            try await fileManager.applyStencils(
                basePath: "BreezeLambdaAPI",
                targetPath: options.targetPath,
                packageName: config.packageName,
                targetName: params.targetName,
                context: context,
                progress: progress
            )
            
            try Self.generateSLS(
                config: config,
                params: params,
                options: options,
                progress: progress
            )
        }
        
        // Success message
        noora.projectReady(targetPath: options.targetPath)
        noora.printInstructions(targetPath: options.targetPath)
    }
    
    private static func generateSLS(
        config: BreezeConfig,
        params: BreezeLambdaAPIConfig,
        options: BreezeCommand.Options,
        progress: (TerminalText) -> Void
    ) throws {
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
        try serverlessConfig.writeSLS(
            targetPath: options.targetPath,
            ymlFileName: "serverless.yml",
            progress: progress
        )
        
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
        try serverlessConfig_x86_64.writeSLS(
            targetPath: options.targetPath,
            ymlFileName: "serverless-x86_64.yml",
            progress: progress
        )
    }
}
