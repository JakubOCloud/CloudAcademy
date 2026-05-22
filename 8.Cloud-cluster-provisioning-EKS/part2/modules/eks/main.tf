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

  eks_managed_node_groups = {
    workers = {
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}
