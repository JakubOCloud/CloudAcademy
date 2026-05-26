resource "aws_iam_role" "bastion_role" {
  name = "bastion_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "bastion_eks" {
  name = "bastion-eks-access"
  role = aws_iam_role.bastion_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "bastion-instance-profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_security_group" "this" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "this" {
  ami           = "ami-036bdae36143a955f"
  instance_type = "t3.micro"
  subnet_id     = var.private_subnet_id

  vpc_security_group_ids = [aws_security_group.this.id]

  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = false
  tags                        = var.tags
}
