# Breeze
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-sprinter%2FBreeze%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swift-sprinter/Breeze) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-sprinter%2FBreeze%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swift-sprinter/Breeze) ![Breeze CI](https://github.com/swift-sprinter/Breeze/actions/workflows/swift-test.yml/badge.svg) [![codecov](https://codecov.io/gh/swift-sprinter/Breeze/branch/main/graph/badge.svg?token=PJR7YGBSQ0)](https://codecov.io/gh/swift-sprinter/Breeze)

[![security status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/security?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)
[![stability status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/stability?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)
[![licensing status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/licensing?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)

![Breeze](logo.png)

A Serverless API Template Generator for Server-Side Swift.

## Abstract

Breeze is a powerful tool designed to streamline the process of creating Serverless API templates in Swift.

It eliminates the complexity of setting up the infrastructure, allowing developers to focus on building robust APIs without the hassle of managing servers.

## Features

- Serverless Architecture: Generate AWS Lambda functions and API Gateway configurations to deploy your API in a serverless environment.

- Server-Side Swift: Breeze is tailored for Swift developers, providing a seamless experience for creating Serverless APIs using Swift.

- Template Customization: Breeze allows you to customize the generated templates to suit your specific requirements.

- Dependencies: All the open-source dependencies are integrated with Swift Package Manager.

- IaaC: The project is generated to be deployed on AWS using the Serverless Framework.

## Breeze Swift Templates

The tool can generate the following kinds of projects:

### Serverless REST API
AWS Serverless REST API based on APIGateway, Lambda, DynamoDB

![AWS Serverless Rest API](/images/AWS-Serverless-REST-API.svg)

- Specs: [Docs/GenerateLambdaAPI.md](Docs/GenerateLambdaAPI.md)

- Command Line help: `breeze generate-lambda-api --help`

- Talk @NSLondon: [Serverles in Swift like a Breeze](https://youtu.be/D4qSv_fhQIo?si=WnsTlYbUjHs9DYHF)

- Slide: [Slides](https://www.slideshare.net/AndreaScuderi6/serverless-in-swift-like-a-breeze)

### GitHub Web-Hook

A GitHub web-hook with signature verification based on APIGateway Lambda.

### Web-hook

A Serveless web-hook based on APIGateway and Lambda with POST and GET endpoints.

## Usage

```bash
swift run breeze
```

output:

```
OVERVIEW: Breeze command line

Generate the deployment of a Serverless project using Breeze.
The command generates of the swift package, the `serverless.yml` file and the
relevant commands in the target path to deploy the Lambda code on AWS using the
Serverless Framework.

USAGE: breeze <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  generate-lambda-api

  See 'breeze help <subcommand>' for detailed help.
```

## Requirements

- Swift (Version >= 5.7)
- [Docker](https://docs.docker.com/install/)
- [Serverless Framework](https://www.serverless.com/framework/docs/getting-started/) version 3
- Ensure your AWS Account has the right [credentials](https://www.serverless.com/framework/docs/providers/aws/guide/credentials/) to deploy a Serverless stack.
- Ensure you can run `make`

## Contributing

Contributions are welcome! If you encounter any issues or have ideas for improvements, please open an issue or submit a pull request.



