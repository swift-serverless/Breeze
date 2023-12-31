make build_lambda
make cp_lambda_to_sls_build_local
BUILD_ARCH=`uname -m`
if [ $BUILD_ARCH = "arm64" ];
then
    serverless deploy -f github-webhook
else
    serverless deploy -f github-webhook -c serverless-x86_64.yml
fi
