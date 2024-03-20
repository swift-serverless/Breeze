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

enum BreezeCommandError: Error, LocalizedError {
    case invalidTemplateFolder
    case invalidConfig
    case cannotOverwriteTargetPath(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidTemplateFolder:
            return "Internal Error: Invalid Template folder"
        case .invalidConfig:
            return "Invalid config"
        case .cannotOverwriteTargetPath(let path):
            return "TargetPath \(path) cannot be overwritten"
        }
    }
}
