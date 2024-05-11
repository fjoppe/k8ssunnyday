# This prepares helm constructs like fluentbit
resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name 'k8s-sunnyday'"
    }
    depends_on = [ aws_eks_cluster.sunnyday ]
}


# This installs the fluentbit component, which also sends logs to CloudWatch
resource "helm_release" "fluentbit" {
  name       = "fluent-bit"
  namespace  = "fluent"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  create_namespace = true
  values = [
    templatefile("${path.module}/fluentbit/fluentbit.conf.yaml", {
      region = data.aws_region.current.name
      cluster_name = var.clustername
      log_retention_in_days = 2
      full_log = "log"
      iam_role_arn = aws_iam_role.k8scloudwatchrole.arn
    })
  ]
  depends_on = [ aws_eks_node_group.sunnydaygroup ]
}