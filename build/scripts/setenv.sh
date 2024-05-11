#!/bin/bash

export AWS_ACCOUNT=`aws sts get-caller-identity --query "Account" --output text`
export AWS_DEFAULT_REGION=`aws configure get region`
export AWS_ECR_ENDPOINT=`aws ecr describe-repositories --query "repositories[*].repositoryUri" --output text | grep k8simages`
