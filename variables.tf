# AWS Provider Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# Access Key and Secret key
variable "access_key" {
  description = "Define Your Account Access Key"
  type        = string
  #sensitive = true
}
variable "secret_key" {
  description = "Define Your Account Secret Key"
  type        = string
  #sensitive = true 
}

# VPC and Subnets
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# EC2 Configuration
variable "instance_ami" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0d682f26195e9ec0f"
}

variable "server_instance" {
  description = "Instance type for EC2 servers"
  type        = string
  default     = "t2.micro"
}

variable "instance_tags" {
  description = "Tags for EC2 instances"
  type        = map(string)
  default = {
    Name    = "WebServer"
    Project = "TerraformDeployment"
    Env     = "Development"
  }
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}

# Security Groups
variable "allowed_ports" {
  description = "List of allowed ports in security group"
  type        = list(number)
  default     = [22, 80, 443, 3306]
}

# Load Balancer
variable "elb_name" {
  description = "Name of the Load Balancer"
  type        = string
  default     = "my-load-balancer"
}

# Database Configuration
variable "db_instance" {
  description = "Instance type for RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# Object Type - DB Configuration
variable "db_config" {
  description = "Database configuration object"
  type = object({
    instance_class    = string
    allocated_storage = number
    port              = number
  })
  default = {
    instance_class    = "db.t3.micro"
    allocated_storage = 20
    port              = 3306
  }
}

# Tuple Type Example
variable "reserved_ips" {
  description = "Tuple of reserved private IPs"
  type        = tuple([string, string])
  default     = ["10.0.1.50", "10.0.1.51"]
}

# Any Type Variable Example
variable "dynamic_variable" {
  description = "A flexible variable that can be of any type"
  type        = any
  default     = "default-value"
}
