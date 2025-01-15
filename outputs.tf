output "ansible_server_public_ip" {
  value = aws_instance.ansible_server.public_ip
}

output "client_nodes_public_ips" {
  value = [for instance in aws_instance.client_nodes : instance.public_ip]
}

output "client_ips" {
  value = aws_instance.client_nodes[*].private_ip
}
