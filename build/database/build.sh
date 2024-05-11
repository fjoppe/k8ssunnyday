#!/bin/bash

echo "Create Database image"
workdir=$(pwd)
currentscriptdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "1. Set environment variables"
source $currentscriptdir/../scripts/setenv.sh


echo "2. Transpile the sources"
cd $currentscriptdir/src

npm install
npm run build

echo "3. Build Image"
cd $currentscriptdir

docker build -t k8simage:database-latest .

echo "4. Upload image to ECR"
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ECR_ENDPOINT
docker tag k8simage:database-latest $AWS_ECR_ENDPOINT:database-latest
docker push $AWS_ECR_ENDPOINT:database-latest
