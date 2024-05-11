# Building the application components

This folder contains the Typescript source code and build-scripts.


Before running:
- make sure you have installed docker, aws cli, typescript, node/npm 
- make sure you configured your AWS context with: `aws configure`;


This scrips creates a private ECR repository with the name `k8simage`, don't forget to delete when you're done.

To build the application and upload to ECR:
1. From a terminal, cd into this folder;
2. Run command `./build_and_upload_all.sh`;
