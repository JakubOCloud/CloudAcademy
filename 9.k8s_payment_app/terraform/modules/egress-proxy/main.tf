data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "proxy" {
  name_prefix = "${var.project_name}-${var.environment}-egress-proxy-"
  description = "Restricted outbound HTTPS proxy for EKS"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP proxy from private application subnets"
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = var.allowed_client_cidrs
  }

  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP for OS package repositories if required"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-egress-proxy-sg"
  }
}

resource "aws_instance" "proxy" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.proxy.id]

  user_data = templatefile("${path.module}/squid.conf.tftpl", {
    allowed_client_cidrs = var.allowed_client_cidrs
  })

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name    = "${var.project_name}-${var.environment}-egress-proxy"
    Project = var.project_name
  }
}
