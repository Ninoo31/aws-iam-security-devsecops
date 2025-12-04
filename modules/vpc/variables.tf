variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
}

variable "my_ip" {
  description = "Your Public IP address (format x.x.x.x/32) for SSH access"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_flow_role" {
  description = "vpc role arn"
  type        = string
}