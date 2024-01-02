# Breeze Github Webhook

## Serverless GitHub WebHook with Breeze

The example shows how to implement the following webhook with AsyncHTTPClient.

- GitHub Webhook: A webhook ready to validate and process an event received from GitHub.

## Requirements

- Install [Docker](https://docs.docker.com/install/)
- Install [Serverless Framework](https://www.serverless.com/framework/docs/getting-started/) version 3

```
Framework Core: 3.25.0 (standalone)
Plugin: 6.2.2
SDK: 4.3.2
```

- Ensure your AWS Account has the right [credentials](https://www.serverless.com/framework/docs/providers/aws/guide/credentials/) to deploy a Serverless stack.
- Clone this repository. From the command line type:
- Ensure you can run `make`

## Deployment Example

The `serverles.yml` deploys the reference architecture for a Serverless Rest API implemented with Breeze in Swift.

### Build

Use the following command to build the code before using the serverless commands:
```bash
./build.sh
```

### Deploy

Deploy the full solution to your AWS using Serverless:
```bash
./deploy.sh
```

After the deployment is completed, the URL of the website is provided by the Serverless framework.

### Update

Rebuild the code and update the Lambda to your AWS using Serverless:
```bash
./update.sh
```

### Remove

To remove the deployment:
```bash
./remove.sh
```

### arm64 M1 Graviton Support

If the project is built with an M1 processor, then the AWS Lambda will be deployed on the `arm64` architecture.

### amd64/x86_64 Support

If the project is built with an Intel processor, then the AWS Lambda will be deployed on the `x86_64` architecture.

## Security Warning
The Example deploys an open endpoint that is not protected, granting open access to anyone from the internet. You need to secure the API gateway endpoints.
You can find more on AWS Documentation about [Controlling and managing access to an HTTP API in API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-access-control.html)
