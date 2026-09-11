module "networking" {
  source = "../../modules/networking"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "ecr" {
  source = "../../modules/ecr"

  environment = var.environment
}

module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  vpc_cidr          = var.vpc_cidr

  target_port = 3000
}

module "iam" {
  source = "../../modules/iam"

  environment        = var.environment
  ecr_repository_arn = module.ecr.repository_arn
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment       = var.environment
  retention_in_days = 14
}
