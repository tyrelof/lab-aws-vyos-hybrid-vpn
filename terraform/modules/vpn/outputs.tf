output "vpn_connection" {
  value     = aws_vpn_connection.main
  sensitive = true
}
