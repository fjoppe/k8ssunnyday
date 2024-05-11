# k8s-sunnyday

Warning: 
**The infrastructure setup with these scripts do not consider free tier, costs will be involved.**

Do NOT forget to remove when you're done.

---

Portfolio repository to setup an AWS EKS Kubernetes cluster from terraform.

This project demonstrates how to use terraform to deploy an EKS cluster to AWS and to deploy an application into the EKS cluster.

This repo consists of three main parts, follow the instructions in the README's in the following order:
1. iac/ - deploys the EKS cluster infrastructure;
2. build/ - builds the application images and stores these in ECR;
3. deploy/ - deploys the application to the EKS cluster;

Note: setup your environment with `aws configure` before you begin.