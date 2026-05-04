aws_region = "eu-central-1"

vpc_cidr             = "10.1.0.0/16"
availability_zones   = ["eu-central-1a", "eu-central-1b"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]

app_image_url = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/hello-world-repo:latest"
