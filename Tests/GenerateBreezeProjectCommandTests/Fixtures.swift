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

struct Fixtures {
    
    static let configFile = "breeze.yml"
    static let emptyConfigFile = "empty.yml"
    static let invalidConfigFile = "invalid.yml"
    
    static func fixture(file: String) throws -> URL {
        let values = file.split(separator: ".").map { String($0) }
        guard let name = values.first,
                let type = values.last,
            let fixtureUrl = Bundle.module.url(forResource: name, withExtension: type, subdirectory: "Fixtures") else {
            throw TestError.missingFixture
        }
        return fixtureUrl
    }
    
    static func example(file: String) throws -> URL {
        let values = file.split(separator: ".").map { String($0) }
        guard let name = values.first,
                let type = values.last,
            let fixtureUrl = Bundle.module.url(forResource: name, withExtension: type, subdirectory: "Fixtures/Examples") else {
            throw TestError.missingFixture
        }
        return fixtureUrl
    }
}

enum TestError: Error {
    case missingFixture
}
