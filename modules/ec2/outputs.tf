output "public_instance_id" {
  value = aws_instance.public_node.id
}

output "public_instance_public_ip" {
  value = aws_instance.public_node.public_ip
}

output "private_instance_id" {
  value = aws_instance.private_node.id
}
