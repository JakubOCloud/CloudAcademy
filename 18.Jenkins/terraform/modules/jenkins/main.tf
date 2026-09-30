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

resource "aws_iam_role" "jenkins" {
  name = "${var.environment}-jenkins-role"

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

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.environment}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "jenkins" {
  name        = "${var.environment}-jenkins-sg"
  description = "Security group for Jenkins"
  vpc_id      = var.vpc_id

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-jenkins-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  iam_instance_profile = aws_iam_instance_profile.jenkins.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true

    tags = {
      Name        = "${var.environment}-jenkins-root"
      Environment = var.environment
    }
  }

  user_data = file("${path.module}/install-jenkins.sh")

  tags = {
    Name        = "${var.environment}-jenkins"
    Environment = var.environment
  }
}


data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role_policy" "jenkins_infra" {
  name = "${var.environment}-jenkins-infra-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # ECR - CI agent / Docker images

      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = [
          "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/task-management-api-dev",
          "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/task-management-api-prod"
        ]
      },

      # EC2 / VPC / Networking

      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeAddresses",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:DescribeAddressesAttribute",
          "ec2:DescribeSecurityGroupRules",

          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",

          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:ModifySubnetAttribute",

          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:CreateRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",

          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",

          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",

          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",

          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },

      # Application Load Balancer

      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",

          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",

          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTargetGroupAttributes",

          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyTargetGroup",

          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeListenerAttributes",

          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]
        Resource = "*"
      },

      # ECS

      {
        Effect = "Allow"
        Action = [
          "ecs:CreateCluster",
          "ecs:DeleteCluster",
          "ecs:DescribeClusters",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTasks",

          "ecs:CreateService",
          "ecs:UpdateService",
          "ecs:DeleteService",
          "ecs:DescribeServices",

          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeTaskDefinition",

          "ecs:ListTaskDefinitions",

          "ecs:TagResource",
          "ecs:UntagResource"
        ]
        Resource = "*"
      },

      # IAM - roles used by ECS

      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:TagRole",
          "iam:UntagRole",

          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",

          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies"
        ]
        Resource = "*"
      },


      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/dev-ecs-execution-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/dev-ecs-task-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/prod-ecs-execution-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/prod-ecs-task-role"
        ]
      },

      # CloudWatch Logs

      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy",
          "logs:TagResource",
          "logs:ListTagsForResource"
        ]
        Resource = "*"
      },

      # Secrets Manager

      {
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:GetResourcePolicy"
        ]
        Resource = "*"
      },

      # S3 - Terraform remote state

      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::cloud-academy-jenkins-task-terraform-state"
      },

      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::cloud-academy-jenkins-task-terraform-state/dev/terraform.tfstate",
          "arn:aws:s3:::cloud-academy-jenkins-task-terraform-state/dev/terraform.tfstate.tflock",
          "arn:aws:s3:::cloud-academy-jenkins-task-terraform-state/prod/terraform.tfstate",
          "arn:aws:s3:::cloud-academy-jenkins-task-terraform-state/prod/terraform.tfstate.tflock"
        ]
      }
    ]
  })
}
