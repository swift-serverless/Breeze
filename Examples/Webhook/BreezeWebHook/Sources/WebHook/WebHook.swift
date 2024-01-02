//    Copyright 2020 (c) Andrea Scuderi - https://github.com/swift-sprinter
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
import AWSLambdaEvents
import AWSLambdaRuntimeCore
import BreezeLambdaWebHook
import Foundation

enum WebHookError: Error {
    case invalidHandler
}

class WebHook: BreezeLambdaWebHookHandler {
    
    let handlerContext: HandlerContext
    
    required init(handlerContext: HandlerContext) {
        self.handlerContext = handlerContext
    }
    
    func handle(context: AWSLambdaRuntimeCore.LambdaContext, event: AWSLambdaEvents.APIGatewayV2Request) async -> AWSLambdaEvents.APIGatewayV2Response {
        do {
            guard let handler = handlerContext.handler else {
                throw  WebHookError.invalidHandler
            }
            switch handler {
            case "get-webhook":
                return await GetWebHook(handlerContext: handlerContext).handle(context: context, event: event)
            case "post-webhook":
                return await PostWebHook(handlerContext: handlerContext).handle(context: context, event: event)
            default:
                throw  WebHookError.invalidHandler
            }
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .badRequest)
        }
    }
}
