data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {


  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name = "demo-eks"

  cluster_version = "1.35"

  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  create_kms_key            = false
  cluster_encryption_config = {}
  enable_kms_key_rotation   = false

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:sts::366183011726:assumed-role/AWSReservedSSO_AdministratorAccess_c6c4e2f33ef77df6/jakubo"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  eks_managed_node_groups = {
    workers = {
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}

