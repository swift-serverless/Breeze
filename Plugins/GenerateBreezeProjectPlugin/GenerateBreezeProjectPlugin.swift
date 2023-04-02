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
import PackagePlugin

@main
struct GenerateBreezeProjectPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        
        print(arguments)
        
        var targetsToProcess: [Target] = context.package.targets
        
        var argExtractor = ArgumentExtractor(arguments)
        
        let selectedTargets = argExtractor.extractOption(named: "target")
        
        if selectedTargets.isEmpty == false {
            targetsToProcess = context.package.targets.filter { selectedTargets.contains($0.name) }.map { $0 }
        }
        
        for target in targetsToProcess {
            guard let target = target as? SourceModuleTarget,
                let directory = URL(string: target.directory.string) else { continue }
            print(directory)
        }
    }
}
