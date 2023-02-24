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

import AWSLambdaEvents
import AWSLambdaRuntime
@testable import AWSLambdaRuntimeCore
import AWSLambdaTesting
import Logging
import NIO

extension Lambda {
    public static func test<Handler: LambdaHandler>(
        _ handlerType: Handler.Type,
        with event: Handler.Event,
        using config: TestConfig = .init()
    ) async throws -> Handler.Output {
        let logger = Logger(label: "test")
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            try! eventLoopGroup.syncShutdownGracefully()
        }
        let eventLoop = eventLoopGroup.next()

        let initContext = LambdaInitializationContext.__forTestsOnly(
            logger: logger,
            eventLoop: eventLoop
        )

        let context = LambdaContext.__forTestsOnly(
            requestID: config.requestID,
            traceID: config.traceID,
            invokedFunctionARN: config.invokedFunctionARN,
            timeout: config.timeout,
            logger: logger,
            eventLoop: eventLoop
        )
        let handler = try await Handler(context: initContext)
        defer {
            let eventLoop = initContext.eventLoop.next()
            try? initContext.terminator.terminate(eventLoop: eventLoop).wait()
        }
        return try await handler.handle(event, context: context)
    }
}
