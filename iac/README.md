# Deploying EKS infrastructure

Warning: 
**The infrastructure setup with these scripts do not consider free tier, costs will be involved.**

Do NOT forget to remove when you're done.

---

These scripts deploy all required infrastructure to the AWS cloud.

Before running:
- make sure you've installed, terraform, helm, kubectl, aws cli;
- configure your AWS context with: `aws configure`;


To run these scripts:
1. From a terminal, cd into this folder;
2. Run the command `terraform init`;
3. Run the command `terraform apply`;
4. When prompted: enter `yes`; 


To destroy the infrastructure:
1. Make sure to destroy the deployed application first;
2. Run the command `terraform destroy`;
4. When prompted: enter `yes`; 


The infrastructure installed are:
- Vpc, subnets, security groups, IAM roles and policies;
- EKS cluster;
- FluentBit logging -> Cloudwatch;
- AWS alb controller for ingress;