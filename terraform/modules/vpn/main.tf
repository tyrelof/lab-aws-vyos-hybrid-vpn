variable "vpc_id" {}
variable "route_table_id" {}
variable "on_prem_public_ip" {}
variable "on_prem_cidr" {} # Kept for potential other uses, or can be removed if unused, but avoiding altering variables unnecessarily.
variable "project" {}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = var.vpc_id
  amazon_side_asn = "64512"
  tags = { Name = "${var.project}-vgw" }
}

resource "aws_vpn_gateway_route_propagation" "private" {
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = var.route_table_id
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
  static_routes_only  = false
  tags = { Name = "${var.project}-vpn-conn" }
}

output "vpn_connection_id" {
  value = aws_vpn_connection.main.id
}

output "vpn_connection" {
  value = aws_vpn_connection.main
  sensitive = true
}
