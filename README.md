# Breeze
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-sprinter%2FBreeze%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swift-sprinter/Breeze) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-sprinter%2FBreeze%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swift-sprinter/Breeze) ![Breeze CI](https://github.com/swift-sprinter/Breeze/actions/workflows/swift-test.yml/badge.svg) [![codecov](https://codecov.io/gh/swift-sprinter/Breeze/branch/main/graph/badge.svg?token=PJR7YGBSQ0)](https://codecov.io/gh/swift-sprinter/Breeze)

[![security status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/security?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)
[![stability status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/stability?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)
[![licensing status](https://www.meterian.io/badge/gh/swift-sprinter/Breeze/licensing?branch=main)](https://www.meterian.io/report/gh/swift-sprinter/Breeze)

![Breeze](logo.png)

A Serverless API Template Generator for Server-Side Swift.

## Abstract

Breeze is a powerful tool designed to streamline the process of creating Serverless API templates in Swift.

It eliminates the complexity of setting up a project from scratch, providing developers with code, scripts and configurations to adapt and customize.
The tool is based on open-source code, allowing anyone the possibility to inspect, understand and improve the implementation.

Breeze fundamental choices:

- Serverless Architecture
- Server-Side Swift code based on [SSWG SDKs](https://www.swift.org/sswg/)
- Open-Source dependencies
- Open to inspection, customisation and contribution
- Infrastructure as a Code
- Deployment scripts

## Why Serverless?

Serverless architecture has revolutionized the way developers approach application deployment. Serverless computing eliminates the complexities associated with traditional server management. This approach results in increased agility, reduced operational overhead, scalability and efficient resource utilization.

## Why Swift?

Swift's concise syntax, strong type system, and performance optimizations contribute to faster development cycles and enhanced code maintainability. Leveraging Swift on the server side ensures a consistent and unified language experience for developers, fostering code sharing between client and server components.

## Breeze Swift Templates

The tool can generate the following available templates:

### Serverless REST API
AWS Serverless REST API based on APIGateway, Lambda, DynamoDB

![AWS Serverless Rest API](/images/AWS-Serverless-REST-API.svg)

- Specs: [Docs/GenerateLambdaAPI.md](Docs/GenerateLambdaAPI.md)

- Command Line help: `swift run breeze generate-lambda-api --help`

- Talk @NSLondon: Serverless in Swift like a Breeze](https://youtu.be/D4qSv_fhQIo?si=WnsTlYbUjHs9DYHF)

- Slide: [Slides](https://www.slideshare.net/AndreaScuderi6/serverless-in-swift-like-a-breeze)

### GitHub Webhook

A GitHub Webhook with signature verification based on APIGateway and Lambda.

![AWS Serverless GitHub Webhook](/images/AWS-Serverless-Github-Webhook.svg)

- Specs: [Docs/GenerateGithubWebhook.md](Docs/GenerateGithubWebhook.md)

- Command Line help: `swift run breeze generate-github-webhook --help`

### GET/POST Webhook

A Serveless Webhook based on APIGateway and Lambda with POST and GET endpoints.

![AWS Serverless Webhook](/images/AWS-Serverless-Webhook.svg)

- Specs: [Docs/GenerateWebhook.md](Docs/GenerateWebhook.md)

- Command Line help: `swift run breeze generate-webhook --help`

## Usage

```bash
swift run breeze --help
```

output:

```
OVERVIEW: Breeze command line

Generate the deployment of a Serverless project using Breeze.
The command generates of the swift package, the `serverless.yml` file and the relevant commands in the target path to deploy
the Lambda code on AWS using the Serverless Framework.

USAGE: breeze <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  generate-lambda-api
  generate-github-webhook
  generate-webhook

  See 'breeze help <subcommand>' for detailed help.
```

## Development Workflow

The workflow to develop Serverless in Swift using Breeze can be described by the following steps:

- Generate the project using the `breeze` command line tool
  - Choose a Breeze template and follow the documentation
  - Copy and adapt the template configuration file
  - Generate the project
- Customize the generated project adapting the code
- Build the project using the `build.sh` script
- Deploy the project using the `deploy.sh` script
- Update the project when the code changes using the `update.sh` script
- Remove the project if it's not needed anymore with `remove.sh` script

## Requirements and Tools

- Swift (Version >= 5.7)
- [Docker](https://docs.docker.com/install/)
- [Serverless Framework](https://www.serverless.com/framework/docs/getting-started/) version 3
- Ensure your AWS Account has the right [credentials](https://www.serverless.com/framework/docs/providers/aws/guide/credentials/) to deploy a Serverless stack.
- Ensure you can run `make`

## Contributing

Contributions are welcome! If you encounter any issues or have ideas for improvements, please open an issue or submit a pull request.



