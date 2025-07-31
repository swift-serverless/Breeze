# Breeze
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-serverless%2FBreeze%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swift-serverless/Breeze) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-serverless%2FBreeze%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swift-serverless/Breeze) ![Breeze CI](https://github.com/swift-serverless/Breeze/actions/workflows/swift-test.yml/badge.svg) [![codecov](https://codecov.io/gh/swift-serverless/Breeze/branch/main/graph/badge.svg?token=PJR7YGBSQ0)](https://codecov.io/gh/swift-serverless/Breeze)

[![security status](https://www.meterian.io/badge/gh/swift-serverless/Breeze/security?branch=main)](https://www.meterian.io/report/gh/swift-serverless/Breeze)
[![stability status](https://www.meterian.io/badge/gh/swift-serverless/Breeze/stability?branch=main)](https://www.meterian.io/report/gh/swift-serverless/Breeze)
[![licensing status](https://www.meterian.io/badge/gh/swift-serverless/Breeze/licensing?branch=main)](https://www.meterian.io/report/gh/swift-serverless/Breeze)


# Breeze

**Build and deploy serverless Swift applications in a Breeze\!**

![Breeze](logo.png)

Breeze is a command-line tool that makes it easy to create, build, and deploy serverless applications written in Swift. It provides ready-to-use templates that you can customize to fit your needs, so you can focus on writing your application's logic instead of wrestling with project setup and configuration.

## Why Breeze? 🤔

Building serverless applications can be complex. You have to deal with infrastructure as code, deployment scripts, and a whole new set of tools and services. Breeze simplifies this process by providing:

  * **Ready-to-use templates:** Get started quickly with pre-built templates for common serverless use cases.
  * **Swift on the server:** Write your backend code in the same language you use for your iOS, macOS, and other Apple platform apps.
  * **Open and customizable:** All the generated code and configurations are open source and can be easily modified to fit your specific needs.
  * **Streamlined workflow:** Breeze provides a set of simple commands to generate, build, deploy, and manage your serverless applications.

## Why Serverless? 🚀

Serverless computing allows you to build and run applications without thinking about servers. It offers:

  * **Reduced operational overhead:** No servers to provision or manage.
  * **Automatic scaling:** Your application scales automatically with the number of requests.
  * **Cost-effectiveness:** You only pay for the resources your application consumes.

## Why Swift? 🐦

Swift is a modern, fast, and safe programming language that is now a great choice for server-side development. It offers:

  * **High performance:** Swift is a compiled language that is known for its speed and efficiency.
  * **Concise and readable syntax:** Swift's clean syntax makes it easy to write and maintain code.
  * **Strongly typed:** Swift's strong type system helps you catch errors at compile time, not at runtime.

## Available Templates 📦

Breeze currently offers the following templates:

### Serverless REST API

A complete serverless REST API with CRUD operations, using **API Gateway**, **Lambda**, and **DynamoDB**.

![AWS Serverless Rest API](/images/AWS-Serverless-REST-API.svg)

  * **Learn more:** [Docs/GenerateLambdaAPI.md](https://www.google.com/search?q=Docs/GenerateLambdaAPI.md)
  * **Get started:** `swift run breeze generate-lambda-api --help`
  * **Watch the talk:** [Serverless in Swift Like a Breeze – Andrea Scuderi (NSLondon 2023.2)](http://www.youtube.com/watch?v=D4qSv_fhQIo)
  * **View the slides:** [Slides](https://www.slideshare.net/AndreaScuderi6/serverless-in-swift-like-a-breeze)

### GitHub Webhook

A serverless webhook that can receive and process GitHub events, with signature verification.

![AWS Serverless GitHub Webhook](/images/AWS-Serverless-Github-Webhook.svg)

  * **Learn more:** [Docs/GenerateGithubWebhook.md](https://www.google.com/search?q=Docs/GenerateGithubWebhook.md)
  * **Get started:** `swift run breeze generate-github-webhook --help`

### GET/POST Webhook

A simple serverless webhook with GET and POST endpoints.

![AWS Serverless Webhook](/images/AWS-Serverless-Webhook.svg)

  * **Learn more:** [Docs/GenerateWebhook.md](https://www.google.com/search?q=Docs/GenerateWebhook.md)
  * **Get started:** `swift run breeze generate-webhook --help`

## Getting Started 🏁

Make sure you have the prerequisites installed, including Swift, Docker, and the Open Source Serverless framework. 
Then, you can start using Breeze to generate your serverless applications.
It only takes a few steps to get your first serverless Swift application up and running with Breeze:

1.  **Generate a project:**
    ```bash
    swift run breeze generate-lambda-api --product-name MyAwesomeAPI
    ```
2.  **Customize the code:**
    Open the generated project in your favorite editor and start writing your application's logic.
3.  **Build and deploy:**
    ```bash
    cd MyAwesomeAPI
    ./build.sh
    ./deploy.sh
    ```

That's it\! Your serverless application is now live.

## Cli Commands 📜

Breeze provides a set of command-line interface (CLI) commands to help you generate your serverless applications:

- `swift run breeze generate-lambda-api`: Generate a new serverless REST API.
- `swift run breeze generate-github-webhook`: Generate a new GitHub webhook.
- `swift run breeze generate-webhook`: Generate a new generic webhook.

Help for each command can be accessed by appending `--help` to the command, e.g. `swift run breeze generate-lambda-api --help`.

## Development Workflow 🛠️

Breeze provides a simple and efficient workflow for developing serverless applications in Swift:

1.  **Generate:** Create a new project from a template.
2.  **Customize:** Modify the generated code to implement your application's logic.
3.  **Build:** Use the `build.sh` script to compile your code and package it for deployment.
4.  **Deploy:** Use the `deploy.sh` script to deploy your application to AWS.
5.  **Update:** Use the `update.sh` script to deploy changes to your application.
6.  **Remove:** Use the `remove.sh` script to delete your application from AWS.

## Requirements 📋

  * Swift 5.7 or later
  * [Docker](https://docs.docker.com/install/)
  * [Open Source Serverless](https://github.com/oss-serverless/serverless)
  * An AWS account with the necessary credentials to deploy a Serverless stack.
  * `make`

## Cost of Running Breeze 💰

Breeze is designed to minimize costs by leveraging serverless architecture. However, you should be aware of the following potential costs when running your serverless applications:
  * **AWS Lambda:** You pay for the compute time your functions consume.[*](https://aws.amazon.com/lambda/pricing/)
  * **API Gateway:** You pay for the number of API calls and data transfer. [*](https://aws.amazon.com/api-gateway/pricing/)
  * **DynamoDB:** You pay for the read/write capacity and storage used by your database.[*](https://aws.amazon.com/dynamodb/pricing/)
  * **S3:** You pay for the storage used by your application assets.[*](https://aws.amazon.com/s3/pricing/)
  * **IAM:** You may incur costs for IAM roles and policies, depending on your usage. [*](https://aws.amazon.com/iam/pricing/)

Estimated costs can vary based on your application's usage patterns, so it's important to monitor your AWS billing and optimize your resources accordingly. Estimation of costs can be done using the AWS Pricing Calculator: [AWS Pricing Calculator](https://calculator.aws/#/)

Free tier usage is available for many AWS services, so you can get started without incurring costs.

- Low Traffic: If your API handles fewer than 1 million requests per month and performs simple database operations, your total monthly bill will almost certainly be $0.00, thanks to the generous AWS Free Tier for every component.

## Contributing 🤝

Contributions are welcome! If you find any issues or have ideas for new features, please open an issue or submit a pull request.