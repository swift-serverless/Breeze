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
import Stencil
import PathKit
import Noora

extension FileManager {
    
    private func templatePath(basePath: String) -> String {
#if os(macOS)
        let resourcePath = Bundle.module.url(forResource: "breeze", withExtension: "yml", subdirectory: "Resources")?.deletingLastPathComponent().path ?? ""
        return resourcePath.appending("/\(basePath)/Template/")
#else
        return Bundle.module.resourcePath?.appending("/\(basePath)/Template/") ?? ""
#endif
    }
    
    func applyStencils(
        basePath: String,
        targetPath: String,
        packageName: String,
        targetName: String,
        context: [String: Any],
        progress: (TerminalText) -> Void
    ) async throws {
        var isDirectory: ObjCBool = false
        let templatePath = templatePath(basePath: basePath)
        guard fileExists(atPath: templatePath, isDirectory: &isDirectory) else {
            progress("\(.danger("Invalid templatePath: \(templatePath)"))")
            throw BreezeCommandError.invalidTemplateFolder
        }
        let dirEnum = enumerator(atPath: templatePath)
        while let file = dirEnum?.nextObject() as? String {
            if file.hasSuffix(".stencil") {
                let stencilURL = URL(fileURLWithPath: templatePath.appending(file))
                let targetURL = URL(fileURLWithPath: targetPath.appending("/").appending(file)).deletingLastPathComponent().path
                try createDirectory(atPath: targetURL, withIntermediateDirectories: true)
                try applyStencil(
                    stencilURL: stencilURL,
                    targetPath: targetURL,
                    context: context,
                    progress: progress
                )
            }
        }
        progress(try self.move(targetPath: targetPath, at: "/SwiftPackage/Sources/SwiftTarget", to: "/SwiftPackage/Sources/\(targetName)"))
        if let value = try? self.move(targetPath: targetPath, at: "/SwiftPackage/Tests/SwiftTarget", to: "/SwiftPackage/Tests/\(targetName)Tests") {
            progress(value)
        }
        progress(try self.move(targetPath: targetPath, at: "/SwiftPackage", to: "/\(packageName)"))
    }
    
    func applyStencil(stencilURL: URL, targetPath: String, context: [String: Any], progress: (TerminalText) -> Void) throws {
        let stencil = stencilURL.lastPathComponent
        let templateFolder = stencilURL.deletingLastPathComponent().path
        let fsLoader = FileSystemLoader(paths: [Path(stringLiteral: templateFolder)])
        let environment = Environment(loader: fsLoader)
        let package = try environment.renderTemplate(name: stencil, context: context)
        let path = targetPath.appending("/").appending(stencil.replacingOccurrences(of: ".stencil", with: ""))
        let destination = URL(fileURLWithPath: path)
        try package.data(using: .utf8)?.write(to: destination)
        progress("\(destination.path)")
        if destination.pathExtension == "sh" {
            try setAttributes([FileAttributeKey.posixPermissions: 0o755], ofItemAtPath: path)
        }
    }
    
    func move(targetPath: String, at: String, to: String) throws -> TerminalText {
        let moveAt = targetPath.appending(at)
        let moveTo = targetPath.appending(to)
        try moveItem(atPath: moveAt, toPath: moveTo)
        return TerminalText(unicodeScalarLiteral: "\(moveAt)\n > \(moveTo)")
    }
}
