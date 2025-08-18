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

import Foundation
import Noora

extension FileManager {
    func cleanTargetPath(
        _ targetPath: String,
        remove: Bool,
        yes: Bool,
        noora: Noorable
    ) async throws {
        var isDirectory: ObjCBool = false
        
        let directoryExists = fileExists(atPath: targetPath, isDirectory: &isDirectory)
        if remove,
           directoryExists,
           !yes {
            guard noora.yesOrNoChoicePrompt(
                title: "\(.danger("WARNING: The folder at path \(targetPath) will be removed."))",
                question: "Do you want to continue?",
                defaultAnswer: false,
                description: "The target path needs to be empty before proceeding.",
            ) else {
                throw BreezeCommandError.cannotOverwriteTargetPath(targetPath)
            }
        }
        
        if remove, directoryExists {
            try removeItem(at: URL(fileURLWithPath: targetPath))
            noora.info("removing: \(targetPath)\n")
        }
        
        if fileExists(atPath: targetPath, isDirectory: &isDirectory) {
            throw BreezeCommandError.cannotOverwriteTargetPath(targetPath)
        }
    }
}
