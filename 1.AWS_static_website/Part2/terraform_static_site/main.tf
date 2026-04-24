module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  tags        = var.tags
}

module "waf" {
  source = "./modules/waf"
  providers = {
    aws = aws.us_east_1
  }
}

module "cloudfront" {
  source             = "./modules/cloudfront"
  bucket_domain_name = module.s3.bucket_domain_name
  bucket_arn         = module.s3.bucket_arn
  tags               = var.tags
  web_acl_arn        = module.waf.web_acl_arn
}
