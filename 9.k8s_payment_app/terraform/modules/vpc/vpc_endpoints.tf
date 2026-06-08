resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-vpce"
  description = "VPC Endpoint Security Group"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-central-1.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-central-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private_app[*].id
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-central-1.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-central-1.sts"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "eks" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-central-1.eks"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-central-1.ec2"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true
}
