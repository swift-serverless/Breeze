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
import Rainbow

@main
struct BreezeCommand: ParsableCommand {
    
    struct Options: ParsableArguments {
        @Option(name: .shortAndLong, help: "YML configurarion file")
        var configFile: String
        
        @Option(name: .shortAndLong, help: "Target path")
        var targetPath: String
        
        @Flag(name: .shortAndLong, help: "Force target path overwrite")
        var forceOverwrite: Bool = false
        
        @Flag(name: .short)
        var yes: Bool = false
    }
    
    static let configuration: CommandConfiguration = CommandConfiguration(
        commandName: "breeze",
        abstract: "Breeze command line",
        discussion: "Generate the deployment of a Serverless project using Breeze.\nThe command generates of the swift package, the `serverless.yml` file and the relevant commands in the target path to deploy the Lambda code on AWS using the Serverless Framework.",
        subcommands: [
            GenerateLambdaAPI.self,
            GenerateGithubWebhook.self,
            GenerateWebhook.self
        ]
    )
}
