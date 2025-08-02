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
    func cleanTargetPath(_ targetPath: String, remove: Bool, yes: Bool) throws {
        printTitle("🔎 Verifing target path")
        var isDirectory: ObjCBool = false
        
        let directoryExists = fileExists(atPath: targetPath, isDirectory: &isDirectory)
        if remove,
           directoryExists,
           !yes {
            printError("WARNING: The folder at path \(targetPath) will be removed. Do you want to continue? [yes/no]")
            let readline = readLine()
            if readline != "yes" {
                throw BreezeCommandError.cannotOverwriteTargetPath(targetPath)
            }
        }
        
        if remove, directoryExists {
            try removeItem(at: URL(fileURLWithPath: targetPath))
            printInfo("🧹 \(targetPath)\n")
        }
        
        if fileExists(atPath: targetPath, isDirectory: &isDirectory) {
            throw BreezeCommandError.cannotOverwriteTargetPath(targetPath)
        }
        printSuccess("✅ Target path ready!\n")
    }
}

func printTitle(_ string: String) {
    let noora = Noora(theme: BreezeHeader.theme)
    let text: TerminalText = "\(.primary(string))"
    let formattedText = noora.format(text)
    print("\(formattedText)\n")
}

func printInfo(_ string: String) {
    let noora = Noora(theme: BreezeHeader.theme)
    let text: TerminalText = "\(.secondary(string))"
    let formattedText = noora.format(text)
    print("\(formattedText)\n")
}

func printError(_ string: String) {
    let noora = Noora(theme: BreezeHeader.theme)
    noora.error("\(string)")
}

func printSuccess(_ string: String) {
    let noora = Noora(theme: BreezeHeader.theme)
    noora.success("\(string)")
}

func printCommand(_ string: String) {
    let noora = Noora(theme: BreezeHeader.theme)
    let text: TerminalText = "\(.success(string))"
    let formattedText = noora.format(text)
    print("\(formattedText)\n")
}

struct BreezeHeader {
    
    let noora: Noorable
    
    static let theme = Theme(
        primary: "76A3FF",
        secondary: "A9E8D8",
        muted: "505050",
        accent: "DE5E44",
        danger: "FF2929",
        success: "56822B",
        info: "0280B9",
        selectedRowText: "FFFFFF",
        selectedRowBackground: "4600AE"
    )
    
    func breeze() {
        
        let title = """
    BBBBBBBBBBBBBBBBB                                                                                                    
    B::::::::::::::::B                                                                                                   
    B::::::BBBBBB:::::B                                                                                                  
    BB:::::B     B:::::B                                                                                                 
      B::::B     B:::::Brrrrr   rrrrrrrrr       eeeeeeeeeeee        eeeeeeeeeeee    zzzzzzzzzzzzzzzzz    eeeeeeeeeeee    
      B::::B     B:::::Br::::rrr:::::::::r    ee::::::::::::ee    ee::::::::::::ee  z:::::::::::::::z  ee::::::::::::ee  
      B::::BBBBBB:::::B r:::::::::::::::::r  e::::::eeeee:::::ee e::::::eeeee:::::eez::::::::::::::z  e::::::eeeee:::::ee
      B:::::::::::::BB  rr::::::rrrrr::::::re::::::e     e:::::ee::::::e     e:::::ezzzzzzzz::::::z  e::::::e     e:::::e
      B::::BBBBBB:::::B  r:::::r     r:::::re:::::::eeeee::::::ee:::::::eeeee::::::e      z::::::z   e:::::::eeeee::::::e
      B::::B     B:::::B r:::::r     rrrrrrre:::::::::::::::::e e:::::::::::::::::e      z::::::z    e:::::::::::::::::e 
      B::::B     B:::::B r:::::r            e::::::eeeeeeeeeee  e::::::eeeeeeeeeee      z::::::z     e::::::eeeeeeeeeee  
      B::::B     B:::::B r:::::r            e:::::::e           e:::::::e              z::::::z      e:::::::e           
    BB:::::BBBBBB::::::B r:::::r            e::::::::e          e::::::::e            z::::::zzzzzzzze::::::::e          
    B:::::::::::::::::B  r:::::r             e::::::::eeeeeeee   e::::::::eeeeeeee   z::::::::::::::z e::::::::eeeeeeee  
    B::::::::::::::::B   r:::::r              ee:::::::::::::e    ee:::::::::::::e  z:::::::::::::::z  ee:::::::::::::e  
    BBBBBBBBBBBBBBBBB    rrrrrrr                eeeeeeeeeeeeee      eeeeeeeeeeeeee  zzzzzzzzzzzzzzzzz    eeeeeeeeeeeeee
    """
        
        let formattedTitle = noora.format("\(.accent(title))")
        print(formattedTitle)
    }
}
