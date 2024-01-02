make build_lambda
make cp_lambda_to_sls_build_local
BUILD_ARCH=`uname -m`
if [ $BUILD_ARCH = "arm64" ];
then
    serverless deploy -f createItemAPI
    serverless deploy -f readItemAPI
    serverless deploy -f updateItemAPI
    serverless deploy -f deleteItemAPI
    serverless deploy -f listItemAPI
else
    serverless deploy -f createItemAPI -c serverless-x86_64.yml
    serverless deploy -f readItemAPI -c serverless-x86_64.yml
    serverless deploy -f updateItemAPI -c serverless-x86_64.yml
    serverless deploy -f deleteItemAPI -c serverless-x86_64.yml
    serverless deploy -f listItemAPI -c serverless-x86_64.yml
fi
