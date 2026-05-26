module "vpc" {
  source = "./modules/vpc"
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_ids[0]

}

module "eks" {
  source = "./modules/eks"

  subnet_ids                = module.vpc.private_subnet_ids
  vpc_id                    = module.vpc.vpc_id
  bastion_security_group_id = module.bastion.security_group_id
  bastion_role_arn          = module.bastion.bastion_role_arn
}
