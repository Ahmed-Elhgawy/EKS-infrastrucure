# ****************************** EKS CLUSTER ******************************
resource "aws_iam_role" "EksClusterRole" {
  name = "EksClusterRole"

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

data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy_attachment" "EksClusterRole-attach" {
  name       = "EksClusterRole-attachment"
  roles      = [aws_iam_role.EksClusterRole.name]
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.EksClusterRole.arn

  vpc_config {
    subnet_ids = var.subnets_id
  }

  depends_on = [aws_iam_policy_attachment.EksClusterRole-attach]
}

# ****************************** EKS NODES ******************************
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

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
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

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}_node_group"
  node_role_arn   = aws_iam_role.AmazonEKSNodeRole.arn
  subnet_ids      = var.subnets_id
  instance_types  = var.instance_types

  remote_access {
    ec2_ssh_key = var.remote_access.ssh_key
  }

  scaling_config {
    desired_size = var.node_size.desired_size
    max_size     = var.node_size.max_size
    min_size     = var.node_size.min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [aws_iam_policy_attachment.EksClusterRole-attach]
}

# ****************************** TLS CERTIFICATE ******************************
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# ****************************** AWS-EBS-CSI-DRIVER ******************************
data "aws_iam_policy_document" "AmazonEBSCSIDriverPolicy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "AmazonEBSCSIDriverRole" {
  assume_role_policy = data.aws_iam_policy_document.AmazonEBSCSIDriverPolicy.json
  name               = "AmazonEBSCSIDriverRole"
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverRole-attach" {
  role       = aws_iam_role.AmazonEBSCSIDriverRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.AmazonEBSCSIDriverRole.arn

  depends_on = [
    aws_eks_node_group.node_group,
    aws_iam_role_policy_attachment.AmazonEBSCSIDriverRole-attach
  ]
}
