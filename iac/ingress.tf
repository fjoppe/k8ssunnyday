# This installs the ALB Ingress Controller as IngressClass
# The ALB will be created by an IngressRule, which is part of the deployment
resource "helm_release" "ingress_alb" {
  name = "aws-load-balancer-controller"
  namespace = "eks"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  create_namespace = true
  set {
    name = "clusterName"
    value = var.clustername
  }
  set {
    name = "serviceAccount.create"
    value = "true"
  }
  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name = "region"
    value = data.aws_region.current.name
  }

  depends_on = [ aws_eks_node_group.sunnydaygroup ]
}
