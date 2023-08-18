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

import AsyncHTTPClient
import AWSLambdaEvents
import AWSLambdaRuntime
import AWSLambdaRuntimeCore
import Foundation

public extension LambdaInitializationContext {
    enum WebHook {
        public static var timeout: Int64 = 30
    }
}

public struct HandlerContext {
    public let handler: String?
    public let httpClient: HTTPClient
}

public class BreezeLambdaWebHook<Handler: BreezeLambdaWebHookHandler>: LambdaHandler {
    public typealias Event = APIGatewayV2Request
    public typealias Output = APIGatewayV2Response
    
    let handlerContext: HandlerContext

    public required init(context: LambdaInitializationContext) async throws {
        let handler = Lambda.env("_HANDLER")
        context.logger.info("handler: \(handler ?? "")")

        let timeout = HTTPClient.Configuration.Timeout(
            connect: .seconds(LambdaInitializationContext.WebHook.timeout),
            read: .seconds(LambdaInitializationContext.WebHook.timeout)
        )

        let configuration = HTTPClient.Configuration(timeout: timeout)
        let httpClient = HTTPClient(
            eventLoopGroupProvider: .shared(context.eventLoop),
            configuration: configuration
        )
        
        handlerContext = HandlerContext(handler: handler, httpClient: httpClient)

        context.terminator.register(name: "shutdown") { eventLoop in
            context.logger.info("shutdown: started")
            let promise = eventLoop.makePromise(of: Void.self)
            Task {
                do {
                    try await self.handlerContext.httpClient.shutdown()
                    promise.succeed()
                    context.logger.info("shutdown: succeed")
                } catch {
                    promise.fail(error)
                    context.logger.info("shutdown: fail")
                }
            }
            return promise.futureResult
        }
    }

    public func handle(_ event: AWSLambdaEvents.APIGatewayV2Request, context: AWSLambdaRuntimeCore.LambdaContext) async throws -> AWSLambdaEvents.APIGatewayV2Response {
        return await Handler(handlerContext: handlerContext).handle(context: context, event: event)
    }
}

