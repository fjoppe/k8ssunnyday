data "aws_iam_policy_document" "k8assumerolepolicy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "cloudwatchwriterpolicydocument" {
  statement {
      effect = "Allow"
      actions = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:PutRetentionPolicy",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ]
            
        resources = ["*"]
    }
}


resource "aws_iam_policy" "cloudwatchwriterpolicy" {
  name = "${var.clustername}-cloudwatchwriterpolicy"
  policy = data.aws_iam_policy_document.cloudwatchwriterpolicydocument.json
}


resource "aws_iam_role" "k8eksrole" {
    name = "${var.clustername}-role"
    assume_role_policy = data.aws_iam_policy_document.k8assumerolepolicy.json
}


resource "aws_iam_role_policy_attachment" "attach-EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.k8eksrole.name
}


resource "aws_eks_cluster" "sunnyday" {
    name = var.clustername
    role_arn = aws_iam_role.k8eksrole.arn

    vpc_config {
      subnet_ids = [ for subnet in aws_subnet.pubsubnets: subnet.id ]
    }

    depends_on = [ aws_iam_role_policy_attachment.attach-EKSClusterPolicy ]
}


data "aws_iam_policy_document" "k8nodegroupassumerolepolicy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


data "http" "alb_policy_document" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}


resource "aws_iam_policy" "alb_serviceaccount_policy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.alb_policy_document.response_body
}


resource "aws_iam_role_policy_attachment" "k8srole-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.k8eksrole.name
}


resource "aws_iam_role" "k8snodegrouprole" {
    name = "${var.clustername}-nodegroup-role"
    assume_role_policy = data.aws_iam_policy_document.k8nodegroupassumerolepolicy.json  
}


resource "aws_iam_role_policy_attachment" "k8snodegrouprole-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8snodegrouprole.name
}


resource "aws_iam_role_policy_attachment" "k8snodegrouprole-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8snodegrouprole.name
}


resource "aws_iam_role_policy_attachment" "k8snodegrouprole-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.k8snodegrouprole.name
}


resource "aws_iam_role_policy_attachment" "k8snodegrouprole-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8snodegrouprole.name
}


resource "aws_iam_role_policy_attachment" "attach_service_account_policy" {
  policy_arn = aws_iam_policy.alb_serviceaccount_policy.arn
  role       = aws_iam_role.k8snodegrouprole.name
}


resource "aws_iam_role" "k8scloudwatchrole" {
    name = "${var.clustername}-cloudwatch-role"
    assume_role_policy = data.aws_iam_policy_document.k8nodegroupassumerolepolicy.json
}


resource "aws_iam_role_policy_attachment" "k8snodegrouprole-cloudwatchwriter" {
  policy_arn = aws_iam_policy.cloudwatchwriterpolicy.arn
  role       = aws_iam_role.k8scloudwatchrole.name
}


resource "aws_eks_node_group" "sunnydaygroup" {
  cluster_name    = aws_eks_cluster.sunnyday.name
  node_group_name = "${var.clustername}-group"
  node_role_arn   = aws_iam_role.k8snodegrouprole.arn
  subnet_ids      = [ for subnet in aws_subnet.pubsubnets: subnet.id ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
}


output "endpoint" {
    value = aws_eks_cluster.sunnyday.endpoint  
}


output "cluster_id" {
  value = aws_eks_cluster.sunnyday.cluster_id
}