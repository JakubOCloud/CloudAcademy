module "networking" {
  source = "../../modules/networking"

  environment        = "ci"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "jenkins" {
  source = "../../modules/jenkins"

  environment = "ci"

  vpc_id = module.networking.vpc_id

  subnet_id = module.networking.public_subnet_ids[0]

  admin_cidr = var.admin_cidr

  instance_type    = "t3.medium"
  root_volume_size = 30
}
