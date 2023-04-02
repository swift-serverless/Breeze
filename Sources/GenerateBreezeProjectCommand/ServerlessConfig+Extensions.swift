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
import SLSAdapter

extension ServerlessConfig {
    
    struct Endpoint {
        let handler: String
        let method: HTTPMethod
        let path: String
    }
    
    static func dynamoDBLambdaAPI(service: String,
                                  dynamoDBKey: String,
                                  dynamoDBTableNamePrefix: String,
                                  httpAPIPath: String,
                                  region: Region,
                                  runtime: Runtime,
                                  architecture: Architecture,
                                  memorySize: Int,
                                  executable: String,
                                  artifact: String) throws -> ServerlessConfig {
        // Internal
        let keyedPath = "\(httpAPIPath)/{\(dynamoDBKey)}"
        let dynamoResourceName = "\(executable)Table"
        
        let environmentTableName = "DYNAMO_DB_TABLE_NAME"
        let environmentKeyName = "DYNAMO_DB_KEY"
        
        // Initialise ServerlessConfig
        let iam = Iam(
            role: Role(
                statements: [.allowLogAccess(resource: try YAMLContent(with: "*")),
                             .allowDynamoDBReadWrite(resource: try YAMLContent(with: [["Fn::GetAtt": [dynamoResourceName, "Arn"]]]))]
            )
        )
        let environment = try YAMLContent(with: [environmentTableName: "${self:custom.tableName}",
                                                   environmentKeyName: "${self:custom.keyName}"])
        let provider = Provider(
            name: .aws,
            region: region,
            runtime: runtime,
            environment: environment,
            architecture: architecture,
            httpAPI: .init(payload: "2.0", cors: true),
            iam: iam
        )
        let custom = try YAMLContent(with: ["tableName": "\(dynamoDBTableNamePrefix)-table-${sls:stage}",
                                            "keyName": dynamoDBKey])
        
        let endpoints = [
            Endpoint(handler: "create", method: .post, path: httpAPIPath),
            Endpoint(handler: "read", method: .get, path: keyedPath),
            Endpoint(handler: "update", method: .put, path: httpAPIPath),
            Endpoint(handler: "delete", method: .delete, path: keyedPath),
            Endpoint(handler: "list", method: .get, path: httpAPIPath)
        ]
        var functions: [String: Function] = [:]
        for endpoint in endpoints {
            let function = try Function.httpApiLambda(
                handler: "\(endpoint.handler)",
                description: nil,
                memorySize: memorySize,
                runtime: nil,
                package: nil,
                event: .init(path: endpoint.path, method: endpoint.method)
            )
            functions["\(endpoint.handler)\(executable)"] = function
        }
        
        let resource = Resource.dynamoDBResource(tableName: "${self:custom.tableName}", key: "${self:custom.keyName}")
        let resources = Resources.resources(with: [dynamoResourceName: resource])
        
        return ServerlessConfig(
            service: service,
            provider: provider,
            package: .init(patterns: nil, individually: nil, artifact: artifact),
            custom: custom,
            layers: nil,
            functions: functions,
            resources: try YAMLContent(with: resources)
        )
    }
}
