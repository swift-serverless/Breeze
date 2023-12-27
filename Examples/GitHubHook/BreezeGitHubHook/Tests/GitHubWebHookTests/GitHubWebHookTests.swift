//    Copyright 2020 (c) Andrea Scuderi - https://github.com/swift-sprinter
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
@testable import GitHubWebHook

class GitHubWebHookTests: XCTestCase {
    
    func testVerifySignature() throws {
        // https://docs.github.com/en/webhooks-and-events/webhooks/securing-your-webhooks
        let key = "It's a Secret to Everybody"
        let payload = "Hello, World!"
        let signature = "sha256=757107ea0eb2509fc211221cce984b8a37570b6d7586c22c46f4379c8b043e17"
        let validator = GitHubSignatureValidator(signature: signature, secret: key, payload: payload)
        let isValid = try validator.isValid()
        XCTAssertTrue(isValid)
    }
}
