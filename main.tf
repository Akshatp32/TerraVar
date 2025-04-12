terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Generate SSH Key
resource "tls_private_key" "ins_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "mykey" {
  key_name   = "ins_test_key"
  public_key = tls_private_key.ins_key.public_key_openssh
}

resource "local_file" "private_key" {
  content = tls_private_key.ins_key.private_key_pem
  filename =  "${path.module}/mykey.pem"
  
}
locals {
  project_name = "MyTerraformProject"
  vpc_name     = "VPC1"
  vpc1_name    = "vpc2"
}
# VPC
resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = local.vpc_name
  }
}

# Public Subnet
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet1_Public_Myvpc"
  }
}

# Private Subnet
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "Subnet2_Private_Myvpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "myvpcigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "MyVpc_igw"
  }
}

# Public Route Table
resource "aws_route_table" "Publicrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myvpcigw.id
  }

  tags = {
    Name = "PublicRT_MyVpc"
  }
}

# Route Table Associations
resource "aws_route_table_association" "publicsubnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.Publicrt.id
}

resource "aws_route_table_association" "publicsubnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.Publicrt.id
}

# Security Groups
resource "aws_security_group" "public_grp" {
  name        = "Allow_ALL_RULE"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-grp"
  }
}

# EC2 Instances
resource "aws_instance" "instance1" {
  ami                    = var.instance_ami
  instance_type          = var.server_instance
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.public_grp.id]
  key_name               = aws_key_pair.mykey.key_name

  tags = var.instance_tags
}


resource "aws_instance" "instance2" {
  ami                    = var.instance_ami
  instance_type          = var.server_instance
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.public_grp.id]
  key_name               = aws_key_pair.mykey.key_name

  tags = var.instance_tags
}

# Outputs
output "instance1_public_ip" {
  description = "Public IP of Instance 1"
  value       = aws_instance.instance1.public_ip
}

output "instance2_public_ip" {
  description = "Public IP of Instance 2"
  value       = aws_instance.instance2.public_ip
}
