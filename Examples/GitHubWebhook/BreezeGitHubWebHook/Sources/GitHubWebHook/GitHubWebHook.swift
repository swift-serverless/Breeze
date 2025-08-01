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
import AWSLambdaEvents
import AWSLambdaRuntime
import BreezeLambdaWebHook

enum GitHubWebHookError: Error {
    case invalidKey
    case invalidBody
    case invalidSignature
}

class GitHubWebHook: BreezeLambdaWebHookHandler {
    
    let handlerContext: HandlerContext
    
    required init(handlerContext: HandlerContext) {
        self.handlerContext = handlerContext
    }
    
    private func validateGitHubSignature(context: LambdaContext, event: AWSLambdaEvents.APIGatewayV2Request) throws -> String {
        guard let key = Lambda.env("WEBHOOK_SECRET") else {
            throw GitHubWebHookError.invalidKey
        }
        guard let payload = event.body else {
            throw GitHubWebHookError.invalidBody
        }
        guard let signature = event.headers["x-hub-signature-256"] else {
            throw GitHubWebHookError.invalidSignature
        }
        let validator = GitHubSignatureValidator(signature: signature, secret: key, payload: payload)
        let isValid = try validator.isValid()
        context.logger.info("isValid: \(isValid)")
        return payload
    }
    
    func handle(_ event: APIGatewayV2Request, context: LambdaContext) async -> APIGatewayV2Response {
        do {
            context.logger.info("event: \(event)")
            let payload = try validateGitHubSignature(context: context, event: event)
            
            // TODO: Decode the Github payload
            
            // TODO: Implement the business logic
            
            return APIGatewayV2Response(with: "{}", statusCode: .ok)
        } catch {
            return APIGatewayV2Response(with: error, statusCode: .badRequest)
        }
    }
}
