make build_lambda
make cp_lambda_to_sls_build_local
BUILD_ARCH=`uname -m`
if [ $BUILD_ARCH = "arm64" ];
then
    serverless deploy -f createBreezeItemAPI
    serverless deploy -f readBreezeItemAPI
    serverless deploy -f updateBreezeItemAPI
    serverless deploy -f deleteBreezeItemAPI
    serverless deploy -f listBreezeItemAPI
else
    serverless deploy -f createBreezeItemAPI -c serverless-x86_64.yml
    serverless deploy -f readBreezeItemAPI -c serverless-x86_64.yml
    serverless deploy -f updateBreezeItemAPI -c serverless-x86_64.yml
    serverless deploy -f deleteBreezeItemAPI -c serverless-x86_64.yml
    serverless deploy -f listBreezeItemAPI -c serverless-x86_64.yml
fi
