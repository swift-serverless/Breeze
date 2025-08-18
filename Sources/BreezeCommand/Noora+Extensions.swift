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

extension Noora {
    
    func breezeHeader() {
        
        let title = """
    
        
                                        \\ | /                                                  
                             | /     -----< -                                                  
                         ----< -          | \\                                                 
                           / |                    \\ /                                                     
            ░▒░░░░                    \\       ----< -                                                     
          ░░▒░░░░▒░░                  ->--        / \\                                                     
         ░▒░░▒▒░▒░░▒░                 /                                                            
        ░░░▒░░▓█░▒▒░░░                                                                     
        ░▒▒░▒████░░░░░                                                                     
        ▒░░░░░█▓░▒░▒▒░      ░████████                                                      
         ░░░░█░▒░░▒░░       ░██    ░██                                                     
          ░░█░▒░▒░░▒        ░██    ░██  ░██████  ░████████  ░████████  ░█████████ ░████████
           █░░░░░▒          ░████████   ░██  ░██ ░██        ░██             ░███  ░██      
          ▓█                ░██     ░██ ░██████  ░████████  ░████████     ░███    ░████████
          ▓█                ░██     ░██ ░██  ░██ ░██        ░██         ░███      ░██      
          ██                ░█████████  ░██  ░██ ░████████  ░████████  ░█████████ ░████████
        
    
    """
        let formattedTitle = format("\(.accent(title))")
        print(formattedTitle)
        print("")
    }
    
    func loadConfig<V>(task: @escaping ((String) -> Void) async throws -> V) async throws -> V {
        try await progressStep(
            message: "Loading configuration",
            successMessage: "Configuration loaded",
            errorMessage: "Invalid configuration",
            showSpinner: true,
            task: task
        )
    }
    
    func verifyTarget(
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
    ) async throws {
        try await collapsibleStep(
            title: "Verifing target path",
            successMessage: "Target path is valid",
            errorMessage: "Target path is not valid",
            visibleLines: 3,
            task: task
        )
    }
    
    func generateProject(
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
    ) async throws {
        try await collapsibleStep(
            title: "Generating project from template",
            successMessage: "Project genereration succeeded",
            errorMessage: "Project genereration failed",
            visibleLines: 3,
            task: task
        )
    }
    
    func printInstructions(targetPath: String) {
        let info: TerminalText = "\(.primary("Use the following commands to build & deploy:\n"))"
        self.info(.alert(info))
        let command = format("\(.secondary("cd \(targetPath)\n./build.sh\n./deploy.sh"))")
        print("\(command)\n")
    }
    
    
    func projectReady(targetPath: String) {
        print("")
        success("Project is ready at path: \(targetPath)")
        print("")
    }
}

struct BreezeNoora {
    static let theme = Theme(
        primary: "A378F2",
        secondary: "FF4081",
        muted: "505050",
        accent: "DE5E44",
        danger: "FF2929",
        success: "56822B",
        info: "0280B9",
        selectedRowText: "FFFFFF",
        selectedRowBackground: "4600AE"
    )
}
