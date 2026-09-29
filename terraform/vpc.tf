resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
tags = {
    Name = "DevOps-Project-VPC"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
tags = {
    Name = "DevOps-IGW"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
tags = {
    Name = "DevOps-Public-Subnet"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
tags = {
    Name = "DevOps-Public-RT"
  }
}
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}