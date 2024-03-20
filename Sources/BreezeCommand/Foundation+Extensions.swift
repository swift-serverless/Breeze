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

extension FileManager {
    func cleanTargetPath(_ targetPath: String, remove: Bool, yes: Bool) throws {
        printTitle("🔎 Verifing target path")
        var isDirectory: ObjCBool = false
        
        let directoryExists = fileExists(atPath: targetPath, isDirectory: &isDirectory)
        if remove,
           directoryExists,
           !yes {
            print("WARNING: The folder at path \(targetPath) will be removed. Do you want to continue? [yes/no]")
            let readline = readLine()
            if readline != "yes" {
                throw BreezeCommandError.cannotOverwriteTargetPath(targetPath)
            }
        }
        
        if remove, directoryExists {
            try removeItem(at: URL(fileURLWithPath: targetPath))
            print("🧹 \(targetPath)\n")
        }
        
        if fileExists(atPath: targetPath, isDirectory: &isDirectory) {
            throw BreezeCommandError.cannotOverwriteTargetPath(targetPath)
        }
        print("✅ Target path ready!\n")
    }
}

func printTitle(_ string: String) {
    print("\(string)\n")
}

func breeze() {
    
    let title = """
    🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵
    🎵💨💨💨💨💨💨🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵
    🎵💨🎵🎵🎵🎵🎵💨🎵💨💨💨💨💨🎵🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵
    🎵💨🎵🎵🎵🎵🎵💨🎵💨🎵🎵🎵🎵💨🎵💨🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵💨🎵🎵💨🎵🎵🎵🎵🎵🎵
    🎵💨💨💨💨💨💨🎵🎵💨🎵🎵🎵🎵💨🎵💨💨💨💨💨🎵🎵💨💨💨💨💨🎵🎵🎵🎵🎵💨🎵🎵🎵💨💨💨💨💨🎵🎵
    🎵💨🎵🎵🎵🎵🎵💨🎵💨💨💨💨💨🎵🎵💨🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵
    🎵💨🎵🎵🎵🎵🎵💨🎵💨🎵🎵🎵💨🎵🎵💨🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵💨🎵🎵🎵🎵🎵🎵
    🎵💨💨💨💨💨💨🎵🎵💨🎵🎵🎵🎵💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵💨💨💨💨💨💨🎵
    🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵🎵
    """
    print(title)
}
