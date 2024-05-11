provider "aws" {
    alias = "aws-region"
}


data "aws_region" "current" {
  provider = aws.aws-region
}


variable "clustername" {
  type = string
  default = "k8s-sunnyday"
}


variable "tag_name" {
  type = string
  default = "k8ssunnyday"
}


provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
