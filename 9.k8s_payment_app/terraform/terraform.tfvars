project_name = "finpay"

aws_region = "eu-central-1"

cluster_name = "finpay"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "eu-central-1a",
  "eu-central-1b",
  "eu-central-1c"
]

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_app_subnets = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24"
]

private_db_subnets = [
  "10.0.21.0/24",
  "10.0.22.0/24",
  "10.0.23.0/24"
]

postgres_db_name = "payments"

postgres_db_username = "payments"
