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

  db_secret_arn = module.database_secret.secret_arn
}



/*module "rds" {
  source = "./modules/rds"

  project_name = var.project_name

  vpc_id = module.vpc.vpc_id

  private_db_subnet_ids = module.vpc.private_db_subnet_ids

  private_app_subnets = var.private_app_subnets

  db_name = var.postgres_db_name

  db_username = var.postgres_db_username
}*/

module "postgres_vm" {
  source = "./modules/postgres-vm"

  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_db_subnet_ids[0]
}

module "database_secret" {
  source = "./modules/database-secret"

  project_name = var.project_name

  db_endpoint = module.postgres_vm.private_ip
  db_port     = module.postgres_vm.db_port
  db_name     = module.postgres_vm.db_name

  db_username = module.postgres_vm.db_username
  db_password = module.postgres_vm.db_password
}


module "addons" {
  source = "./modules/addons"

  cluster_name            = module.eks.cluster_name
  vpc_id                  = module.vpc.vpc_id
  alb_controller_role_arn = module.eks.alb_controller_role_arn
  fluent_bit_role_arn     = module.eks.fluent_bit_role_arn

  depends_on = [
    module.eks
  ]
}

module "cloudwatch_observability" {
  source = "./modules/cloudwatch-observability"

  cluster_name = module.eks.cluster_name
}

module "cloudwatch_alarms" {
  source = "./modules/cloudwatch-alarms"

  cluster_name         = module.eks.cluster_name
  postgres_instance_id = module.postgres_vm.instance_id
}

