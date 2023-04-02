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
import Stencil
import PathKit

extension FileManager {
    
    private var templatePath: String {
#if os(macOS)
        return Bundle.module.resourcePath?.appending("/Resources/Template/") ?? ""
#else
        return Bundle.module.resourcePath?.appending("/Template/") ?? ""
#endif
    }
    
    func applyStencils(targetPath: String, params: BreezeLambdaAPIConfig)
    throws {
        printTitle("📁 Generating project from template")
        let context = ["params" : params]
        let dirEnum = enumerator(atPath: templatePath)
        while let file = dirEnum?.nextObject() as? String {
            if file.hasSuffix(".stencil") {
                let stencilURL = URL(fileURLWithPath: templatePath.appending(file))
                let targetURL = URL(fileURLWithPath: targetPath.appending("/").appending(file)).deletingLastPathComponent().path
                try createDirectory(atPath: targetURL, withIntermediateDirectories: true)
                try applyStencil(stencilURL: stencilURL, targetPath: targetURL, context: context)
            }
        }
        try move(targetPath: targetPath, at: "/SwiftPackage/Sources/SwiftTarget", to: "/SwiftPackage/Sources/\(params.targetName)")
        try move(targetPath: targetPath, at: "/SwiftPackage", to: "/\(params.packageName)")
    }
    
    func applyStencil(stencilURL: URL, targetPath: String, context: [String: Any]) throws {
        let stencil = stencilURL.lastPathComponent
        let templateFolder = stencilURL.deletingLastPathComponent().path
        let fsLoader = FileSystemLoader(paths: [Path(stringLiteral: templateFolder)])
        let environment = Environment(loader: fsLoader)
        let package = try environment.renderTemplate(name: stencil, context: context)
        let path = targetPath.appending("/").appending(stencil.replacingOccurrences(of: ".stencil", with: ""))
        let destination = URL(fileURLWithPath: path)
        try package.data(using: .utf8)?.write(to: destination)
        print("📝 \(destination.path)")
        if destination.pathExtension == "sh" {
            try setAttributes([FileAttributeKey.posixPermissions: 0o755], ofItemAtPath: path)
        }
    }
    
    func move(targetPath: String, at: String, to: String) throws {
        let moveAt = targetPath.appending(at)
        let moveTo = targetPath.appending(to)
        try moveItem(atPath: moveAt, toPath: moveTo)
        print("🛫 \(moveAt)\n🛬 \(moveTo)")
    }
}
