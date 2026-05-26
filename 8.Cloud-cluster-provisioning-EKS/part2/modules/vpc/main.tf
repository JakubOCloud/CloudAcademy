resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.101.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.102.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.103.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.104.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_1.id
}

resource "aws_route_table_association" "private_2" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_2.id
}
