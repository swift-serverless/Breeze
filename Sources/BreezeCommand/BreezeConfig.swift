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

struct BreezeConfig: Codable {
    let service: String
    let awsRegion: String
    let swiftVersion: String
    let swiftConfiguration: String
    let packageName: String
    let buildPath: String
    let breezeLambdaAPI: BreezeLambdaAPIConfig?
    let breezeGithubWebhook: BreezeGithubWebhookConfig?
    let breezeWebhook: BreezeWebhookConfig?
    let cors: Bool
    let authorizer: BreezeAuthorizer?
}

enum BreezeAuthorizerType: String, Codable {
    case JWTAuthorizer
    case customAuthorizer
}

struct BreezeAuthorizer: Codable {
    let name: String
    let type: BreezeAuthorizerType
    let issuerUrl: String
    let audience: [String]
}

struct BreezeLambdaAPIConfig: Codable {
    let targetName: String
    let itemCodable: String
    let itemKey: String
    let httpAPIPath: String
    let dynamoDBTableNamePrefix: String
}

struct BreezeGithubWebhookConfig: Codable {
    let targetName: String
    let httpPath: String
    let secret: String
}

struct BreezeWebhookConfig: Codable {
    let targetName: String
    let httpPath: String
}

extension BreezeConfig {
    static let decoder = YAMLDecoder()
    static func load(from url: URL) throws -> BreezeConfig {
        let paramsYML = try Data(contentsOf: url)
        printTitle("⚙️ Loading configuration file")
        print("\(url.path)\n")
        let yml = String(data: paramsYML, encoding: .utf8) ?? ""
        print(yml)
        return try decoder.decode(BreezeConfig.self, from: paramsYML)
    }
}
