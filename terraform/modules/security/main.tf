variable "vpc_id" {}
variable "on_prem_cidr" {}
variable "project" {}

resource "aws_security_group" "private_sg" {
  name        = "${var.project}-private-sg"
  description = "Allow ICMP and SSH from On-Prem VyOS"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from On-Prem Network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.on_prem_cidr]
  }

  ingress {
    description = "ICMP from On-Prem Network"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.on_prem_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "security_group_id" {
  value = aws_security_group.private_sg.id
}
