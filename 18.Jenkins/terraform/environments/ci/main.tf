module "networking" {
  source = "../../modules/networking"

  environment        = "ci"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}
