provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = var.tags
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  log_group_name = "/ecs/hello-api"

  tags = var.tags
}

module "alb" {
  source = "./modules/alb"

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids
  app_port         = var.app_port

  tags = var.tags
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name          = "hello-world-cluster"
  task_family           = "hello-world-task"
  ecs_task_cpu          = var.ecs_task_cpu
  ecs_task_memory       = var.ecs_task_memory
  app_image             = var.app_image_url
  app_port              = var.app_port
  log_group_name        = module.cloudwatch.log_group_name
  desired_task_count    = var.desired_task_count
  max_task_count        = var.max_task_count
  target_group_arn      = module.alb.target_group_arn
  vpc_id                = module.vpc.vpc_id
  private_subnets_ids   = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.security_group_id

  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  cpu_high_threshold = var.cpu_high_threshold
  cpu_low_threshold  = var.cpu_low_threshold
  scale_in_cooldown  = var.scale_in_cooldown
  scale_out_cooldown = var.scale_out_cooldown

  depends_on = [module.alb, module.cloudwatch]

  tags = var.tags
}
