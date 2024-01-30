resource "aws_iam_role" "eksClusterRole" {
  name = "eksClusterRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    tag-key = "Amazon EKS - Cluster role"
  }
}

resource "aws_iam_role" "AmazonEKSNodeRole" {
  name = "AmazonEKSNodeRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    tag-key = "Amazon EKS - Node role"
  }
}

data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_policy_attachment" "eksClusterRole-attach" {
  name       = "eksClusterRole-attachment"
  roles      = [aws_iam_role.eksClusterRole.name]
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
}

resource "aws_iam_policy_attachment" "AmazonEKSNodeRole-attach" {
  name = "AmazonEKSNodeRole-attachment"
  for_each = toset([
    data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn,
    data.aws_iam_policy.AmazonEKS_CNI_Policy.arn,
    data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
  ])

  roles      = [aws_iam_role.AmazonEKSNodeRole.name]
  policy_arn = each.value
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eksClusterRole.arn

  vpc_config {
    subnet_ids = var.subnets_id
  }

  depends_on = [aws_iam_policy_attachment.eksClusterRole-attach]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}_node_group"
  node_role_arn   = aws_iam_role.AmazonEKSNodeRole.arn
  subnet_ids      = var.subnets_id
  instance_types  = var.instance_types

  remote_access {
    ec2_ssh_key               = var.remote_access.ssh_key
  }

  scaling_config {
    desired_size = var.node_size.desired_size
    max_size     = var.node_size.max_size
    min_size     = var.node_size.min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [aws_iam_policy_attachment.eksClusterRole-attach]
}