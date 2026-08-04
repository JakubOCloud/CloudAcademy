resource "aws_security_group" "postgres" {
  name        = "postgres-vm-sg"
  description = "PostgreSQL VM"
  vpc_id      = var.vpc_id

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_iam_role" "postgres_vm" {
  name = "finpay-postgres-vm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.postgres_vm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "postgres_vm" {
  name = "finpay-postgres-vm-profile"
  role = aws_iam_role.postgres_vm.name
}

data "aws_ami" "al2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "postgres" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type

  subnet_id = var.private_subnet_id

  vpc_security_group_ids = [
    aws_security_group.postgres.id
  ]

  iam_instance_profile = aws_iam_instance_profile.postgres_vm.name

  user_data = templatefile(
    "${path.module}/user-data.sh.tpl",
    {
      postgres_password = random_password.postgres.result
    }
  )

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "finpay-postgres"
  }
}

resource "random_password" "postgres" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}
