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
import Crypto

public struct GitHubSignatureValidator {
    private let signature: String
    private let key: SymmetricKey
    private let payloadBytes: Array<UInt8>
    
    public init(signature: String, secret: String, payload: String) {
        self.signature = signature
        let secretBytes: Array<UInt8> = Array(secret.utf8)
        self.key = SymmetricKey(data: secretBytes)
        self.payloadBytes = Array(payload.utf8)
    }
    
    func isValid() throws -> Bool {
        let mac = try Data(hexString: signature.replacingOccurrences(of: "sha256=", with: ""))
        return HMAC<SHA256>.isValidAuthenticationCode(mac, authenticating: payloadBytes, using: key)
    }
}

fileprivate enum HexEncodingError: Error {
    case inavlidHexValue
    case invalidString
}

fileprivate extension UInt8 {
    func char2int() throws -> UInt8 {
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        switch self {
        case char0...char0 + 9:
            return self - char0
        case charA...charA + 5:
            return self - charA + 10
        default:
            throw HexEncodingError.inavlidHexValue
        }
    }
}

fileprivate extension Data {
    init(hexString: String) throws {
        self.init()
        if hexString.count % 2 != 0 || hexString.count == 0 {
            throw HexEncodingError.invalidString
        }

        let stringBytes: [UInt8] = Array(hexString.data(using: String.Encoding.utf8)!)

        for i in 0...((hexString.count / 2) - 1) {
            let char1 = stringBytes[2 * i]
            let char2 = stringBytes[2 * i + 1]
            try self.append(char1.char2int() << 4 + char2.char2int())
        }
    }
}
