variable "vpc_id" {}
variable "route_table_id" {}
variable "on_prem_public_ip" {}
variable "on_prem_cidr" {}
variable "project" {}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = var.vpc_id
  tags = { Name = "${var.project}-vgw" }
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = var.on_prem_public_ip
  type       = "ipsec.1"
  tags = { Name = "${var.project}-cgw" }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = { Name = "${var.project}-vpn-conn" }
}

resource "aws_vpn_connection_route" "on_prem_route" {
  destination_cidr_block = var.on_prem_cidr
  vpn_connection_id      = aws_vpn_connection.main.id
}

resource "aws_route" "private_to_vgw" {
  route_table_id         = var.route_table_id
  destination_cidr_block = var.on_prem_cidr
  gateway_id             = aws_vpn_gateway.vgw.id
}

output "vpn_connection_id" {
  value = aws_vpn_connection.main.id
}
