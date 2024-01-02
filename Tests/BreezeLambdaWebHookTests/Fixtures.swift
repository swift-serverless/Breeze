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
import AWSLambdaEvents

struct Fixtures {
    
    // MARK: - Fixtures JSONs
    
    static let getWebHook = "get_webhook_api_gtw"
    
    static let postWebHook = "post_webhook_api_gtw"
    
    // MARK: - Functions
    static func fixture(name: String, type: String) throws -> Data {
        guard let fixtureUrl = Bundle.module.url(forResource: name, withExtension: type, subdirectory: "Fixtures") else {
            throw TestError.missingFixture
        }
        return try Data(contentsOf: fixtureUrl)
    }
}
