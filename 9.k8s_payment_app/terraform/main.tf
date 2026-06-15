module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnets = var.public_subnets

  private_app_subnets = var.private_app_subnets

  private_db_subnets = var.private_db_subnets
}

module "eks" {
  source = "./modules/eks"

  cluster_name = var.cluster_name

  private_subnet_ids = module.vpc.private_app_subnet_ids

  db_secret_arn = module.rds.secret_arn
}



module "rds" {
  source = "./modules/rds"

  project_name = var.project_name

  vpc_id = module.vpc.vpc_id

  private_db_subnet_ids = module.vpc.private_db_subnet_ids

  private_app_subnets = var.private_app_subnets

  db_name = var.postgres_db_name

  db_username = var.postgres_db_username
}

module "addons" {
  source = "./modules/addons"

  cluster_name            = module.eks.cluster_name
  vpc_id                  = module.vpc.vpc_id
  alb_controller_role_arn = var.alb_controller_role_arn

  depends_on = [
    module.eks
  ]
}
