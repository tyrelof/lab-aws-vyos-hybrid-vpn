variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project Name used for Tags"
  type        = string
  default     = "lab01-vpn"
}

variable "vpc_cidr" {
  description = "CIDR block for the AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "on_prem_cidr" {
  description = "CIDR block for the On-Premises Network"
  type        = string
  default     = "192.168.0.0/24"
}

variable "on_prem_public_ip" {
  description = "Public IP of the Customer Gateway (VyOS Router)"
  type        = string
}
