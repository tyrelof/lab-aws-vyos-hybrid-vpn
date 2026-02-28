output "vpn_tunnel_details" {
  description = "VPN Tunnel 1 and 2 Details for VyOS Configuration"
  value = {
    tunnel1_address            = module.vpn.vpn_connection.tunnel1_address
    tunnel1_preshared_key      = module.vpn.vpn_connection.tunnel1_preshared_key
    tunnel1_cgw_inside_address = module.vpn.vpn_connection.tunnel1_cgw_inside_address
    tunnel1_vgw_inside_address = module.vpn.vpn_connection.tunnel1_vgw_inside_address
    tunnel2_address            = module.vpn.vpn_connection.tunnel2_address
    tunnel2_preshared_key      = module.vpn.vpn_connection.tunnel2_preshared_key
    tunnel2_cgw_inside_address = module.vpn.vpn_connection.tunnel2_cgw_inside_address
    tunnel2_vgw_inside_address = module.vpn.vpn_connection.tunnel2_vgw_inside_address
  }
  sensitive = true
}

output "aws_private_ip" {
  description = "Private IP of the Test Target instance"
  value       = aws_instance.vpn_test_target.private_ip
}
