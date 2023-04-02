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

struct BreezeLambdaAPIConfig: Codable {
    let swiftVersion: String
    let swiftConfiguration: String
    let packageName: String
    let targetName: String
    let itemCodable: String
    let itemKey: String
    let buildPath: String
    let httpAPIPath: String
    let dynamoDBTableNamePrefix: String
    let service: String
    let awsRegion: String
}

extension BreezeLambdaAPIConfig {
    static let decoder = YAMLDecoder()
    static func load(from url: URL) throws -> BreezeLambdaAPIConfig {
        let paramsYML = try Data(contentsOf: url)
        printTitle("⚙️ Loading configuration file")
        print("\(url.path)\n")
        let yml = String(data: paramsYML, encoding: .utf8) ?? ""
        print(yml)
        return try decoder.decode(BreezeLambdaAPIConfig.self, from: paramsYML)
    }
}
