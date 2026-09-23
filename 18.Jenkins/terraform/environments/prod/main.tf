module "networking" {
  source = "../../modules/networking"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
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
  ecr_repository_arn = "arn:aws:ecr:eu-central-1:366183011726:repository/task-management-api-prod"
  secret_arn         = module.secrets.secret_arn
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
  ecr_repository_url    = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/task-management-api-prod"
  image_tag             = var.image_tag
  execution_role_arn    = module.iam.ecs_execution_role_arn
  task_role_arn         = module.iam.ecs_task_role_arn
  log_group_name        = module.monitoring.ecs_log_group_name

  secret_arn = module.secrets.secret_arn

  desired_count  = 2
  cpu            = 256
  memory         = 512
  container_port = 3000
}

module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
}
