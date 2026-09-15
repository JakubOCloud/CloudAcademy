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

module "ecs" {
  source = "../../modules/ecs"

  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  ecr_repository_url    = module.ecr.repository_url
  image_tag             = "bootstrap-1"
  execution_role_arn    = module.iam.ecs_execution_role_arn
  task_role_arn         = module.iam.ecs_task_role_arn
  log_group_name        = module.monitoring.ecs_log_group_name

  desired_count  = 1
  cpu            = 256
  memory         = 512
  container_port = 3000
}
