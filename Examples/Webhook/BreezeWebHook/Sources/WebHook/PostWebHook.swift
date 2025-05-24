//    Copyright 2020 (c) Andrea Scuderi - https://github.com/swift-serverless
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
import AsyncHTTPClient
import AWSLambdaEvents
import AWSLambdaRuntime
import BreezeLambdaWebHook

enum PostWebHookError: Error {
    case invalidBody
}

struct PostWebHookRequest: Codable {
    let githubUser: String
    
    enum CodingKeys: String, CodingKey {
        case githubUser = "github-user"
    }
}

class PostWebHook: BreezeLambdaWebHookHandler {
    
    let handlerContext: HandlerContext
    
    required init(handlerContext: HandlerContext) {
        self.handlerContext = handlerContext
    }
    
    func handle(_ event: APIGatewayV2Request, context: LambdaContext) async -> APIGatewayV2Response {
        do {
            context.logger.info("event: \(event)")
            let incomingRequest: PostWebHookRequest = try event.bodyObject()
            let url = "https://github.com/\(incomingRequest.githubUser)"
            let request = HTTPClientRequest(url: url)
            let response = try await httpClient.execute(request, timeout: .seconds(3))
            let bytes = try await response.body.collect(upTo: 1024 * 1024) // 1 MB Buffer
            let body = String(buffer: bytes)
            return APIGatewayV2Response(with: body, statusCode: .ok)
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .badRequest)
        }
    }
}
