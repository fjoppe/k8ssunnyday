provider "kubernetes" {
    config_path = "~/.kube/config"
}

provider "aws" {
    alias = "aws-region"
}

data "aws_region" "current" {
  provider = aws.aws-region
}
