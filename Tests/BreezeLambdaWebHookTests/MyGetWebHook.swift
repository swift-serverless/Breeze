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
import BreezeLambdaWebHook
import AsyncHTTPClient
import AWSLambdaEvents
import AWSLambdaRuntimeCore

class MyGetWebHook: BreezeLambdaWebHookHandler {
    let handler: String?
    let httpClient: AsyncHTTPClient.HTTPClient
    
    required init(httpClient: AsyncHTTPClient.HTTPClient, handler: String?) {
        self.httpClient = httpClient
        self.handler = handler
    }
    
    func handle(context: AWSLambdaRuntimeCore.LambdaContext, event: AWSLambdaEvents.APIGatewayV2Request) async -> AWSLambdaEvents.APIGatewayV2Response {
        do {
            try await Task.sleep(nanoseconds: 1_000_000)
            guard let params = event.queryStringParameters else {
                throw BreezeLambdaWebHookError.invalidRequest
            }
            return APIGatewayV2Response(with: params, statusCode: .ok)
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .badRequest)
        }
    }
}
