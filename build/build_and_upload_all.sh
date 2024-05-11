#!/bin/bash

if [ "$(aws ecr describe-repositories --query "repositories[*].repositoryName" --output text | grep k8simages)" = "" ] 
then   
    echo "Repository k8simages does not exist in ECR - create"
    aws ecr create-repository --repository-name k8simages 
fi

currentscriptdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

$currentscriptdir/database/build.sh

$currentscriptdir/restapi/build.sh
