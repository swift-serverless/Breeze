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

func setEnvironmentVar(name: String, value: String, overwrite: Bool) {
    setenv(name, value, overwrite ? 1 : 0)
}

enum TestError: Error {
    case missingFixture
}

extension APIGatewayV2Response {
    func decodeBody<Out: Decodable>() throws -> Out {
        let decoder = JSONDecoder()
        let data = body?.data(using: .utf8) ?? Data()
        return try decoder.decode(Out.self, from: data)
    }
}
