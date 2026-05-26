resource "aws_iam_role" "eks_cluster_role" {

  name = "demo-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "this" {
  name     = "demo-eks"
  version  = "1.35"
  role_arn = aws_iam_role.eks_cluster_role.arn

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = false
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = var.tags
}

resource "aws_iam_role" "eks_node_role" {
  name = "demo-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "workers"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]

  tags = var.tags
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = "arn:aws:iam::366183011726:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_AdministratorAccess_c6c4e2f33ef77df6"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_policy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.admin.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
