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

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  project  = var.project
}

module "security" {
  source       = "./modules/security"
  vpc_id       = module.vpc.vpc_id
  on_prem_cidr = var.on_prem_cidr
  project      = var.project
}

module "vpn" {
  source            = "./modules/vpn"
  vpc_id            = module.vpc.vpc_id
  route_table_id    = module.vpc.private_route_table_id
  on_prem_public_ip = var.on_prem_public_ip
  on_prem_cidr      = var.on_prem_cidr
  project           = var.project
}
