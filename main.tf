terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "iam" {
  source      = "./modules/iam"
  bucket_name = var.bucket_name
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  my_ip               = var.my_ip
}

module "ec2" {
  source                = "./modules/ec2"
  bucket_name           = var.bucket_name
  subnet_id             = module.vpc.public_subnet_id
  security_group_id     = module.vpc.security_group_id
  instance_profile_name = module.iam.instance_profile_name
  instance_profile_write_only_name = module.iam.instance_profile_write_only_name
}

