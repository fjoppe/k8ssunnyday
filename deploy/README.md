# Deploy application to EKS

These scripts deploy a non-trivial application to the EKS cluster. The application logic is
very simple, however the deployment emulates a backend service, which retrieves some data from a database.

Remove the application before removing the infrastructure.

Before running:
1. make sure you deployed the infrastructure as described in: iac/README.md;
2. make sure you build and uploaded the application as described in: build/README.md;

To run these scripts:
1. From a terminal, cd into this folder;
2. Run the command `terraform init`;
3. Run the command `terraform apply`;
4. When prompted: enter `yes`; 


Test the application:
- note, the ALB must be in State "Active" for the url's to work;
- run script `./get_testurls.sh`, this will print two url's which you can open in your browser, to test with more id's, see the "FIFA" column in the [source data](https://raw.githubusercontent.com/datasets/country-codes/master/data/country-codes.csv);
- in the AWS console, go switch to the region you've deployed, and go to the Cloudwatch service;
- under "Log Groups" you'll find the stream "/aws/eks/k8s-sunnyday/ns/default" in which the services "restapi" and "database" write their logging;


To remove the application deployment:
1. Run the command `terraform destroy`;
2. When prompted: enter `yes`;
3. You can manually delete the image `k8simage` from ECR;
