data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  subnet_id = var.subnet_id

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.jenkins.name

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = file("${path.module}/install-jenkins.sh")

  tags = {
    Name        = "jenkins"
    Environment = "ci"
  }
}

resource "aws_security_group" "jenkins" {
  name   = "${var.environment}-jenkins-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
